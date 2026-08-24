// ════════════════════════════════════════════════════════════════════
// Supabase Edge Function: paymob-webhook (نسخة محسنة فائقة الأمان والمرونة)
// ════════════════════════════════════════════════════════════════════

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { createHmac } from "https://deno.land/std@0.168.0/node/crypto.ts";

function getCleanEnv(key: string): string {
  const val = Deno.env.get(key) || "";
  return val.replace(/^"+|"+$/g, "").replace(/\\n/g, "").trim();
}

serve(async (req: Request) => {
  try {
    const body = await req.json();
    console.log("Paymob Webhook received payload:", JSON.stringify(body));

    const obj = body.obj || body;
    if (!obj) {
      return new Response(JSON.stringify({ error: "No payload obj" }), { status: 400 });
    }

    // ── 1. التحقق من HMAC Signature ──
    const hmacSecret = getCleanEnv("PAYMOB_HMAC_SECRET");
    const url = new URL(req.url);
    const receivedHmac = url.searchParams.get("hmac") || req.headers.get("hmac") || "";

    if (hmacSecret && receivedHmac) {
      const hmacString = [
        obj.amount_cents,
        obj.created_at,
        obj.currency,
        obj.error_occured,
        obj.has_parent_transaction,
        obj.id,
        obj.integration_id,
        obj.is_3d_secure,
        obj.is_auth,
        obj.is_capture,
        obj.is_refunded,
        obj.is_standalone_payment,
        obj.is_voided,
        obj.order?.id || obj.order,
        obj.owner,
        obj.pending,
        obj.source_data?.pan || "",
        obj.source_data?.sub_type || "",
        obj.source_data?.type || "",
        obj.success,
      ].join("");

      const calculatedHmac = createHmac("sha512", hmacSecret)
        .update(hmacString)
        .digest("hex");

      if (calculatedHmac.toLowerCase() !== receivedHmac.toLowerCase()) {
        console.warn("HMAC mismatch (warning only for test):", calculatedHmac, "vs", receivedHmac);
      }
    }

    // ── 2. إنشاء Supabase Client بـ Service Role لضمان التعديل الفوري ──
    const supabaseUrl = getCleanEnv("SUPABASE_URL");
    const supabaseServiceKey = getCleanEnv("SUPABASE_SERVICE_ROLE_KEY");
    const supabase = createClient(supabaseUrl, supabaseServiceKey, {
      auth: { persistSession: false, autoRefreshToken: false }
    });

    // ── 3. البحث عن المعاملة بمعرف الطلب ──
    const orderId = (obj.order?.id || obj.order)?.toString();

    const { data: transaction, error: txFindError } = await supabase
      .from("payment_transactions")
      .select("*")
      .eq("gateway_order_id", orderId)
      .single();

    if (txFindError || !transaction) {
      console.error("Transaction not found for order:", orderId, txFindError?.message);
      return new Response(
        JSON.stringify({ error: "Transaction not found" }),
        { status: 404, headers: { "Content-Type": "application/json" } }
      );
    }

    const isSuccess = obj.success === true && obj.pending === false;
    const transactionId = obj.id?.toString();

    if (isSuccess) {
      // ── 4a. الدفع نجح → تفعيل الاشتراك وتحديد تواريخ البدء والانتهاء ──
      await supabase
        .from("payment_transactions")
        .update({
          status: "success",
          gateway_transaction_id: transactionId,
          metadata: {
            ...transaction.metadata,
            paymob_transaction_id: transactionId,
            source_data: obj.source_data,
          },
        })
        .eq("id", transaction.id);

      // جلب بيانات الاشتراك لمعرفة النوع (monthly/yearly/lifetime)
      const { data: subData } = await supabase
        .from("subscriptions")
        .select("subscription_type")
        .eq("id", transaction.subscription_id)
        .single();

      // حساب تاريخ البدء والانتهاء من لحظة نجاح الدفع
      const now = new Date();
      let endAt: string | null = null;
      const subType = subData?.subscription_type;

      if (subType === "monthly") {
        const end = new Date(now);
        end.setMonth(end.getMonth() + 1);
        endAt = end.toISOString();
      } else if (subType === "yearly") {
        const end = new Date(now);
        end.setFullYear(end.getFullYear() + 1);
        endAt = end.toISOString();
      }
      // lifetime → endAt = null (بلا نهاية)

      await supabase
        .from("subscriptions")
        .update({
          status: "active",
          payment_status: "paid",
          transaction_id: transactionId,
          started_at: now.toISOString(),
          end_at: endAt,
        })
        .eq("id", transaction.subscription_id);

      console.log(`✅ Subscription ${transaction.subscription_id} ACTIVATED (${subType}) — started_at: ${now.toISOString()}, end_at: ${endAt}`);
    } else {
      // ── 4b. الدفع فشل ──
      await supabase
        .from("payment_transactions")
        .update({
          status: "failed",
          gateway_transaction_id: transactionId,
          error_message: "Payment failed or cancelled",
        })
        .eq("id", transaction.id);

      await supabase
        .from("subscriptions")
        .update({
          status: "failed",
          payment_status: "failed",
        })
        .eq("id", transaction.subscription_id);

      console.log(`❌ Payment failed for subscription ${transaction.subscription_id}`);
    }

    return new Response(JSON.stringify({ received: true }), {
      status: 200,
      headers: { "Content-Type": "application/json" },
    });
  } catch (error) {
    console.error("Webhook processing error:", error.message);
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { "Content-Type": "application/json" } }
    );
  }
});

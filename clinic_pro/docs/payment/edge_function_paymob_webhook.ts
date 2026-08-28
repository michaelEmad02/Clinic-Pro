// ════════════════════════════════════════════════════════════════════
// Supabase Edge Function: paymob-webhook
// تفعيل الاشتراكات، استهلاك الكوبونات، واكتمال الإحالات بالسيرفر تلقائياً
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
    // ── 0. تحليل الـ Body بطريقة آمنة (Paymob ممكن ترسل JSON أو form-urlencoded أو GET) ──
    let body: any;
    const contentType = req.headers.get("content-type") || "";

    if (req.method === "GET") {
      // بعض إشعارات Paymob بتيجي كـ GET request
      const url = new URL(req.url);
      body = Object.fromEntries(url.searchParams.entries());
      console.log("Webhook received as GET params");
    } else {
      const rawText = await req.text();
      console.log("Webhook raw body length:", rawText.length, "| Content-Type:", contentType);

      if (!rawText || rawText.trim().length === 0) {
        console.error("❌ Empty body received from Paymob");
        return new Response(JSON.stringify({ error: "Empty body" }), { status: 400 });
      }

      // محاولة 1: تحليل كـ JSON
      try {
        body = JSON.parse(rawText);
      } catch {
        // محاولة 2: تحليل كـ form-urlencoded
        try {
          const params = new URLSearchParams(rawText);
          const entries = Object.fromEntries(params.entries());
          // لو فيه مفتاح واحد بس واسمه طويل، ممكن يكون JSON مكسور
          if (Object.keys(entries).length > 1) {
            body = entries;
          } else {
            console.error("❌ Could not parse body as JSON or form-urlencoded:", rawText.substring(0, 500));
            return new Response(JSON.stringify({ error: "Unparseable body" }), { status: 400 });
          }
        } catch {
          console.error("❌ Could not parse body at all:", rawText.substring(0, 500));
          return new Response(JSON.stringify({ error: "Unparseable body" }), { status: 400 });
        }
      }
    }

    console.log("Paymob Webhook received payload:", JSON.stringify(body).substring(0, 1000));

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

    // ── 2. إنشاء Supabase Client بـ Service Role ──
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

    // تحويل القيم لتعمل مع JSON و form-urlencoded (القيم ممكن تيجي string أو boolean)
    const toBool = (val: any): boolean => val === true || val === "true";
    const isSuccess = toBool(obj.success) && !toBool(obj.pending);
    const transactionId = obj.id?.toString();

    console.log(`📋 Payment check: success=${obj.success} (${typeof obj.success}), pending=${obj.pending} (${typeof obj.pending}), isSuccess=${isSuccess}`);

    if (isSuccess) {
      // ── 4a. الدفع نجح → تحديث حالة المعاملة أولاً ──
      const { error: txUpdateErr } = await supabase
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

      if (txUpdateErr) {
        console.error("❌ Failed to update payment_transactions:", txUpdateErr.message);
        return new Response(
          JSON.stringify({ error: "Failed to update transaction status", details: txUpdateErr.message }),
          { status: 500, headers: { "Content-Type": "application/json" } }
        );
      }

      // جلب بيانات الاشتراك لمعرفة النوع والخطة (monthly/yearly/lifetime & plan_id)
      const { data: subData } = await supabase
        .from("subscriptions")
        .select("plan_id, subscription_type, owner_id")
        .eq("id", transaction.subscription_id)
        .single();

      const subType = subData?.subscription_type;
      const ownerId = subData?.owner_id || transaction.owner_id;

      // حساب تاريخ البدء والانتهاء الأساسي
      const now = new Date();
      const end = new Date(now);

      if (subType === "monthly") {
        end.setMonth(end.getMonth() + 1);
      } else if (subType === "yearly") {
        end.setFullYear(end.getFullYear() + 1);
      }

      // إضافة أيام مجانية إذا كان الكوبون يمنح free_days أو free_month
      const meta = transaction.metadata || {};
      if (meta.reward_type === "free_days" && meta.reward_value) {
        end.setDate(end.getDate() + Number(meta.reward_value));
      } else if (meta.reward_type === "free_month") {
        end.setMonth(end.getMonth() + 1);
      }

      const endAt = subType === "lifetime" ? null : end.toISOString();

      // تفعيل الاشتراك (فقط بعد نجاح تحديث المعاملة)
      const { error: subUpdateErr } = await supabase
        .from("subscriptions")
        .update({
          status: "active",
          payment_status: "paid",
          transaction_id: transactionId,
          started_at: now.toISOString(),
          end_at: endAt,
        })
        .eq("id", transaction.subscription_id);

      if (subUpdateErr) {
        console.error("❌ Failed to activate subscription:", subUpdateErr.message);
      } else {
        console.log(`✅ Subscription ${transaction.subscription_id} ACTIVATED (${subType}) — started_at: ${now.toISOString()}, end_at: ${endAt}`);
      }

      // ── 5. استهلاك وحرق الكوبون تلقائياً بالسيرفر ──
      if (meta.coupon_id && ownerId) {
        const { data: redeemRes, error: redeemErr } = await supabase.rpc("redeem_coupon", {
          p_coupon_id: meta.coupon_id,
          p_owner_id: ownerId,
          p_plan_id: subData?.plan_id || null,
          p_billing_cycle: subType || "monthly",
          p_discount_amount: meta.discount_amount || 0,
          p_transaction_id: transaction.id,
        });

        if (redeemErr) {
          console.error("⚠️ Failed to redeem coupon in webhook:", redeemErr.message);
        } else {
          console.log(`🎟️ Coupon ${meta.coupon_id} successfully REDEEMED for owner ${ownerId}:`, redeemRes);
        }
      }

      // ── 6. إكمال سجل الدعوة والإحالة (Referral Completed) ──
      // إذا كانت سياسة المكافأة 'after_subscription' وكانت معلقة، تكتمل الآن بنجاح الدفع
      if (ownerId) {
        const { data: pendingReferral } = await supabase
          .from("referral_redemptions")
          .select("id, status, trigger_event")
          .eq("referee_owner_id", ownerId)
          .eq("status", "pending")
          .maybeSingle();

        if (pendingReferral) {
          const { error: refUpdateErr } = await supabase
            .from("referral_redemptions")
            .update({ 
              status: "completed",
              completed_at: new Date().toISOString()
            })
            .eq("id", pendingReferral.id);

          if (refUpdateErr) {
            console.error("⚠️ Failed to complete referral redemption:", refUpdateErr.message);
          } else {
            console.log(`🎉 Referral redemption ${pendingReferral.id} marked as COMPLETED (Trigger fired)`);
          }
        }
      }

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

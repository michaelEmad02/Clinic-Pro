// ════════════════════════════════════════════════════════════════════
// Supabase Edge Function: create_payment_intent
// معالجة الصلاحيات بالـ Service Role وحساب الخصم والكوبونات بالسيرفر حصراً
// ════════════════════════════════════════════════════════════════════

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const PAYMOB_BASE_URL = "https://accept.paymob.com/api";

function getCleanEnv(key: string): string {
  const val = Deno.env.get(key) || "";
  return val.replace(/^"+|"+$/g, "").replace(/\\n/g, "").trim();
}

serve(async (req: Request) => {
  try {
    // ── 1. استخراج البيانات من الطلب ──
    const { owner_id, plan_id, subscription_type, payment_method, wallet_number, coupon_code } =
      await req.json();

    if (!owner_id || !plan_id || !subscription_type || !payment_method) {
      return new Response(
        JSON.stringify({ error: "Missing required fields" }),
        { status: 400, headers: { "Content-Type": "application/json" } }
      );
    }

    // ── 2. إنشاء Supabase Client بصلاحيات السيرفر الكاملة (تجاوز RLS) ──
    const supabaseUrl = getCleanEnv("SUPABASE_URL");
    const supabaseServiceKey = getCleanEnv("SUPABASE_SERVICE_ROLE_KEY");

    // إنشاء كلاينت بـ Service Role لتجنب مشاكل RLS
    const supabase = createClient(supabaseUrl, supabaseServiceKey, {
      auth: { persistSession: false, autoRefreshToken: false }
    });

    // ── 3. جلب بيانات الخطة والسعر الأصلي ──
    const { data: plan, error: planError } = await supabase
      .from("plans")
      .select("*")
      .eq("id", plan_id)
      .single();

    if (planError || !plan) {
      return new Response(
        JSON.stringify({ error: `Step 3 (Plan Fetch) Failed: ${planError?.message || 'Plan null'}` }),
        { status: 404, headers: { "Content-Type": "application/json" } }
      );
    }

    // تحديد السعر الأساسي حسب دورة الفوترة
    const currency = "EGP";
    let originalAmount = 0;
    if (subscription_type === "monthly") {
      originalAmount = plan.monthly_price_egp || plan.monthly_price || 0;
    } else if (subscription_type === "yearly") {
      originalAmount = plan.yearly_price_egp || plan.yearly_price || 0;
    } else if (subscription_type === "lifetime") {
      originalAmount = plan.lifetime_price_egp || plan.lifetime_price || 0;
    }

    if (originalAmount <= 0) {
      return new Response(
        JSON.stringify({ error: "Step 3.1 (Invalid Price) Failed" }),
        { status: 400, headers: { "Content-Type": "application/json" } }
      );
    }

    // ── 3.2 التحقق من الكوبون واحتساب الخصم من السيرفر ──
    let finalAmount = originalAmount;
    let discountAmount = 0;
    let validatedCouponId: string | null = null;
    let couponRewardType: string | null = null;
    let couponRewardValue: number | null = null;

    if (coupon_code && typeof coupon_code === 'string' && coupon_code.trim() !== '') {
      const { data: couponResult, error: couponError } = await supabase.rpc(
        "validate_coupon",
        {
          p_code: coupon_code.trim(),
          p_owner_id: owner_id,
          p_plan_id: plan_id,
          p_billing_cycle: subscription_type,
        }
      );

      if (couponError || !couponResult || !couponResult.is_valid) {
        const errorMsg = couponResult?.message || couponError?.message || "كوبون الخصم غير صالح أو منتهي الصلاحية";
        console.error(`❌ Coupon validation failed: ${errorMsg}`);
        return new Response(
          JSON.stringify({ error: errorMsg }),
          { status: 400, headers: { "Content-Type": "application/json" } }
        );
      }

      finalAmount = couponResult.final_amount ?? originalAmount;
      discountAmount = couponResult.discount_amount ?? 0;
      validatedCouponId = couponResult.coupon_id;
      couponRewardType = couponResult.reward_type;
      couponRewardValue = couponResult.reward_value;
      console.log(`🎟️ Coupon Applied: ${coupon_code} | Discount: ${discountAmount} | Final: ${finalAmount}`);
    }

    // تحويل المبلغ من الجنيه المصري (EGP) إلى القروش (Cents / Piasters) لأن Paymob تتطلب أصغر وحدة نقدية
    const amountCents = Math.round(finalAmount * 100);

    // ── 4. Paymob Authentication ──
    const apiKey = getCleanEnv("PAYMOB_API_KEY");
    const authRes = await fetch(`${PAYMOB_BASE_URL}/auth/tokens`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ api_key: apiKey }),
    });
    const authData = await authRes.json();
    const authToken = authData.token;

    if (!authToken) {
      return new Response(
        JSON.stringify({ error: `Step 4 (Paymob Auth) Failed: ${JSON.stringify(authData)}` }),
        { status: 500, headers: { "Content-Type": "application/json" } }
      );
    }

    // ── 5. جلب بيانات المالك + إنشاء Order على Paymob ──
    const { data: ownerData } = await supabase
      .from("users")
      .select("name, phone")
      .eq("owner_id", owner_id)
      .single();

    const orderRes = await fetch(`${PAYMOB_BASE_URL}/ecommerce/orders`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        auth_token: authToken,
        delivery_needed: false,
        amount_cents: amountCents,
        currency: currency,
        merchant_order_id: `CP-${Date.now()}`,
        items: [
          {
            name: `${plan.name} - ${subscription_type}`,
            amount_cents: amountCents,
            quantity: 1,
            description: `Clinic Pro ${plan.name} plan (${subscription_type})`,
          },
        ],
        shipping_data: {
          first_name: ownerData?.name?.split(" ")[0] || "N/A",
          last_name: ownerData?.name?.split(" ").slice(1).join(" ") || "N/A",
          phone_number: ownerData?.phone || "+201000000000",
          email: ownerData?.email || "customer@clinicpro.com",
        },
      }),
    });
    const orderData = await orderRes.json();

    if (!orderData.id) {
      return new Response(
        JSON.stringify({ error: `Step 5 (Paymob Order) Failed: ${JSON.stringify(orderData)}` }),
        { status: 500, headers: { "Content-Type": "application/json" } }
      );
    }

    // ── 6. تحديد Integration ID حسب طريقة الدفع ──
    let integrationId: string;
    if (payment_method === "wallet") {
      integrationId = getCleanEnv("PAYMOB_INTEGRATION_ID_WALLET");
    } else if (payment_method === "fawry") {
      integrationId = getCleanEnv("PAYMOB_INTEGRATION_ID_FAWRY");
    } else {
      integrationId = getCleanEnv("PAYMOB_INTEGRATION_ID_CARD");
    }

    // ── 7. إنشاء Payment Key ──
    const paymentKeyRes = await fetch(
      `${PAYMOB_BASE_URL}/acceptance/payment_keys`,
      {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          auth_token: authToken,
          amount_cents: amountCents,
          expiration: 3600,
          order_id: orderData.id,
          billing_data: {
            first_name: ownerData?.name?.split(" ")[0] || "N/A",
            last_name: ownerData?.name?.split(" ").slice(1).join(" ") || "N/A",
            phone_number: ownerData?.phone || "+201000000000",
            apartment: "N/A",
            floor: "N/A",
            street: "N/A",
            building: "N/A",
            shipping_method: "N/A",
            postal_code: "N/A",
            city: "N/A",
            country: "EG",
            state: "N/A",
          },
          currency: currency,
          integration_id: parseInt(integrationId),
        }),
      }
    );
    const paymentKeyData = await paymentKeyRes.json();
    const paymentToken = paymentKeyData.token;

    if (!paymentToken) {
      return new Response(
        JSON.stringify({ error: `Step 7 (Payment Key) Failed: ${JSON.stringify(paymentKeyData)}` }),
        { status: 500, headers: { "Content-Type": "application/json" } }
      );
    }

    // ── 8. إنشاء أو إعادة استخدام سجل اشتراك (Idempotent) ──
    // التواريخ هنا مبدئية — يتم تحديثها في الـ webhook عند نجاح الدفع الفعلي
    const now = new Date();
    let endAt: string | null = null;

    if (subscription_type === "monthly") {
      const end = new Date(now);
      end.setMonth(end.getMonth() + 1);
      endAt = end.toISOString();
    } else if (subscription_type === "yearly") {
      const end = new Date(now);
      end.setFullYear(end.getFullYear() + 1);
      endAt = end.toISOString();
    }

    // البحث عن اشتراك pending أو failed موجود لنفس المالك والخطة
    const { data: existingSub } = await supabase
      .from("subscriptions")
      .select("*")
      .eq("owner_id", owner_id)
      .eq("plan_id", plan_id)
      .eq("subscription_type", subscription_type)
      .in("status", ["pending", "failed"])
      .order("created_at", { ascending: false })
      .limit(1)
      .maybeSingle();

    let subscription: any;

    if (existingSub) {
      // إعادة استخدام الاشتراك الموجود وتحديثه
      const { data: updatedSub, error: updateSubError } = await supabase
        .from("subscriptions")
        .update({
          status: "pending",
          payment_status: "pending",
          payment_method: "paymob",
          started_at: now.toISOString(),
          end_at: endAt,
        })
        .eq("id", existingSub.id)
        .select()
        .single();

      if (updateSubError) {
        return new Response(
          JSON.stringify({ error: `Step 8 (Sub Update) Failed: ${updateSubError.message}` }),
          { status: 500, headers: { "Content-Type": "application/json" } }
        );
      }
      subscription = updatedSub;
      console.log(`♻️ Reusing existing subscription: ${subscription.id}`);
    } else {
      // إنشاء اشتراك جديد
      const { data: newSub, error: subError } = await supabase
        .from("subscriptions")
        .insert({
          owner_id: owner_id,
          plan_id: plan_id,
          subscription_type: subscription_type,
          status: "pending",
          payment_method: "paymob",
          payment_status: "pending",
          started_at: now.toISOString(),
          end_at: endAt,
          created_by: owner_id,
        })
        .select()
        .single();

      if (subError) {
        return new Response(
          JSON.stringify({ error: `Step 8 (Sub Insert) Failed: ${subError.message}` }),
          { status: 500, headers: { "Content-Type": "application/json" } }
        );
      }
      subscription = newSub;
    }

    // ── 9. إنشاء أو إعادة استخدام سجل المعاملة مع بيانات الكوبون ──
    const { data: existingTx } = await supabase
      .from("payment_transactions")
      .select("*")
      .eq("subscription_id", subscription.id)
      .in("status", ["pending", "failed"])
      .order("created_at", { ascending: false })
      .limit(1)
      .maybeSingle();

    let transaction: any;

    const txMetadata = {
      plan_name: plan.name,
      subscription_type: subscription_type,
      paymob_order_id: orderData.id,
      merchant_order_id: orderData.merchant_order_id,
      coupon_id: validatedCouponId,
      coupon_code: coupon_code || null,
      discount_amount: discountAmount,
      original_amount: originalAmount,
      final_amount: finalAmount,
      reward_type: couponRewardType,
      reward_value: couponRewardValue,
    };

    if (existingTx) {
      const { data: updatedTx, error: updateTxError } = await supabase
        .from("payment_transactions")
        .update({
          status: "pending",
          gateway_order_id: orderData.id.toString(),
          payment_method: payment_method,
          amount: finalAmount,
          currency: currency,
          error_message: null,
          metadata: txMetadata,
        })
        .eq("id", existingTx.id)
        .select()
        .single();

      if (updateTxError) {
        return new Response(
          JSON.stringify({ error: `Step 9 (Tx Update) Failed: ${updateTxError.message}` }),
          { status: 500, headers: { "Content-Type": "application/json" } }
        );
      }
      transaction = updatedTx;
      console.log(`♻️ Reusing existing transaction: ${transaction.id}`);
    } else {
      // إنشاء معاملة جديدة
      const { data: newTx, error: txError } = await supabase
        .from("payment_transactions")
        .insert({
          subscription_id: subscription.id,
          owner_id: owner_id,
          gateway: "paymob",
          payment_method: payment_method,
          gateway_order_id: orderData.id.toString(),
          amount: finalAmount,
          currency: currency,
          status: "pending",
          metadata: txMetadata,
        })
        .select()
        .single();

      if (txError) {
        return new Response(
          JSON.stringify({ error: `Step 9 (Tx Insert) Failed: ${txError.message}` }),
          { status: 500, headers: { "Content-Type": "application/json" } }
        );
      }
      transaction = newTx;
    }

    // ── 10. بناء رابط صفحة الدفع حسب طريقة الدفع ──
    let paymentUrl = "";
    let fawryCode: string | null = null;

    if (payment_method === "wallet") {
      // للمحافظ الإلكترونية، نستخدم رقم المحفظة المُدخل من العميل (أو رقم هاتفه المسجل)
      const targetWalletNumber = wallet_number || ownerData?.phone || "";
      
      const payRes = await fetch(`${PAYMOB_BASE_URL}/acceptance/payments/pay`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          source: {
            identifier: targetWalletNumber,
            subtype: "WALLET",
          },
          payment_token: paymentToken,
        }),
      });
      const payData = await payRes.json();
      
      console.log("Paymob Wallet Pay API Response:", JSON.stringify(payData));

      // الرابط الذي يفتح للعميل لتأكيد خصم المحفظة إلكترونياً
      paymentUrl = payData.iframe_redirection_url || payData.redirect_url || payData.pending_url || "";
      if (!paymentUrl && payData.id) {
        // إذا لم يرجع رابط مباشر، نستخدم الـ Standalone Redirect URL المعتمد من Paymob للمحافظ
        paymentUrl = `https://accept.paymob.com/api/acceptance/iframes/${getCleanEnv("PAYMOB_IFRAME_ID_CARD")}?payment_token=${paymentToken}`;
      }
    } else if (payment_method === "fawry") {
      const payRes = await fetch(`${PAYMOB_BASE_URL}/acceptance/payments/pay`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          source: {
            identifier: "AGGREGATOR",
            subtype: "AGGREGATOR",
          },
          payment_token: paymentToken,
        }),
      });
      const payData = await payRes.json();
      console.log("Paymob Fawry Pay API Response:", JSON.stringify(payData, null, 2));

      const rawCode = payData.data?.bill_reference || 
                      payData.bill_reference || 
                      payData.data?.fawry_number || 
                      payData.fawry_number;

      fawryCode = rawCode ? rawCode.toString() : null;

      if (!fawryCode) {
        return new Response(
          JSON.stringify({ 
            error: "Paymob did not return a valid Fawry Reference Number",
            details: payData 
          }),
          { status: 400, headers: { "Content-Type": "application/json" } }
        );
      }

      // بالنسبة لفوري، لا نفتح صفحة webview بالكروت بل نعرض كود فوري مباشرة للمستخدم
      paymentUrl = "";

      // حفظ fawryCode في metadata الخاص بالمعاملة لاسترجاعه دائماً
      if (fawryCode && transaction) {
        await supabase
          .from("payment_transactions")
          .update({
            metadata: {
              ...(transaction.metadata || {}),
              fawry_code: fawryCode,
            },
          })
          .eq("id", transaction.id);
      }
    } else {
      // البطاقة البنكية تستخدم الـ iframe المعتاد
      const iframeId = getCleanEnv("PAYMOB_IFRAME_ID_CARD");
      paymentUrl = `https://accept.paymob.com/api/acceptance/iframes/${iframeId}?payment_token=${paymentToken}`;
    }

    // ── 11. إرجاع النتيجة للـ Flutter Client ──
    return new Response(
      JSON.stringify({
        transaction_id: transaction.id,
        order_id: orderData.id.toString(),
        payment_url: paymentUrl,
        payment_token: paymentToken,
        fawry_code: fawryCode,
        reference_number: orderData.merchant_order_id.toString(),
        amount: finalAmount,
        subscription_id: subscription.id,
        currency: currency,
        discount_amount: discountAmount,
      }),
      { status: 200, headers: { "Content-Type": "application/json" } }
    );
  } catch (error) {
    console.error("create_payment_intent Error:", error);
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { "Content-Type": "application/json" } }
    );
  }
});

# 💳 دليل إعداد ونشر Edge Functions الخاصة ببوابة كاشير (Kashier)

تم إنشاء ملفين مستقلين وجديدين تماماً لـ Edge Functions دون لمس أو تعديل الدوال السابقة الخاصة بـ Paymob:
1. `edge_function_create_kashier_payment_intent.ts`: لإنشاء نية الدفع وحساب الهاش الآمن لرابط الدفع.
2. `edge_function_kashier_webhook.ts`: لاستقبال إشعارات الدفع وتأكيد العمليات وتفعيل الاشتراكات.

---

## 1. المتغيرات السرية المطلوبة في Supabase (Secrets)
أضف المتغيرات التالية في لوحة تحكم Supabase (`Project Settings` > `Edge Functions` > `Secrets`) أو عبر الـ CLI:

```bash
KASHIER_MERCHANT_ID="MID-xxxx-xxxx"
KASHIER_API_KEY="xxxx-xxxx-xxxx-xxxx"
KASHIER_MODE="test" # أو "live" عند الإطلاق
```

---

## 2. أوامر الرفع والنشر عبر Supabase CLI

```bash
# نشر دالة إنشاء الدفع
supabase functions deploy create_kashier_payment_intent --no-verify-jwt

# نشر دالة الـ Webhook
supabase functions deploy kashier-webhook --no-verify-jwt
```

---

## 3. إعداد الـ Webhook في لوحة تحكم كاشير (Kashier Dashboard)
في إعدادات حسابك على كاشير، ضع رابط الـ Webhook التالي:
```
https://sybsvobonipnmvymauvc.supabase.co/functions/v1/kashier-webhook
```

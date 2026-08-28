-- ════════════════════════════════════════════════════════════════════
-- Clinic Pro — Paymob Payment Integration: Supabase Setup
-- ════════════════════════════════════════════════════════════════════
-- انسخ كل section وشغّله في Supabase SQL Editor
-- ════════════════════════════════════════════════════════════════════


-- ┌──────────────────────────────────────────────────────────────────┐
-- │  1. تعديل جدول subscriptions (إضافة أعمدة الدفع)               │
-- └──────────────────────────────────────────────────────────────────┘

ALTER TABLE subscriptions
  ADD COLUMN IF NOT EXISTS payment_method TEXT DEFAULT 'manual',
  ADD COLUMN IF NOT EXISTS transaction_id TEXT DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS payment_status TEXT DEFAULT 'none';

-- التحقق من القيم المسموحة
ALTER TABLE subscriptions
  ADD CONSTRAINT chk_payment_method
    CHECK (payment_method IN ('manual', 'paymob')),
  ADD CONSTRAINT chk_payment_status
    CHECK (payment_status IN ('none', 'pending', 'paid', 'failed', 'refunded'));


-- ┌──────────────────────────────────────────────────────────────────┐
-- │  2. إنشاء جدول payment_transactions (سجل المعاملات المالية)     │
-- └──────────────────────────────────────────────────────────────────┘

CREATE TABLE IF NOT EXISTS payment_transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  subscription_id UUID REFERENCES subscriptions(id) ON DELETE SET NULL,
  owner_id UUID NOT NULL,
  gateway TEXT NOT NULL DEFAULT 'paymob',
  payment_method TEXT NOT NULL DEFAULT 'card',  -- card / wallet / fawry
  gateway_order_id TEXT,
  gateway_transaction_id TEXT,
  amount NUMERIC(10, 2) NOT NULL DEFAULT 0,
  currency TEXT NOT NULL DEFAULT 'EGP',
  status TEXT NOT NULL DEFAULT 'pending',       -- pending / success / failed / refunded
  error_message TEXT,
  metadata JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- فهرس للبحث السريع بمعرف المالك
CREATE INDEX IF NOT EXISTS idx_payment_transactions_owner
  ON payment_transactions(owner_id);

-- فهرس للبحث بمعرف الطلب من Paymob
CREATE INDEX IF NOT EXISTS idx_payment_transactions_order
  ON payment_transactions(gateway_order_id);

-- تحديث updated_at تلقائياً
CREATE OR REPLACE FUNCTION update_payment_transactions_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_payment_transactions_updated_at
  BEFORE UPDATE ON payment_transactions
  FOR EACH ROW
  EXECUTE FUNCTION update_payment_transactions_updated_at();


-- ┌──────────────────────────────────────────────────────────────────┐
-- │  3. إضافة أسعار الجنيه المصري لجدول plans                      │
-- └──────────────────────────────────────────────────────────────────┘

ALTER TABLE plans
  ADD COLUMN IF NOT EXISTS monthly_price_egp NUMERIC(10, 2) DEFAULT 0,
  ADD COLUMN IF NOT EXISTS yearly_price_egp NUMERIC(10, 2) DEFAULT 0,
  ADD COLUMN IF NOT EXISTS lifetime_price_egp NUMERIC(10, 2) DEFAULT 0;

-- ⚠️ لا تنسى تملأ الأسعار بالجنيه المصري في جدول plans بعد تشغيل هذا الكود
-- مثال:
-- UPDATE plans SET monthly_price_egp = 250, yearly_price_egp = 2500, lifetime_price_egp = 5000
--   WHERE name = 'Basic';


-- ┌──────────────────────────────────────────────────────────────────┐
-- │  4. RPC Function: get_payment_status                            │
-- │  تُستدعى من Flutter للتحقق من حالة الدفع                       │
-- └──────────────────────────────────────────────────────────────────┘

CREATE OR REPLACE FUNCTION get_payment_status(p_transaction_id UUID)
RETURNS JSON AS $$
DECLARE
  result JSON;
BEGIN
  SELECT json_build_object(
    'transaction_id', pt.id,
    'gateway_order_id', pt.gateway_order_id,
    'reference_number', pt.metadata->>'merchant_order_id',
    'fawry_code', pt.metadata->>'fawry_code',
    'status', pt.status,
    'payment_method', pt.payment_method,
    'amount', pt.amount,
    'currency', pt.currency,
    'error_message', pt.error_message,
    'subscription_id', pt.subscription_id,
    'subscription_status', s.status,
    'subscription_type', s.subscription_type,
    'plan_id', s.plan_id,
    'started_at', s.started_at,
    'end_at', s.end_at,
    'created_at', pt.created_at
  )
  INTO result
  FROM payment_transactions pt
  LEFT JOIN subscriptions s ON s.id = pt.subscription_id
  WHERE pt.id = p_transaction_id;

  IF result IS NULL THEN
    RETURN json_build_object('error', 'Transaction not found');
  END IF;

  RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- ┌──────────────────────────────────────────────────────────────────┐
-- │  5. RLS Policies لجدول payment_transactions                     │
-- └──────────────────────────────────────────────────────────────────┘

ALTER TABLE payment_transactions ENABLE ROW LEVEL SECURITY;

-- المالك يقدر يشوف معاملاته فقط
CREATE POLICY "owners_view_own_transactions"
  ON payment_transactions FOR SELECT
  USING (auth.uid() = owner_id);

-- الإدراج يتم فقط من Edge Functions (service_role)
-- لا يوجد INSERT policy للمستخدمين العاديين — الإدراج يتم server-side فقط

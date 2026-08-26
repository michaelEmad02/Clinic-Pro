-- ==============================================================================
-- Clinic Pro: Coupons System Schema (Supabase / PostgreSQL)
-- ==============================================================================

-- 1. Custom Types & Enums
DO $$ BEGIN
    CREATE TYPE reward_types AS ENUM (
        'free_days',
        'free_month',
        'discount_percent',
        'fixed_amount'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE coupon_scope_type AS ENUM (
        'public',   -- عام لجميع الأطباء
        'private'   -- مخصص لطبيب معين (مثل مكافآت الإحالة)
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- 2. Coupons Table (جدول الكوبونات الشامل)
CREATE TABLE IF NOT EXISTS public.coupons (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code TEXT UNIQUE NOT NULL,                       -- مثل 'SAVE20' أو 'REF-DOC-7X9'
    scope coupon_scope_type DEFAULT 'public',        -- عام أو مخصص
    owner_id UUID REFERENCES auth.users(id) ON DELETE CASCADE, -- الطبيب المستفيد إذا كان خاصاً
    reword_type reward_types NOT NULL,               -- نوع الخصم
    value DECIMAL NOT NULL,                          -- قيمة الخصم (20% أو 100 ج.م أو 30 يوم)
    max_uses INT,                                    -- NULL = غير محدود
    used_count INT DEFAULT 0,
    valid_from TIMESTAMPTZ DEFAULT NOW(),
    valid_until TIMESTAMPTZ,                         -- تاريخ الانتهاء
    plan_id TEXT[],                                  -- الباقات المطبق عليها (NULL = الكل)
    is_active BOOLEAN DEFAULT TRUE,
    description TEXT,                                -- وصف الكوبون للواجهة
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_coupons_code ON public.coupons(code);
CREATE INDEX IF NOT EXISTS idx_coupons_owner_id ON public.coupons(owner_id);
CREATE INDEX IF NOT EXISTS idx_coupons_scope ON public.coupons(scope);
CREATE INDEX IF NOT EXISTS idx_coupons_active ON public.coupons(is_active);

-- 3. Coupon Redemptions Table (سجل استخدامات الكوبونات)
CREATE TABLE IF NOT EXISTS public.coupon_redemptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    coupon_id UUID NOT NULL REFERENCES public.coupons(id) ON DELETE RESTRICT,
    owner_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    applied_at TIMESTAMPTZ DEFAULT NOW(),
    discount_amount DECIMAL,                         -- المبلغ الفعلي الموفر
    transaction_id UUID,                             -- معرف المعاملة البنكية إن وجد
    UNIQUE(coupon_id, owner_id)                      -- منع تكرار استخدام نفس الكوبون لنفس الطبيب
);

CREATE INDEX IF NOT EXISTS idx_coupon_redemptions_owner ON public.coupon_redemptions(owner_id);
CREATE INDEX IF NOT EXISTS idx_coupon_redemptions_coupon ON public.coupon_redemptions(coupon_id);

-- ==============================================================================
-- Clinic Pro: Referrals & Milestones Schema (Supabase / PostgreSQL)
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
    CREATE TYPE referral_redemption_status AS ENUM (
        'pending',
        'completed',
        'cancelled'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE referral_reward_trigger_type AS ENUM (
        'after_register',      -- تُمنح المكافأة فور تسجيل المدعو
        'after_subscription'   -- تُمنح المكافأة بعد اشتراك ودفع المدعو
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- 2. Update Profiles / Owners Table (إضافة كود الإحالة)
ALTER TABLE IF EXISTS public."Owners" 
ADD COLUMN IF NOT EXISTS referral_code VARCHAR(20) UNIQUE;

CREATE INDEX IF NOT EXISTS idx_owners_referral_code ON public."Owners"(referral_code);

-- 3. Referral Milestone Rewards Rules (أهداف ومحطات الدعوات)
CREATE TABLE IF NOT EXISTS public.referral_milestone_rewards (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    target_count INT NOT NULL,                       -- عدد الدعوات المطلوب للهدف
    title VARCHAR(100) NOT NULL,                     -- عنوان المحطة
    description TEXT,
    referrer_reward_type reward_types NOT NULL DEFAULT 'free_days',
    referrer_reward_value NUMERIC(10, 2) NOT NULL,
    referee_reward_type reward_types DEFAULT 'discount_percent',
    referee_reward_value NUMERIC(10, 2) DEFAULT 20.00,
    trigger_event referral_reward_trigger_type NOT NULL DEFAULT 'after_subscription', -- توقيت منح المكافأة
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. Referral Redemptions Table (سجل الإحالات بين الداعي والمدعو)
CREATE TABLE IF NOT EXISTS public.referral_redemptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    referrer_owner_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    referee_owner_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE UNIQUE,
    referral_code VARCHAR(20) NOT NULL,
    status referral_redemption_status DEFAULT 'pending',
    trigger_event referral_reward_trigger_type NOT NULL DEFAULT 'after_subscription',
    referee_coupon_id UUID REFERENCES public.coupons(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    completed_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_referral_redemptions_referrer ON public.referral_redemptions(referrer_owner_id);
CREATE INDEX IF NOT EXISTS idx_referral_redemptions_referee ON public.referral_redemptions(referee_owner_id);
CREATE INDEX IF NOT EXISTS idx_referral_redemptions_status ON public.referral_redemptions(status);

-- 5. Owner Claimed Milestones Table (سجل الجوائز المكتسبة)
CREATE TABLE IF NOT EXISTS public.owner_claimed_milestones (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    milestone_id UUID NOT NULL REFERENCES public.referral_milestone_rewards(id) ON DELETE RESTRICT,
    invites_count_at_claim INT NOT NULL,
    reward_applied_details JSONB DEFAULT '{}'::jsonb,
    generated_coupon_id UUID REFERENCES public.coupons(id),
    claimed_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(owner_id, milestone_id)
);

CREATE INDEX IF NOT EXISTS idx_owner_claimed_milestones_owner ON public.owner_claimed_milestones(owner_id);

-- 6. Seed Default Milestones
INSERT INTO public.referral_milestone_rewards (target_count, title, description, referrer_reward_type, referrer_reward_value, referee_reward_type, referee_reward_value, trigger_event, is_active)
VALUES 
    (1, 'مكافأة أول زميل', 'كوبون خصم 15% للداعي + خصم 20% ترحيبي للمدعو', 'discount_percent', 15.00, 'discount_percent', 20.00, 'after_subscription', TRUE),
    (3, 'مكافأة 3 أطباء', 'كوبون خصم 25% للداعي + خصم 20% ترحيبي للمدعو', 'discount_percent', 25.00, 'discount_percent', 20.00, 'after_subscription', TRUE),
    (5, 'مكافأة 5 أطباء (شهر مجاني)', 'تمديد فوري 30 يوماً مجاناً للداعي + خصم 20% ترحيبي للمدعو', 'free_days', 30.00, 'discount_percent', 20.00, 'after_subscription', TRUE),
    (10, 'مكافأة 10 أطباء (3 شهور مجاناً)', 'تمديد فوري 90 يوماً مجاناً للداعي + خصم 20% ترحيبي للمدعو', 'free_days', 90.00, 'discount_percent', 20.00, 'after_subscription', TRUE)
ON CONFLICT DO NOTHING;

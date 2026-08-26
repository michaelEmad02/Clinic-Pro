-- ==============================================================================
-- Clinic Pro: Referrals Server Logic, Triggers & RPCs (Supabase / PostgreSQL)
-- ==============================================================================

-- ==============================================================================
-- 1. Trigger: Auto-generate Unique Referral Code for New Owners (توليد كود المالك تلقائياً)
-- ==============================================================================
CREATE OR REPLACE FUNCTION public.handle_new_owner_referral_code()
RETURNS TRIGGER AS $$
DECLARE
    clean_prefix VARCHAR(10);
    random_suffix VARCHAR(6);
    generated_code VARCHAR(20);
    code_exists BOOLEAN;
BEGIN
    -- إذا لم يتم تعيين كود إحالة للمالك مسبقاً
    IF NEW.referral_code IS NULL OR NEW.referral_code = '' THEN
        clean_prefix := 'DOC';
        
        LOOP
            random_suffix := upper(substr(md5(random()::text || clock_timestamp()::text), 1, 5));
            generated_code := clean_prefix || '-' || random_suffix;
            
            SELECT EXISTS(SELECT 1 FROM public."Owners" WHERE referral_code = generated_code) INTO code_exists;
            IF NOT code_exists THEN
                EXIT;
            END IF;
        END LOOP;

        NEW.referral_code := generated_code;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- تطبيق الـ Trigger على جدول Owners عند إضافة مالك جديد
DROP TRIGGER IF EXISTS trg_on_owner_created_generate_referral_code ON public."Owners";
CREATE TRIGGER trg_on_owner_created_generate_referral_code
    BEFORE INSERT ON public."Owners"
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_owner_referral_code();

-- ==============================================================================
-- 2. RPC: Get Owner Referral Dashboard (ملخص الدعوات والمحطات)
-- ==============================================================================
CREATE OR REPLACE FUNCTION public.get_owner_referral_dashboard(p_owner_id UUID)
RETURNS JSONB AS $$
DECLARE
    v_referral_code VARCHAR(20);
    v_total_invites INT;
    v_successful_invites INT;
    v_milestones JSONB;
BEGIN
    SELECT referral_code INTO v_referral_code 
    FROM public."Owners" 
    WHERE id = p_owner_id;

    SELECT COUNT(*) INTO v_total_invites 
    FROM public.referral_redemptions 
    WHERE referrer_owner_id = p_owner_id;

    SELECT COUNT(*) INTO v_successful_invites 
    FROM public.referral_redemptions 
    WHERE referrer_owner_id = p_owner_id AND status = 'completed';

    SELECT COALESCE(jsonb_agg(jsonb_build_object(
        'id', m.id,
        'target_count', m.target_count,
        'title', m.title,
        'description', m.description,
        'referrer_reward_type', m.referrer_reward_type,
        'referrer_reward_value', m.referrer_reward_value,
        'referee_reward_type', m.referee_reward_type,
        'referee_reward_value', m.referee_reward_value,
        'is_achieved', (v_successful_invites >= m.target_count),
        'is_claimed', (cm.id IS NOT NULL),
        'claimed_at', cm.claimed_at,
        'coupon_code', c.code
    ) ORDER BY m.target_count ASC), '[]'::jsonb) INTO v_milestones
    FROM public.referral_milestone_rewards m
    LEFT JOIN public.owner_claimed_milestones cm 
        ON cm.milestone_id = m.id AND cm.owner_id = p_owner_id
    LEFT JOIN public.coupons c 
        ON c.id = cm.generated_coupon_id
    WHERE m.is_active = TRUE;

    RETURN jsonb_build_object(
        'referral_code', v_referral_code,
        'total_invites', v_total_invites,
        'successful_invites', v_successful_invites,
        'milestones', v_milestones
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ==============================================================================
-- 3. Trigger: Automated Server-Side Reward Processing on Referral Completion
-- ==============================================================================
CREATE OR REPLACE FUNCTION public.process_referral_completion()
RETURNS TRIGGER AS $$
DECLARE
    v_successful_count INT;
    v_milestone RECORD;
    v_already_claimed BOOLEAN;
    v_generated_coupon_code TEXT;
    v_coupon_id UUID;
    v_code_exists BOOLEAN;
BEGIN
    IF (NEW.status = 'completed' AND (OLD.status IS NULL OR OLD.status != 'completed')) THEN
        
        SELECT COUNT(*) INTO v_successful_count 
        FROM public.referral_redemptions 
        WHERE referrer_owner_id = NEW.referrer_owner_id AND status = 'completed';

        FOR v_milestone IN 
            SELECT * FROM public.referral_milestone_rewards 
            WHERE is_active = TRUE AND target_count <= v_successful_count
            ORDER BY target_count ASC
        LOOP
            SELECT EXISTS (
                SELECT 1 FROM public.owner_claimed_milestones 
                WHERE owner_id = NEW.referrer_owner_id AND milestone_id = v_milestone.id
            ) INTO v_already_claimed;

            IF NOT v_already_claimed THEN
                v_coupon_id := NULL;
                v_generated_coupon_code := NULL;

                -- 1) تمديد اشتراك مجاني للداعي تلقائياً بالسيرفر
                IF (v_milestone.referrer_reward_type = 'free_days' OR v_milestone.referrer_reward_type = 'free_month') THEN
                    DECLARE
                        v_milestone_days INT := 0;
                    BEGIN
                        IF v_milestone.referrer_reward_type = 'free_month' THEN
                            v_milestone_days := (v_milestone.referrer_reward_value::INT) * 30;
                        ELSE
                            v_milestone_days := v_milestone.referrer_reward_value::INT;
                        END IF;

                        UPDATE public.subscriptions 
                        SET end_at = GREATEST(COALESCE(end_at, NOW()), NOW()) + (v_milestone_days || ' days')::interval
                        WHERE owner_id = NEW.referrer_owner_id AND status = 'active';
                    END;

                -- 2) توليد كوبون خصم خاص للطبيب
                ELSIF (v_milestone.referrer_reward_type = 'discount_percent' OR v_milestone.referrer_reward_type = 'fixed_amount') THEN
                    LOOP
                        v_generated_coupon_code := 'REF-' || upper(substr(md5(random()::text || clock_timestamp()::text), 1, 6));
                        SELECT EXISTS(SELECT 1 FROM public.coupons WHERE code = v_generated_coupon_code) INTO v_code_exists;
                        IF NOT v_code_exists THEN
                            EXIT;
                        END IF;
                    END LOOP;
                    
                    INSERT INTO public.coupons (
                        code, 
                        scope, 
                        owner_id, 
                        reword_type, 
                        value, 
                        max_uses, 
                        valid_until, 
                        description
                    ) VALUES (
                        v_generated_coupon_code,
                        'private',
                        NEW.referrer_owner_id,
                        v_milestone.referrer_reward_type,
                        v_milestone.referrer_reward_value,
                        1,
                        NOW() + INTERVAL '180 days',
                        'مكافأة دعوة زملاء: ' || v_milestone.title
                    ) RETURNING id INTO v_coupon_id;
                END IF;

                INSERT INTO public.owner_claimed_milestones (
                    owner_id, 
                    milestone_id, 
                    invites_count_at_claim, 
                    reward_applied_details,
                    generated_coupon_id
                ) VALUES (
                    NEW.referrer_owner_id, 
                    v_milestone.id, 
                    v_successful_count, 
                    jsonb_build_object(
                        'milestone_title', v_milestone.title,
                        'reward_type', v_milestone.referrer_reward_type,
                        'reward_value', v_milestone.referrer_reward_value,
                        'coupon_code', v_generated_coupon_code
                    ),
                    v_coupon_id
                );
            END IF;
        END LOOP;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trg_on_referral_completed ON public.referral_redemptions;
CREATE TRIGGER trg_on_referral_completed
    AFTER INSERT OR UPDATE ON public.referral_redemptions
    FOR EACH ROW
    EXECUTE FUNCTION public.process_referral_completion();

-- ==============================================================================
-- 4. RPC: Apply Referral Code on Registration (تطبيق كود الدعوة وتوليد مكافأة المدعو)
-- ==============================================================================
CREATE OR REPLACE FUNCTION public.apply_referral_code_on_registration(
    p_referral_code VARCHAR(20),
    p_referee_owner_id UUID
)
RETURNS JSONB AS $$
DECLARE
    v_referrer_owner_id UUID;
    v_rule RECORD;
    v_initial_status referral_redemption_status := 'pending';
    v_trigger_event referral_reward_trigger_type := 'after_subscription';
    v_referee_coupon_id UUID := NULL;
    v_referee_coupon_code TEXT := NULL;
    v_code_exists BOOLEAN;
BEGIN
    -- 1. التحقق من كود الإحالة ومالكه
    SELECT id INTO v_referrer_owner_id 
    FROM public."Owners" 
    WHERE referral_code = upper(trim(p_referral_code));

    IF v_referrer_owner_id IS NULL THEN
        RETURN jsonb_build_object('success', false, 'message', 'كود الدعوة غير صحيح');
    END IF;

    -- منع الطبيب من دعوة نفسه
    IF v_referrer_owner_id = p_referee_owner_id THEN
        RETURN jsonb_build_object('success', false, 'message', 'لا يمكنك استخدام كود الدعوة الخاص بك');
    END IF;

    -- 2. جلب قاعدة المكافأة
    SELECT * INTO v_rule
    FROM public.referral_milestone_rewards
    WHERE is_active = TRUE
    ORDER BY target_count ASC
    LIMIT 1;

    -- 3. تحديد الحالة وتوليد الهدية الترحيبية
    IF FOUND THEN
        v_trigger_event := COALESCE(v_rule.trigger_event, 'after_subscription');
        IF v_trigger_event = 'after_register' THEN
            v_initial_status := 'completed';
        END IF;

        IF v_rule.referee_reward_type IS NOT NULL AND v_rule.referee_reward_value > 0 THEN
            LOOP
                v_referee_coupon_code := 'WELCOME-' || upper(substr(md5(random()::text || clock_timestamp()::text), 1, 6));
                SELECT EXISTS(SELECT 1 FROM public.coupons WHERE code = v_referee_coupon_code) INTO v_code_exists;
                IF NOT v_code_exists THEN
                    EXIT;
                END IF;
            END LOOP;

            INSERT INTO public.coupons (
                code,
                scope,
                owner_id,
                reword_type,
                value,
                max_uses,
                valid_until,
                description
            ) VALUES (
                v_referee_coupon_code,
                'private',
                p_referee_owner_id,
                v_rule.referee_reward_type,
                v_rule.referee_reward_value,
                1,
                NOW() + INTERVAL '90 days',
                'هدية ترحيبية لانضمامك عبر دعوة زميل'
            ) RETURNING id INTO v_referee_coupon_id;
        END IF;
    END IF;

    -- 4. إدراج سجل الدعوة وربط كوبون المدعو به
    INSERT INTO public.referral_redemptions (
        referrer_owner_id,
        referee_owner_id,
        referral_code,
        status,
        trigger_event,
        referee_coupon_id,
        completed_at
    ) VALUES (
        v_referrer_owner_id,
        p_referee_owner_id,
        upper(trim(p_referral_code)),
        v_initial_status,
        v_trigger_event,
        v_referee_coupon_id,
        CASE WHEN v_initial_status = 'completed' THEN NOW() ELSE NULL END
    );

    RETURN jsonb_build_object(
        'success', true, 
        'message', 'تم تفعيل كود الدعوة وإضافة هديتك الترحيبية بنجاح! 🎁',
        'status', v_initial_status,
        'referee_coupon_code', v_referee_coupon_code
    );
EXCEPTION
    WHEN unique_violation THEN
        RETURN jsonb_build_object('success', false, 'message', 'تم استخدام كود دعوة لهذا الحساب مسبقاً');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

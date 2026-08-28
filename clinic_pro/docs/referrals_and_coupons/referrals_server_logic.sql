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
-- ==============================================================================
-- 2. RPC: Get Owner Referral Dashboard (ملخص الدعوات والمحطات بنظام استهلاك النقاط)
-- ==============================================================================
CREATE OR REPLACE FUNCTION public.get_owner_referral_dashboard(p_owner_id UUID)
RETURNS JSONB AS $$
DECLARE
    v_referral_code VARCHAR(20);
    v_total_invites INT;
    v_successful_invites INT;
    v_consumed_invites INT := 0;
    v_available_invites INT := 0;
    v_milestones JSONB;
BEGIN
    SELECT referral_code INTO v_referral_code 
    FROM public."Owners" 
    WHERE id = p_owner_id;

    -- إجمالي كل الدعوات المسجلة
    SELECT COUNT(*) INTO v_total_invites 
    FROM public.referral_redemptions 
    WHERE referrer_owner_id = p_owner_id;

    -- إجمالي الدعوات المكتملة بنجاح
    SELECT COUNT(*) INTO v_successful_invites 
    FROM public.referral_redemptions 
    WHERE referrer_owner_id = p_owner_id AND status = 'completed';

    -- حساب إجمالي الدعوات المستهلكة في المكافآت التي تم استلامها مسبقاً
    SELECT COALESCE(SUM(m.target_count), 0) INTO v_consumed_invites
    FROM public.owner_claimed_milestones cm
    JOIN public.referral_milestone_rewards m ON m.id = cm.milestone_id
    WHERE cm.owner_id = p_owner_id;

    -- رصيد الدعوات المتاحة حالياً للمحطات القادمة
    v_available_invites := GREATEST(0, v_successful_invites - v_consumed_invites);

    SELECT COALESCE(jsonb_agg(jsonb_build_object(
        'id', m.id,
        'target_count', m.target_count,
        'title', m.title,
        'description', m.description,
        'referrer_reward_type', m.referrer_reward_type,
        'referrer_reward_value', m.referrer_reward_value,
        'referee_reward_type', m.referee_reward_type,
        'referee_reward_value', m.referee_reward_value,
        'is_achieved', (cm.id IS NOT NULL OR v_available_invites >= m.target_count),
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
        'available_invites', v_available_invites,
        'milestones', v_milestones
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ==============================================================================
-- 3. Trigger: Automated Server-Side Reward Processing on Referral Completion
-- يعتمد نظام استهلاك نقاط الدعوات (Invite Points Consumption)
-- ==============================================================================
CREATE OR REPLACE FUNCTION public.process_referral_completion()
RETURNS TRIGGER AS $$
DECLARE
    v_successful_count INT;
    v_consumed_count INT := 0;
    v_available_count INT := 0;
    v_milestone RECORD;
    v_already_claimed BOOLEAN;
    v_generated_coupon_code TEXT;
    v_coupon_id UUID;
    v_code_exists BOOLEAN;
BEGIN
    IF (NEW.status = 'completed' AND (OLD.status IS NULL OR OLD.status != 'completed')) THEN
        
        -- حساب إجمالي الدعوات الناجحة المكتملة للداعي
        SELECT COUNT(*) INTO v_successful_count 
        FROM public.referral_redemptions 
        WHERE referrer_owner_id = NEW.referrer_owner_id AND status = 'completed';

        -- حساب الدعوات المستهلكة مسبقاً
        SELECT COALESCE(SUM(m.target_count), 0) INTO v_consumed_count
        FROM public.owner_claimed_milestones cm
        JOIN public.referral_milestone_rewards m ON m.id = cm.milestone_id
        WHERE cm.owner_id = NEW.referrer_owner_id;

        -- الرصيد الفعلي المتاح من الدعوات
        v_available_count := GREATEST(0, v_successful_count - v_consumed_count);

        -- فحص المحطات غير المستلمة وترتيبها تصاعدياً
        FOR v_milestone IN 
            SELECT m.* FROM public.referral_milestone_rewards m
            WHERE m.is_active = TRUE 
              AND NOT EXISTS (
                  SELECT 1 FROM public.owner_claimed_milestones cm 
                  WHERE cm.owner_id = NEW.referrer_owner_id AND cm.milestone_id = m.id
              )
            ORDER BY m.target_count ASC
        LOOP
            -- إذا كان الرصيد المتاح يكفي لتحقيق هذا الهدف
            IF v_available_count >= v_milestone.target_count THEN
                v_coupon_id := NULL;
                v_generated_coupon_code := NULL;

                -- توليد كود كوبون فريد للداعي
                LOOP
                    v_generated_coupon_code := 'REF-' || upper(substr(md5(random()::text || clock_timestamp()::text), 1, 6));
                    SELECT EXISTS(SELECT 1 FROM public.coupons WHERE code = v_generated_coupon_code) INTO v_code_exists;
                    IF NOT v_code_exists THEN
                        EXIT;
                    END IF;
                END LOOP;
                
                -- إنشاء الكوبون الخاص للداعي في جدول الكوبونات (Private Coupon)
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
                    NOW() + INTERVAL '365 days',
                    'مكافأة تحقيق هدف دعوات الأطباء: ' || v_milestone.title
                ) RETURNING id INTO v_coupon_id;

                -- توثيق تحقيق المحطة في سجل owner_claimed_milestones
                INSERT INTO public.owner_claimed_milestones (
                    owner_id, 
                    milestone_id, 
                    invites_count_at_claim, 
                    reward_applied_details,
                    generated_coupon_id
                ) VALUES (
                    NEW.referrer_owner_id, 
                    v_milestone.id, 
                    v_available_count, 
                    jsonb_build_object(
                        'milestone_title', v_milestone.title,
                        'reward_type', v_milestone.referrer_reward_type,
                        'reward_value', v_milestone.referrer_reward_value,
                        'coupon_code', v_generated_coupon_code,
                        'target_consumed', v_milestone.target_count
                    ),
                    v_coupon_id
                );

                -- خصم نقاط/دعوات هذا الهدف من الرصيد المتاح للتحقق من الأهداف التالية في نفس الدورة
                v_available_count := v_available_count - v_milestone.target_count;
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
    v_has_paid_sub_before BOOLEAN := FALSE;
    v_initial_status referral_redemption_status := 'pending';
    v_trigger_event referral_reward_trigger_type := 'after_subscription';
    v_referee_coupon_id UUID := NULL;
    v_referee_coupon_code TEXT := NULL;
    v_referee_reward_type reward_types := 'discount_percent';
    v_referee_reward_value NUMERIC(10, 2) := 20.00;
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

    -- 2. التحقق من أن الطبيب المدعو لا يملك أي اشتراك مدفوع سابق (يسمح فقط بالتجريبي trail)
    SELECT EXISTS (
        SELECT 1 FROM public.subscriptions 
        WHERE owner_id = p_referee_owner_id 
          AND subscription_type != 'trail' 
          AND status IN ('active', 'expired')
    ) INTO v_has_paid_sub_before;

    IF v_has_paid_sub_before THEN
        RETURN jsonb_build_object(
            'success', false, 
            'message', 'عذراً، كود الدعوة متاح فقط للأطباء الجدد الذين لم يسبق لهم الاشتراك المدفوع'
        );
    END IF;

    -- 3. جلب التحدي الحالي النشط للداعي (أول تحدي لم يقم بتحصيله بعد)
    SELECT m.* INTO v_rule
    FROM public.referral_milestone_rewards m
    WHERE m.is_active = TRUE
      AND NOT EXISTS (
          SELECT 1 FROM public.owner_claimed_milestones cm 
          WHERE cm.owner_id = v_referrer_owner_id AND cm.milestone_id = m.id
      )
    ORDER BY m.target_count ASC
    LIMIT 1;

    -- في حال حصل الداعي جميع التحديات، نأخذ آخر تحدي كإعدادات افتراضية
    IF NOT FOUND THEN
        SELECT * INTO v_rule
        FROM public.referral_milestone_rewards
        WHERE is_active = TRUE
        ORDER BY target_count DESC
        LIMIT 1;
    END IF;

    IF FOUND THEN
        v_trigger_event := COALESCE(v_rule.trigger_event, 'after_subscription');
        IF v_rule.referee_reward_type IS NOT NULL THEN
            v_referee_reward_type := v_rule.referee_reward_type;
            v_referee_reward_value := COALESCE(v_rule.referee_reward_value, 20.00);
        END IF;
    END IF;

    -- 4. توليد كوبون ترحيبي خاص للمدعو دائماً (Private Coupon)
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
        v_referee_reward_type,
        v_referee_reward_value,
        1,
        NOW() + INTERVAL '90 days',
        'هدية ترحيبية لانضمامك عبر دعوة زميل'
    ) RETURNING id INTO v_referee_coupon_id;

    -- 5. تحديد الحالة الأولية حسب نوع الحدث (after_register يكتمل فوراً، أما after_subscription فيبقى pending حتى الاشتراك)
    IF v_trigger_event = 'after_register' THEN
        v_initial_status := 'completed';
    ELSE
        v_initial_status := 'pending';
    END IF;

    -- 6. إدراج سجل الدعوة في referral_redemptions
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
        'trigger_event', v_trigger_event,
        'reward_type', v_referee_reward_type,
        'reward_value', v_referee_reward_value,
        'referee_coupon_code', v_referee_coupon_code
    );
EXCEPTION
    WHEN unique_violation THEN
        RETURN jsonb_build_object('success', false, 'message', 'تم استخدام كود دعوة لهذا الحساب مسبقاً');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ==============================================================================
-- 5. Trigger: إتمام الإحالة تلقائياً عند بدء أول اشتراك (تجريبي Trial أو مدفوع)
-- ==============================================================================
CREATE OR REPLACE FUNCTION public.handle_subscription_referral_completion()
RETURNS TRIGGER AS $$
DECLARE
    v_has_previous_paid_sub BOOLEAN;
BEGIN
    -- التأكد أن الاشتراك أصبح نشطاً (في حالة INSERT جديد أو تحول الحالة إلى active)
    IF NEW.status = 'active' AND (TG_OP = 'INSERT' OR OLD.status IS NULL OR OLD.status != 'active') THEN
        
        -- التحقق من عدم وجود أي اشتراكات سابقة غير تجريبية
        SELECT EXISTS (
            SELECT 1 FROM public.subscriptions 
            WHERE owner_id = NEW.owner_id 
              AND id != NEW.id 
              AND subscription_type != 'trail' 
              AND status IN ('active', 'expired')
        ) INTO v_has_previous_paid_sub;

        -- إذا كان الطبيب مؤهلاً (أول اشتراك له أو تجريبي)
        IF NOT v_has_previous_paid_sub THEN
            UPDATE public.referral_redemptions
            SET status = 'completed',
                completed_at = NOW()
            WHERE referee_owner_id = NEW.owner_id 
              AND status = 'pending';
        END IF;

    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trg_subscription_referral_completion ON public.subscriptions;
CREATE TRIGGER trg_subscription_referral_completion
    AFTER INSERT OR UPDATE OF status ON public.subscriptions
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_subscription_referral_completion();


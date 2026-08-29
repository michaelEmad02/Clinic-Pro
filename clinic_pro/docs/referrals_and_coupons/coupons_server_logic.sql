-- ==============================================================================
-- Clinic Pro: Coupons Server Logic & RPCs (Supabase / PostgreSQL)
-- ==============================================================================

-- ==============================================================================
-- 1. RPC: Verify and Validate Coupon (فحص صلاحية الكوبون وحساب الخصم بالسيرفر)
-- يجلب السعر الأصلي للباقة من جدول plans بالسيرفر مباشرة لمنع التلاعب
-- ==============================================================================
CREATE OR REPLACE FUNCTION public.validate_coupon(
    p_code TEXT,
    p_owner_id UUID,
    p_plan_id UUID,
    p_billing_cycle TEXT DEFAULT 'monthly' -- 'monthly' | 'yearly' | 'lifetime'
)
RETURNS JSONB AS $$
DECLARE
    v_coupon RECORD;
    v_plan RECORD;
    v_has_active_sub BOOLEAN := FALSE;
    v_free_days INT := 0;
    v_original_amount DECIMAL := 0;
    v_discount DECIMAL := 0;
    v_final_amount DECIMAL := 0;
BEGIN
    -- 1. جلب سعر الباقة من جدول plans بالسيرفر مباشرة
    SELECT * INTO v_plan 
    FROM public.plans 
    WHERE id = p_plan_id;

    IF NOT FOUND THEN
        RETURN jsonb_build_object('is_valid', false, 'message', 'الباقة المختارة غير موجودة');
    END IF;

    -- تحديد السعر الأصلي حسب دورة الدفع (بالجنيه المصري EGP)
    IF p_billing_cycle = 'yearly' THEN
        v_original_amount := COALESCE(NULLIF(v_plan.yearly_price_egp, 0), v_plan.yearly_price, 0);
    ELSIF p_billing_cycle = 'lifetime' THEN
        v_original_amount := COALESCE(NULLIF(v_plan.lifetime_price_egp, 0), v_plan.lifetime_price, 0);
    ELSE
        v_original_amount := COALESCE(NULLIF(v_plan.monthly_price_egp, 0), v_plan.monthly_price, 0);
    END IF;

    -- 2. البحث عن الكوبون
    SELECT * INTO v_coupon 
    FROM public.coupons 
    WHERE UPPER(code) = UPPER(TRIM(p_code)) AND is_active = TRUE;

    IF NOT FOUND THEN
        RETURN jsonb_build_object('is_valid', false, 'message', 'كوبون الخصم غير صحيح أو غير مفعل');
    END IF;

    -- التحقق من تاريخ الصلاحية
    IF v_coupon.valid_until IS NOT NULL AND v_coupon.valid_until < NOW() THEN
        RETURN jsonb_build_object('is_valid', false, 'message', 'انتهت صلاحية هذا الكوبون');
    END IF;

    -- التحقق من الحد الأقصى للاستخدام العام
    IF v_coupon.max_uses IS NOT NULL AND v_coupon.used_count >= v_coupon.max_uses THEN
        RETURN jsonb_build_object('is_valid', false, 'message', 'تم استنفاد الحد الأقصى لاستخدام هذا الكوبون');
    END IF;

    -- التحقق من نطاق الكوبون (إذا كان مخصصاً لطبيب آخر)
    IF v_coupon.scope = 'private' AND v_coupon.owner_id != p_owner_id THEN
        RETURN jsonb_build_object('is_valid', false, 'message', 'هذا الكوبون غير');
    END IF;

    -- التحقق من الباقة المحددة
    IF v_coupon.plan_id IS NOT NULL AND NOT (p_plan_id::text = ANY(v_coupon.plan_id)) THEN
        RETURN jsonb_build_object('is_valid', false, 'message', 'هذا الكوبون غير متاح للباقة المختارة');
    END IF;

    -- التحقق من الاستخدام السابق للطبيب
    IF EXISTS (
        SELECT 1 FROM public.coupon_redemptions 
        WHERE coupon_id = v_coupon.id AND owner_id = p_owner_id
    ) THEN
        RETURN jsonb_build_object('is_valid', false, 'message', 'لقد قمت باستخدام هذا الكوبون مسبقاً');
    END IF;

    -- 3. فحص حالة اشتراك الطبيب الحالي
    SELECT EXISTS (
        SELECT 1 FROM public.subscriptions 
        WHERE owner_id = p_owner_id AND status = 'active' AND (end_at IS NULL OR end_at > NOW())
    ) INTO v_has_active_sub;

    -- 4. حساب الخصم أو الأيام المجانية بالسيرفر
    IF v_coupon.reword_type = 'discount_percent' THEN
        v_discount := (v_original_amount * v_coupon.value) / 100.0;
        v_final_amount := GREATEST(0, v_original_amount - v_discount);

    ELSIF v_coupon.reword_type = 'fixed_amount' THEN
        v_discount := LEAST(v_coupon.value, v_original_amount);
        v_final_amount := GREATEST(0, v_original_amount - v_discount);

    ELSIF v_coupon.reword_type = 'free_days' OR v_coupon.reword_type = 'free_month' THEN
        IF v_coupon.reword_type = 'free_month' THEN
            v_free_days := (v_coupon.value::INT) * 30;
        ELSE
            v_free_days := v_coupon.value::INT;
        END IF;

        -- إذا كان غير مشترك -> يصبح المبلغ النهائي 0 لتفعيل اشتراك مجاني بدون بوابة دفع
        IF NOT v_has_active_sub THEN
            v_discount := v_original_amount;
            v_final_amount := 0;
        ELSE
            -- إذا كان مشتركاً بالفعل -> المبلغ 0 للتمديد الفوري لاشتراكه الساري
            v_discount := 0;
            v_final_amount := 0;
        END IF;
    END IF;

    RETURN jsonb_build_object(
        'is_valid', true,
        'coupon_id', v_coupon.id,
        'code', v_coupon.code,
        'reward_type', v_coupon.reword_type,
        'reward_value', v_coupon.value,
        'free_days_granted', v_free_days,
        'has_active_subscription', v_has_active_sub,
        'original_amount', v_original_amount,
        'discount_amount', v_discount,
        'final_amount', v_final_amount,
        'description', v_coupon.description
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ==============================================================================
-- 2. RPC: Redeem Coupon (تطبيق الكوبون وتفعيل/تمديد الاشتراك تلقائياً - Zero Client Trust)
-- يدعم الاستدعاء المباشر (للكوبونات المجانية) والاستدعاء عبر الـ Webhook (بعد سداد الفيزا/المحفظة)
-- ==============================================================================
CREATE OR REPLACE FUNCTION public.redeem_coupon(
    p_coupon_id UUID,
    p_owner_id UUID,
    p_plan_id UUID DEFAULT NULL,
    p_billing_cycle TEXT DEFAULT 'monthly', -- 'monthly' | 'yearly' | 'lifetime'
    p_discount_amount DECIMAL DEFAULT NULL,
    p_transaction_id UUID DEFAULT NULL
)
RETURNS JSONB AS $$
DECLARE
    v_coupon RECORD;
    v_validation JSONB;
    v_free_days INT := 0;
    v_discount_amount DECIMAL := 0;
    v_original_price DECIMAL := 0;
    v_has_active_sub BOOLEAN := FALSE;
    v_sub_id UUID;
    v_inserted_tx_id UUID;
BEGIN
    -- 1. جلب الكوبون
    SELECT * INTO v_coupon 
    FROM public.coupons 
    WHERE id = p_coupon_id;

    IF NOT FOUND THEN
        RETURN jsonb_build_object('success', false, 'message', 'الكوبون غير موجود');
    END IF;

    -- 2. إذا تم تمرير p_plan_id (استدعاء مباشر لتفعيل اشتراك مجاني)
    IF p_plan_id IS NOT NULL THEN
        v_validation := public.validate_coupon(
            v_coupon.code, 
            p_owner_id, 
            p_plan_id, 
            p_billing_cycle
        );

        IF NOT (v_validation->>'is_valid')::BOOLEAN THEN
            RETURN jsonb_build_object(
                'success', false, 
                'message', COALESCE(v_validation->>'message', 'الكوبون غير صالح للاستخدام')
            );
        END IF;

        v_free_days := COALESCE((v_validation->>'free_days_granted')::INT, 0);
        v_discount_amount := COALESCE((v_validation->>'discount_amount')::DECIMAL, 0);
        v_has_active_sub := COALESCE((v_validation->>'has_active_subscription')::BOOLEAN, FALSE);

        -- حساب السعر الأصلي للخطة
        SELECT 
            CASE 
                WHEN p_billing_cycle = 'yearly' THEN COALESCE(yearly_price_egp, yearly_price, 0)
                WHEN p_billing_cycle = 'lifetime' THEN COALESCE(lifetime_price_egp, lifetime_price, 0)
                ELSE COALESCE(monthly_price_egp, monthly_price, 0)
            END INTO v_original_price
        FROM public.plans
        WHERE id = p_plan_id;

        -- معالجة تمديد أو تفعيل الاشتراك إذا كان الكوبون يمنح أياماً أو شهوراً مجانية
        IF v_free_days > 0 THEN
            IF v_has_active_sub THEN
                UPDATE public.subscriptions 
                SET end_at = GREATEST(COALESCE(end_at, NOW()), NOW()) + (v_free_days || ' days')::interval
                WHERE owner_id = p_owner_id AND status = 'active'
                RETURNING id INTO v_sub_id;
            ELSE
                INSERT INTO public.subscriptions (
                    owner_id,
                    plan_id,
                    subscription_type,
                    status,
                    payment_method,
                    started_at,
                    end_at,
                    created_at
                ) VALUES (
                    p_owner_id,
                    p_plan_id,
                    COALESCE(p_billing_cycle, 'monthly')::public.subscription_types,
                    'active',
                    'coupon',
                    NOW(),
                    NOW() + (v_free_days || ' days')::interval,
                    NOW()
                )
                RETURNING id INTO v_sub_id;
            END IF;

            -- ⭐ إضافة سجل في جدول المعاملات المالية payment_transactions بقيمة 0
            IF v_sub_id IS NOT NULL THEN
                INSERT INTO public.payment_transactions (
                    subscription_id,
                    owner_id,
                    gateway,
                    payment_method,
                    amount,
                    currency,
                    status,
                    metadata,
                    created_at
                ) VALUES (
                    v_sub_id,
                    p_owner_id,
                    'coupon',
                    'coupon',
                    0.00,
                    'EGP',
                    'success',
                    jsonb_build_object(
                        'coupon_id', v_coupon.id,
                        'coupon_code', v_coupon.code,
                        'subscription_type' , subscription_type,
                        'original_amount', COALESCE(v_original_price, 0),
                        'discount_amount', COALESCE(v_discount_amount, v_original_price, 0),
                        'final_amount', 0.00,
                        'free_days_granted', v_free_days
                    ),
                    NOW()
                )
                RETURNING id INTO v_inserted_tx_id;
            END IF;
        END IF;
    ELSE
        -- في حالة الاستدعاء من الـ Webhook (p_plan_id = NULL) نأخذ القيمة من البارامتر مباشرة
        v_discount_amount := COALESCE(p_discount_amount, 0);
    END IF;

    -- 3. تسجيل استهلاك الكوبون بالسيرفر في جدول coupon_redemptions
    INSERT INTO public.coupon_redemptions (
        coupon_id,
        owner_id,
        discount_amount,
        transaction_id
    ) VALUES (
        p_coupon_id,
        p_owner_id,
        v_discount_amount,
        p_transaction_id
    )
    ON CONFLICT (coupon_id, owner_id) DO NOTHING;

    -- 4. زيادة عداد الاستخدام للكوبون
    UPDATE public.coupons 
    SET used_count = COALESCE(used_count, 0) + 1 
    WHERE id = p_coupon_id;

    RETURN jsonb_build_object(
        'success', true, 
        'message', 'تم تسجيل استهلاك الكوبون بنجاح',
        'discount_amount', v_discount_amount,
        'free_days_granted', v_free_days
    );
EXCEPTION
    WHEN unique_violation THEN
        RETURN jsonb_build_object('success', false, 'message', 'تم استخدام هذا الكوبون مسبقاً');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ==============================================================================
-- 3. RPC: Get Available Coupons for Owner (كوبونات الطبيب المتاحة الخاصة به حصراً)
-- ==============================================================================
CREATE OR REPLACE FUNCTION public.get_available_coupons_for_owner(p_owner_id UUID)
RETURNS TABLE (
    coupon_id UUID,
    code TEXT,
    scope coupon_scope_type,
    reword_type reward_types,
    value DECIMAL,
    description TEXT,
    valid_until TIMESTAMPTZ
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c.id AS coupon_id,
        c.code,
        c.scope,
        c.reword_type,
        c.value,
        c.description,
        c.valid_until
    FROM public.coupons c
    WHERE c.is_active = TRUE
      AND c.scope = 'private'
      AND c.owner_id = p_owner_id
      AND (c.valid_until IS NULL OR c.valid_until > NOW())
      AND (c.max_uses IS NULL OR c.used_count < c.max_uses)
      AND NOT EXISTS (
          SELECT 1 FROM public.coupon_redemptions cr 
          WHERE cr.coupon_id = c.id AND cr.owner_id = p_owner_id
      )
    ORDER BY c.created_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- //////////////////////


-- 1. دالة تسجيل الكوبون تلقائياً عند نجاح أي عملية دفع
CREATE OR REPLACE FUNCTION public.handle_payment_success_coupon_redemption()
RETURNS TRIGGER AS $$
DECLARE
    v_coupon_id UUID;
    v_coupon_id_text TEXT;
    v_discount_amount DECIMAL := 0;
BEGIN
    -- عندما تتحول حالة المعاملة إلى success
    IF NEW.status = 'success' AND (OLD.status IS NULL OR OLD.status != 'success') THEN
        v_coupon_id_text := NEW.metadata->>'coupon_id';
        
        IF v_coupon_id_text IS NOT NULL AND v_coupon_id_text != '' AND v_coupon_id_text != 'null' THEN
            v_coupon_id := v_coupon_id_text::UUID;
            v_discount_amount := COALESCE((NEW.metadata->>'discount_amount')::DECIMAL, 0);

            -- تسجيل الاستهلاك في جدول coupon_redemptions وزيادة used_count في جدول coupons
            PERFORM public.redeem_coupon(
                p_coupon_id => v_coupon_id,
                p_owner_id => NEW.owner_id,
                p_plan_id => NULL,
                p_billing_cycle => COALESCE(NEW.metadata->>'subscription_type', 'monthly'),
                p_discount_amount => v_discount_amount,
                p_transaction_id => NEW.id
            );
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. تفعيل الـ Trigger على جدول معاملات الدفع payment_transactions
DROP TRIGGER IF EXISTS trg_payment_success_redeem_coupon ON public.payment_transactions;

CREATE TRIGGER trg_payment_success_redeem_coupon
AFTER INSERT OR UPDATE OF status ON public.payment_transactions
FOR EACH ROW
EXECUTE FUNCTION public.handle_payment_success_coupon_redemption();

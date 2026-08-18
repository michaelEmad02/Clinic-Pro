-- =================================================================
-- SQL RPC Functions مخصصة وخفيفة جداً لـ Owner Dashboard
-- مصممة للأداء الأقصى والسرعة الفائقة لخدمة شاشة المالك مباشرة
-- =================================================================

-- 1. RPC إحصائيات الملخص اليومية والمرضى
CREATE OR REPLACE FUNCTION get_owner_dashboard_stats_rpc(
    p_owner_id UUID
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_today DATE := CURRENT_DATE;
    v_today_net_revenue NUMERIC := 0;
    v_today_appts INT := 0;
    v_today_completed_appts INT := 0;
    v_total_patients INT := 0;
BEGIN
    -- أ) مواعيد اليوم المكتملة والإجمالية
    SELECT 
        COALESCE(COUNT(*), 0),
        COALESCE(COUNT(*) FILTER (WHERE a.status IN ('done', 'confirmed')), 0)
    INTO 
        v_today_appts,
        v_today_completed_appts
    FROM appointments a
    JOIN clinics c ON a.clinic_id = c.id
    WHERE c.owner_id = p_owner_id
      AND a.date = v_today;

    -- ب) محصل إيراد اليوم من الفواتير
    SELECT COALESCE(SUM(i.paid_amount), 0)
    INTO v_today_net_revenue
    FROM invoices i
    JOIN clinics c ON i.clinic_id = c.id
    WHERE c.owner_id = p_owner_id
      AND DATE(i.created_at) = v_today;

    -- ج) إجمالي المرضى المسجلين لعيادات المالك
    SELECT COALESCE(COUNT(*), 0)
    INTO v_total_patients
    FROM patients;

    RETURN jsonb_build_object(
        'today_net_revenue', v_today_net_revenue,
        'today_appointments', v_today_appts,
        'today_completed_appointments', v_today_completed_appts,
        'total_patients', v_total_patients
    );
END;
$$;


-- 2. RPC إيرادات الأسبوع للمخطط البياني (الأيام الـ 7 الأخيرة)
CREATE OR REPLACE FUNCTION get_owner_weekly_revenue_rpc(
    p_owner_id UUID
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_result JSONB;
BEGIN
    WITH daily_totals AS (
        SELECT 
            d.day_date AS day_date,
            COALESCE(SUM(i.paid_amount), 0) AS total_collected
        FROM (
            SELECT (CURRENT_DATE - (i || ' days')::INTERVAL)::DATE AS day_date
            FROM generate_series(6, 0, -1) AS i
        ) d
        LEFT JOIN clinics c ON c.owner_id = p_owner_id
        LEFT JOIN invoices i ON i.clinic_id = c.id AND DATE(i.created_at) = d.day_date
        GROUP BY d.day_date
    )
    SELECT jsonb_agg(
        jsonb_build_object(
            'day', dt.day_date,
            'collected', dt.total_collected
        )
        ORDER BY dt.day_date
    )
    INTO v_result
    FROM daily_totals dt;

    RETURN COALESCE(v_result, '[]'::jsonb);
END;
$$;


-- 3. RPC ملخص العيادات النشطة لعيادات المالك (يشمل عدد الأطباء وعدد المرضى)
CREATE OR REPLACE FUNCTION get_owner_clinics_overview_rpc(
    p_owner_id UUID
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_result JSONB;
BEGIN
    SELECT jsonb_agg(
        jsonb_build_object(
            'id', c.id,
            'name', c.name,
            'address', c.address,
            'is_active', c.is_active,
            'doctors_count', (
                SELECT COUNT(*) 
                FROM clinic_staff cs 
                WHERE cs.clinic_id = c.id AND cs.role = 'doctor'
            ),
        'patients_count', (
                SELECT COUNT(DISTINCT id)
                FROM patients p
                WHERE p.clinic_id = c.id
            )
        )
    )
    INTO v_result
    FROM clinics c
    WHERE c.owner_id = p_owner_id;

    RETURN COALESCE(v_result, '[]'::jsonb);
END;
$$;

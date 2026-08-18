/* ==============================================================================
   🔒 Subscriptions & Plans Feature Gate - Complete PostgreSQL RPC Functions
   ============================================================================== */

-- 🧹 0. تنظيف وحذف النسخ القديمة لحل التعارض (Clean Old Function Overloads)
DROP FUNCTION IF EXISTS check_subscription_feature_access(uuid, text);
DROP FUNCTION IF EXISTS get_financial_report_rpc;
DROP FUNCTION IF EXISTS get_appointments_report_rpc;
DROP FUNCTION IF EXISTS get_doctors_performance_report_rpc;
DROP FUNCTION IF EXISTS get_prescriptions_report_rpc;
DROP FUNCTION IF EXISTS get_patient_stats_report_rpc;
DROP FUNCTION IF EXISTS get_clinics_report_rpc;
DROP FUNCTION IF EXISTS verify_print_report_access_rpc;


/* ------------------------------------------------------------------------------
   1. دالة الفحص المركزية للصلاحية (Centralized Security Access Check)
   ------------------------------------------------------------------------------ */
CREATE OR REPLACE FUNCTION check_subscription_feature_access(
  p_owner_id uuid,
  p_feature_key text
) RETURNS boolean AS $$
DECLARE
  v_is_enabled boolean := false;
  v_actual_owner_id uuid := p_owner_id;
BEGIN
  IF p_owner_id IS NULL THEN
    RETURN true;
  END IF;

  -- إذا لم يكن p_owner_id مالكاً مباشراً (مثل طبيب أو سكرتير)، نجلب مالك أول عيادة ينتمي إليها
  IF NOT EXISTS (SELECT 1 FROM subscriptions WHERE owner_id = p_owner_id) THEN
    SELECT c.owner_id INTO v_actual_owner_id
    FROM clinic_staff cs
    JOIN clinics c ON c.id = cs.clinic_id
    WHERE cs.user_id = p_owner_id
    LIMIT 1;

    IF v_actual_owner_id IS NULL THEN
      SELECT owner_id INTO v_actual_owner_id FROM clinics WHERE owner_id = p_owner_id LIMIT 1;
    END IF;
  END IF;

  IF v_actual_owner_id IS NULL THEN
    RETURN true;
  END IF;

  SELECT (pf.features -> p_feature_key ->> 'value')::boolean INTO v_is_enabled
  FROM subscriptions s
  JOIN plans_features pf ON pf.plan_id = s.plan_id
  WHERE s.owner_id = v_actual_owner_id
    AND s.status = 'active'
    AND (s.end_at IS NULL OR s.end_at > now())
  ORDER BY s.created_at DESC
  LIMIT 1;

  RETURN COALESCE(v_is_enabled, false);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


/* ------------------------------------------------------------------------------
   2. تقرير مقارنة وأداء عيادات المالك الشامل (Clinics Overview Report RPC)
   Target Model: ClinicReportEntity / fetchClinicReport
   ------------------------------------------------------------------------------ */
CREATE OR REPLACE FUNCTION get_clinics_report_rpc(
  p_owner_id uuid DEFAULT auth.uid()
) RETURNS jsonb AS $$
DECLARE
  v_total_active int := 0;
  v_total_exp_rev double precision := 0.0;
  v_total_col_amt double precision := 0.0;
  v_total_exp double precision := 0.0;
  v_total_net double precision := 0.0;
  v_total_appts_today int := 0;
  v_total_docs int := 0;
  v_clinics_list jsonb := '[]'::jsonb;
BEGIN
  IF p_owner_id IS NOT NULL AND NOT check_subscription_feature_access(p_owner_id, 'clinics_reports') THEN
    RAISE EXCEPTION 'FEATURE_NOT_ALLOWED: clinics_reports' USING ERRCODE = '40301';
  END IF;

  SELECT 
    COALESCE(COUNT(*) FILTER (WHERE c.is_active = true), 0),
    COALESCE(jsonb_agg(
      jsonb_build_object(
        'id', c.id,
        'name', c.name,
        'is_active', COALESCE(c.is_active, true),
        'expected_revenue', COALESCE(c_data.expected_rev, 0.0),
        'collected_amount', COALESCE(c_data.collected_amt, 0.0),
        'expenses', COALESCE(c_data.exp_amt, 0.0),
        'net_profit', COALESCE(c_data.collected_amt, 0.0) - COALESCE(c_data.exp_amt, 0.0),
        'day_appointments', COALESCE(c_data.appts_today, 0),
        'finished_appointments', COALESCE(c_data.appts_finished, 0),
        'number_of_doctors', COALESCE(c_data.doc_count, 0)
      )
    ), '[]'::jsonb)
  INTO v_total_active, v_clinics_list
  FROM clinics c
  LEFT JOIN LATERAL (
    SELECT 
      SUM(a.price) as expected_rev,
      (SELECT SUM(inv.paid_amount) FROM invoices inv WHERE inv.clinic_id = c.id) as collected_amt,
      (SELECT SUM(e.amount) FROM expenses e WHERE e.clinic_id = c.id) as exp_amt,
      COUNT(a.id) FILTER (WHERE a.date::date = CURRENT_DATE) as appts_today,
      COUNT(a.id) FILTER (WHERE a.status IN ('done', 'completed', 'confirmed')) as appts_finished,
      (SELECT COUNT(*) FROM clinic_staff cs WHERE cs.clinic_id = c.id AND cs.role = 'doctor') as doc_count
    FROM appointments a
    WHERE a.clinic_id = c.id
  ) c_data ON true
  WHERE c.owner_id = p_owner_id;

  SELECT 
    COALESCE(SUM((item->>'expected_revenue')::double precision), 0.0),
    COALESCE(SUM((item->>'collected_amount')::double precision), 0.0),
    COALESCE(SUM((item->>'expenses')::double precision), 0.0),
    COALESCE(SUM((item->>'net_profit')::double precision), 0.0),
    COALESCE(SUM((item->>'day_appointments')::int), 0),
    COALESCE(SUM((item->>'number_of_doctors')::int), 0)
  INTO v_total_exp_rev, v_total_col_amt, v_total_exp, v_total_net, v_total_appts_today, v_total_docs
  FROM jsonb_array_elements(v_clinics_list) AS item;

  RETURN jsonb_build_object(
    'total_active_clinics', v_total_active,
    'total_expected_revenue', v_total_exp_rev,
    'total_collected_amount', v_total_col_amt,
    'total_expenses', v_total_exp,
    'total_net_profit', v_total_net,
    'total_appointments_today', v_total_appts_today,
    'total_doctors', v_total_docs,
    'clinics', v_clinics_list
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


/* ------------------------------------------------------------------------------
   3. تقرير المخصصة المالية والإيرادات المصحح (Financial Report RPC)
   Target Model: RevenueSummaryModel.fromMap
   ------------------------------------------------------------------------------ */
CREATE OR REPLACE FUNCTION get_financial_report_rpc(
  p_clinic_id uuid DEFAULT NULL,
  p_doctor_id uuid DEFAULT NULL,
  p_start_date timestamptz DEFAULT NULL,
  p_end_date timestamptz DEFAULT NULL,
  p_owner_id uuid DEFAULT auth.uid()
) RETURNS jsonb AS $$
DECLARE
  v_total_revenue double precision := 0.0;
  v_collected double precision := 0.0;
  v_total_expenses double precision := 0.0;
  v_pending double precision := 0.0;
  v_curr_month_rev double precision := 0.0;
  v_prev_month_rev double precision := 0.0;
  v_curr_month_exp double precision := 0.0;
  v_prev_month_exp double precision := 0.0;
  v_revenue_change text := '0%';
  v_expenses_change text := '0%';
  v_expenses_breakdown jsonb := '[]'::jsonb;
  v_chart jsonb := '[]'::jsonb;
BEGIN
  IF p_owner_id IS NOT NULL AND NOT check_subscription_feature_access(p_owner_id, 'clinics_reports') THEN
    RAISE EXCEPTION 'FEATURE_NOT_ALLOWED: financial_reports' USING ERRCODE = '40301';
  END IF;

  SELECT COALESCE(SUM(price), 0.0) INTO v_total_revenue
  FROM appointments
  WHERE (p_clinic_id IS NULL OR clinic_id = p_clinic_id)
    AND (p_doctor_id IS NULL OR doctor_id = p_doctor_id)
    AND (p_start_date IS NULL OR created_at >= p_start_date)
    AND (p_end_date IS NULL OR created_at <= p_end_date);

  SELECT 
    COALESCE(SUM(paid_amount), 0.0),
    COALESCE(SUM(GREATEST(total_amount - paid_amount, 0.0)), 0.0)
  INTO v_collected, v_pending
  FROM invoices
  WHERE (p_clinic_id IS NULL OR clinic_id = p_clinic_id)
    AND (p_start_date IS NULL OR created_at >= p_start_date)
    AND (p_end_date IS NULL OR created_at <= p_end_date);

  IF p_doctor_id IS NULL THEN
    SELECT COALESCE(SUM(amount), 0.0) INTO v_total_expenses
    FROM expenses
    WHERE (p_clinic_id IS NULL OR clinic_id = p_clinic_id)
      AND (p_start_date IS NULL OR created_at >= p_start_date)
      AND (p_end_date IS NULL OR created_at <= p_end_date);

    SELECT COALESCE(jsonb_agg(eb), '[]'::jsonb) INTO v_expenses_breakdown
    FROM (
      SELECT 
        COALESCE(ec.name, 'أخرى') as category,
        SUM(e.amount)::double precision as amount,
        CASE WHEN v_total_expenses > 0 
             THEN ROUND(((SUM(e.amount)::double precision / v_total_expenses) * 100)::numeric, 2)
             ELSE 0 
        END as percentage
      FROM expenses e
      LEFT JOIN expense_categories ec ON ec.id = e.category_id
      WHERE (p_clinic_id IS NULL OR e.clinic_id = p_clinic_id)
        AND (p_start_date IS NULL OR e.created_at >= p_start_date)
        AND (p_end_date IS NULL OR e.created_at <= p_end_date)
      GROUP BY COALESCE(ec.name, 'أخرى')
    ) eb;
  END IF;

  -- 📈 حساب نسبة التغير في الإيرادات عن الشهر السابق
  SELECT COALESCE(SUM(paid_amount), 0.0) INTO v_curr_month_rev
  FROM invoices WHERE DATE_TRUNC('month', created_at) = DATE_TRUNC('month', now());

  SELECT COALESCE(SUM(paid_amount), 0.0) INTO v_prev_month_rev
  FROM invoices WHERE DATE_TRUNC('month', created_at) = DATE_TRUNC('month', now() - INTERVAL '1 month');

  IF v_prev_month_rev > 0 THEN
    v_revenue_change := ROUND(((v_curr_month_rev - v_prev_month_rev) / v_prev_month_rev * 100)::numeric, 0)::text || '%';
  ELSIF v_curr_month_rev > 0 THEN
    v_revenue_change := '+100%';
  END IF;

  -- 📉 حساب نسبة التغير في المصروفات عن الشهر السابق
  SELECT COALESCE(SUM(amount), 0.0) INTO v_curr_month_exp
  FROM expenses 
  WHERE DATE_TRUNC('month', created_at) = DATE_TRUNC('month', now())
    AND (p_clinic_id IS NULL OR clinic_id = p_clinic_id);

  SELECT COALESCE(SUM(amount), 0.0) INTO v_prev_month_exp
  FROM expenses 
  WHERE DATE_TRUNC('month', created_at) = DATE_TRUNC('month', now() - INTERVAL '1 month')
    AND (p_clinic_id IS NULL OR clinic_id = p_clinic_id);

  IF v_prev_month_exp > 0 THEN
    v_expenses_change := ROUND(((v_curr_month_exp - v_prev_month_exp) / v_prev_month_exp * 100)::numeric, 0)::text || '%';
  ELSIF v_curr_month_exp > 0 THEN
    v_expenses_change := '+100%';
  END IF;

  -- 📊 حساب الرسم البياني المالي لأسابيع الشهر الحالي الـ 4
  SELECT COALESCE(jsonb_agg(
    jsonb_build_object(
      'week', 'الأسبوع ' || w.week_num,
      'revenue', COALESCE(w_rev.rev, 0.0),
      'collected', COALESCE(w_inv.col, 0.0),
      'expenses', COALESCE(w_exp.exp, 0.0)
    )
    ORDER BY w.week_num
  ), '[]'::jsonb) INTO v_chart
  FROM generate_series(1, 4) AS w(week_num)
  LEFT JOIN (
    SELECT 
      CASE 
        WHEN EXTRACT(DAY FROM created_at) <= 7 THEN 1
        WHEN EXTRACT(DAY FROM created_at) <= 14 THEN 2
        WHEN EXTRACT(DAY FROM created_at) <= 21 THEN 3
        ELSE 4
      END as week_num,
      SUM(price)::double precision as rev
    FROM appointments
    WHERE DATE_TRUNC('month', created_at) = DATE_TRUNC('month', now())
      AND (p_clinic_id IS NULL OR clinic_id = p_clinic_id)
      AND (p_doctor_id IS NULL OR doctor_id = p_doctor_id)
    GROUP BY 1
  ) w_rev ON w_rev.week_num = w.week_num
  LEFT JOIN (
    SELECT 
      CASE 
        WHEN EXTRACT(DAY FROM created_at) <= 7 THEN 1
        WHEN EXTRACT(DAY FROM created_at) <= 14 THEN 2
        WHEN EXTRACT(DAY FROM created_at) <= 21 THEN 3
        ELSE 4
      END as week_num,
      SUM(paid_amount)::double precision as col
    FROM invoices
    WHERE DATE_TRUNC('month', created_at) = DATE_TRUNC('month', now())
      AND (p_clinic_id IS NULL OR clinic_id = p_clinic_id)
    GROUP BY 1
  ) w_inv ON w_inv.week_num = w.week_num
  LEFT JOIN (
    SELECT 
      CASE 
        WHEN EXTRACT(DAY FROM created_at) <= 7 THEN 1
        WHEN EXTRACT(DAY FROM created_at) <= 14 THEN 2
        WHEN EXTRACT(DAY FROM created_at) <= 21 THEN 3
        ELSE 4
      END as week_num,
      SUM(amount)::double precision as exp
    FROM expenses
    WHERE DATE_TRUNC('month', created_at) = DATE_TRUNC('month', now())
      AND (p_clinic_id IS NULL OR clinic_id = p_clinic_id)
    GROUP BY 1
  ) w_exp ON w_exp.week_num = w.week_num;

  RETURN jsonb_build_object(
    'total_revenue', v_total_revenue,
    'collected_amount', v_collected,
    'total_expenses', v_total_expenses,
    'net_profit', v_collected - v_total_expenses,
    'pending_amount', v_pending,
    'revenue_change', v_revenue_change,
    'expenses_change', v_expenses_change,
    'chart', v_chart,
    'expenses_breakdown', v_expenses_breakdown
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


/* ------------------------------------------------------------------------------
   4. تقرير المواعيد المصحح (Appointments Report RPC)
   Feature Key: 'appointments_reports'
   ------------------------------------------------------------------------------ */
CREATE OR REPLACE FUNCTION get_appointments_report_rpc(
  p_clinic_id uuid DEFAULT NULL,
  p_doctor_id uuid DEFAULT NULL,
  p_start_date timestamptz DEFAULT NULL,
  p_end_date timestamptz DEFAULT NULL,
  p_owner_id uuid DEFAULT auth.uid()
) RETURNS jsonb AS $$
DECLARE
  v_total int := 0;
  v_completed int := 0;
  v_cancelled int := 0;
  v_no_show int := 0;
  v_urgent int := 0;
  v_attendance_rate double precision := 0.0;
  v_no_show_rate double precision := 0.0;
  v_urgent_percentage double precision := 0.0;
  v_avg_wait_time int := 0;
  v_status_breakdown jsonb := '{}'::jsonb;
  v_peak_hours jsonb := '[]'::jsonb;
  v_peak_days jsonb := '[]'::jsonb;
  v_by_type jsonb := '[]'::jsonb;
BEGIN
  IF p_owner_id IS NOT NULL AND NOT check_subscription_feature_access(p_owner_id, 'appointments_reports') THEN
    RAISE EXCEPTION 'FEATURE_NOT_ALLOWED: appointments_reports' USING ERRCODE = '40301';
  END IF;

  SELECT 
    COUNT(*),
    COUNT(*) FILTER (WHERE status IN ('confirmed', 'done', 'in_progress')),
    COUNT(*) FILTER (WHERE status = 'cancelled'),
    COUNT(*) FILTER (WHERE status = 'scheduled' AND date::date < CURRENT_DATE),
    COUNT(*) FILTER (WHERE is_urgent = true),
    COALESCE(AVG(EXTRACT(EPOCH FROM (called_at - arrived_at)) / 60) FILTER (WHERE arrived_at IS NOT NULL AND called_at IS NOT NULL), 0)::int
  INTO v_total, v_completed, v_cancelled, v_no_show, v_urgent, v_avg_wait_time
  FROM appointments
  WHERE (p_clinic_id IS NULL OR clinic_id = p_clinic_id)
    AND (p_doctor_id IS NULL OR doctor_id = p_doctor_id)
    AND (p_start_date IS NULL OR created_at >= p_start_date)
    AND (p_end_date IS NULL OR created_at <= p_end_date);

  IF v_total > 0 THEN
    v_attendance_rate := ROUND(((v_completed::double precision / v_total::double precision) * 100)::numeric, 2);
    v_no_show_rate := ROUND(((v_no_show::double precision / v_total::double precision) * 100)::numeric, 2);
    v_urgent_percentage := ROUND(((v_urgent::double precision / v_total::double precision) * 100)::numeric, 2);
  END IF;

  SELECT COALESCE(jsonb_object_agg(status, count), '{}'::jsonb) INTO v_status_breakdown
  FROM (
    SELECT status, COUNT(*)::int as count
    FROM appointments
    WHERE (p_clinic_id IS NULL OR clinic_id = p_clinic_id)
      AND (p_doctor_id IS NULL OR doctor_id = p_doctor_id)
      AND (p_start_date IS NULL OR created_at >= p_start_date)
      AND (p_end_date IS NULL OR created_at <= p_end_date)
    GROUP BY status
  ) sb;

  SELECT COALESCE(jsonb_agg(ph), '[]'::jsonb) INTO v_peak_hours
  FROM (
    SELECT EXTRACT(HOUR FROM created_at)::int as hour, COUNT(*)::int as count
    FROM appointments
    WHERE (p_clinic_id IS NULL OR clinic_id = p_clinic_id)
      AND (p_doctor_id IS NULL OR doctor_id = p_doctor_id)
      AND (p_start_date IS NULL OR created_at >= p_start_date)
      AND (p_end_date IS NULL OR created_at <= p_end_date)
    GROUP BY 1 ORDER BY count DESC LIMIT 5
  ) ph;

  SELECT COALESCE(jsonb_agg(pd), '[]'::jsonb) INTO v_peak_days
  FROM (
    SELECT TO_CHAR(created_at, 'Day') as day, COUNT(*)::int as count
    FROM appointments
    WHERE (p_clinic_id IS NULL OR clinic_id = p_clinic_id)
      AND (p_doctor_id IS NULL OR doctor_id = p_doctor_id)
      AND (p_start_date IS NULL OR created_at >= p_start_date)
      AND (p_end_date IS NULL OR created_at <= p_end_date)
    GROUP BY 1 ORDER BY count DESC
  ) pd;

  SELECT COALESCE(jsonb_agg(bt), '[]'::jsonb) INTO v_by_type
  FROM (
    SELECT 
      COALESCE(at.name, 'كشف عادي') as name, 
      COUNT(*)::int as count
    FROM appointments a
    LEFT JOIN doctor_appointment_types dat ON dat.id = a.type_id
    LEFT JOIN appointment_types at ON at.id = dat.appointment_type_id
    WHERE (p_clinic_id IS NULL OR a.clinic_id = p_clinic_id)
      AND (p_doctor_id IS NULL OR a.doctor_id = p_doctor_id)
      AND (p_start_date IS NULL OR a.created_at >= p_start_date)
      AND (p_end_date IS NULL OR a.created_at <= p_end_date)
    GROUP BY COALESCE(at.name, 'كشف عادي')
  ) bt;

  RETURN jsonb_build_object(
    'total', v_total,
    'completed', v_completed,
    'cancelled', v_cancelled,
    'attendance_rate', v_attendance_rate,
    'avg_wait_time', v_avg_wait_time,
    'urgent_count', v_urgent,
    'urgent_percentage', v_urgent_percentage,
    'no_show_count', v_no_show,
    'no_show_rate', v_no_show_rate,
    'status_breakdown', v_status_breakdown,
    'peak_hours', v_peak_hours,
    'peak_days', v_peak_days,
    'by_type', v_by_type
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


/* ------------------------------------------------------------------------------
   5. تقرير أداء الأطباء المصحح (Doctors Performance Report RPC - Deduplicated)
   Feature Key: 'doctors_performance_reports'
   ------------------------------------------------------------------------------ */
CREATE OR REPLACE FUNCTION get_doctors_performance_report_rpc(
  p_clinic_id uuid DEFAULT NULL,
  p_start_date timestamptz DEFAULT NULL,
  p_end_date timestamptz DEFAULT NULL,
  p_owner_id uuid DEFAULT auth.uid()
) RETURNS jsonb AS $$
DECLARE
  v_total_revenue double precision := 0.0;
  v_result jsonb := '[]'::jsonb;
BEGIN
  IF p_owner_id IS NOT NULL AND NOT check_subscription_feature_access(p_owner_id, 'doctors_performance_reports') THEN
    RAISE EXCEPTION 'FEATURE_NOT_ALLOWED: doctors_performance_reports' USING ERRCODE = '40301';
  END IF;

  SELECT COALESCE(SUM(COALESCE(inv.paid_amount, a.price, 0.0)), 0.0) INTO v_total_revenue
  FROM appointments a
  LEFT JOIN invoices inv ON inv.source_id = a.id
  WHERE a.status != 'cancelled'
    AND (p_clinic_id IS NULL OR a.clinic_id = p_clinic_id)
    AND (p_start_date IS NULL OR a.created_at >= p_start_date)
    AND (p_end_date IS NULL OR a.created_at <= p_end_date);

  SELECT COALESCE(jsonb_agg(doc_item), '[]'::jsonb) INTO v_result
  FROM (
    SELECT 
      u.id as doctor_id,
      COALESCE(u.name, 'طبيب غير معروف') as doctor_name,
      COUNT(DISTINCT a.id)::int as visit_count,
      COALESCE(SUM(COALESCE(inv.paid_amount, a.price, 0.0)), 0.0)::double precision as revenue,
      CASE 
        WHEN v_total_revenue > 0 
        THEN ROUND(((COALESCE(SUM(COALESCE(inv.paid_amount, a.price, 0.0)), 0.0) / v_total_revenue) * 100)::numeric, 0)::int 
        ELSE 0 
      END as rating,
      CASE WHEN COALESCE(SUM(COALESCE(inv.paid_amount, a.price, 0.0)), 0.0) > 0 THEN 'up' ELSE 'stable' END as trend,
      u.image_url as avatar_url
    FROM (
      SELECT DISTINCT user_id 
      FROM clinic_staff 
      WHERE role = 'doctor' 
        AND (p_clinic_id IS NULL OR clinic_id = p_clinic_id)
    ) docs
    JOIN users u ON u.id = docs.user_id
    LEFT JOIN appointments a ON a.doctor_id = u.id 
      AND a.status != 'cancelled'
      AND (p_clinic_id IS NULL OR a.clinic_id = p_clinic_id)
      AND (p_start_date IS NULL OR a.created_at >= p_start_date)
      AND (p_end_date IS NULL OR a.created_at <= p_end_date)
    LEFT JOIN invoices inv ON inv.source_id = a.id
    GROUP BY u.id, u.name, u.image_url
    ORDER BY revenue DESC
  ) doc_item;

  RETURN v_result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


/* ------------------------------------------------------------------------------
   6. تقرير الأدوية والروشتات المصحح الشامل بالكامل (Prescriptions & Drugs Report RPC)
   Target Model: DrugStatsEntity / fetchDrugStats
   Feature Key: 'prescriptions_reports'
   ------------------------------------------------------------------------------ */
CREATE OR REPLACE FUNCTION get_prescriptions_report_rpc(
  p_clinic_id uuid DEFAULT NULL,
  p_doctor_id uuid DEFAULT NULL,
  p_start_date timestamptz DEFAULT NULL,
  p_end_date timestamptz DEFAULT NULL,
  p_owner_id uuid DEFAULT auth.uid()
) RETURNS jsonb AS $$
DECLARE
  v_total_rx int := 0;
  v_total_items int := 0;
  v_avg_drugs double precision := 0.0;
  v_prn_count int := 0;
  v_prn_percentage double precision := 0.0;
  v_top_diagnosis_name text := '';
  v_categories jsonb := '[]'::jsonb;
  v_top_drugs jsonb := '[]'::jsonb;
  v_top_diagnoses jsonb := '[]'::jsonb;
  v_chronic_drugs jsonb := '[]'::jsonb;
  v_template_stats jsonb := '[]'::jsonb;
  v_monthly_trend jsonb := '[]'::jsonb;
  v_common_dosages jsonb := '[]'::jsonb;
  v_drug_diag_links jsonb := '[]'::jsonb;
  v_repeated_drugs jsonb := '[]'::jsonb;
  v_patient_reach jsonb := '[]'::jsonb;
BEGIN
  IF p_owner_id IS NOT NULL AND NOT check_subscription_feature_access(p_owner_id, 'prescriptions_reports') THEN
    RAISE EXCEPTION 'FEATURE_NOT_ALLOWED: prescriptions_reports' USING ERRCODE = '40301';
  END IF;

  -- 1. حساب الإجماليات
  SELECT COUNT(DISTINCT p.id) INTO v_total_rx
  FROM prescriptions p
  WHERE (p_clinic_id IS NULL OR p.clinic_id = p_clinic_id)
    AND (p_doctor_id IS NULL OR p.doctor_id = p_doctor_id)
    AND (p_start_date IS NULL OR p.created_at >= p_start_date)
    AND (p_end_date IS NULL OR p.created_at <= p_end_date);

  SELECT COUNT(pi.id), COUNT(pi.id) FILTER (WHERE pi.is_prn = true)
  INTO v_total_items, v_prn_count
  FROM prescription_items pi
  JOIN prescriptions p ON p.id = pi.prescription_id
  WHERE (p_clinic_id IS NULL OR p.clinic_id = p_clinic_id)
    AND (p_doctor_id IS NULL OR p.doctor_id = p_doctor_id)
    AND (p_start_date IS NULL OR p.created_at >= p_start_date)
    AND (p_end_date IS NULL OR p.created_at <= p_end_date);

  IF v_total_rx > 0 THEN
    v_avg_drugs := ROUND((v_total_items::double precision / v_total_rx::double precision)::numeric, 2);
  END IF;

  IF v_total_items > 0 THEN
    v_prn_percentage := ROUND(((v_prn_count::double precision / v_total_items::double precision) * 100)::numeric, 2);
  END IF;

  -- 2. التشخيصات
  SELECT COALESCE(jsonb_agg(td), '[]'::jsonb) INTO v_top_diagnoses
  FROM (
    SELECT 
      COALESCE(TRIM(p.diagnosis), 'تشخيص عام') as name,
      COUNT(*)::int as count,
      CASE WHEN v_total_rx > 0 
           THEN ROUND(((COUNT(*)::double precision / v_total_rx::double precision) * 100)::numeric, 2)
           ELSE 0 
      END as percentage
    FROM prescriptions p
    WHERE (p_clinic_id IS NULL OR p.clinic_id = p_clinic_id)
      AND (p_doctor_id IS NULL OR p.doctor_id = p_doctor_id)
      AND (p_start_date IS NULL OR p.created_at >= p_start_date)
      AND (p_end_date IS NULL OR p.created_at <= p_end_date)
      AND p.diagnosis IS NOT NULL AND TRIM(p.diagnosis) != ''
    GROUP BY TRIM(p.diagnosis)
    ORDER BY count DESC
  ) td;

  SELECT COALESCE(v_top_diagnoses->0->>'name', '') INTO v_top_diagnosis_name;

  -- 3. الفئات والأدوية
  SELECT COALESCE(jsonb_agg(c), '[]'::jsonb) INTO v_categories
  FROM (
    SELECT 
      COALESCE(d.category, 'عام') as category,
      COUNT(*)::int as count,
      CASE WHEN v_total_items > 0 
           THEN ROUND(((COUNT(*)::double precision / v_total_items::double precision) * 100)::numeric, 2)
           ELSE 0 
      END as percentage
    FROM prescription_items pi
    JOIN prescriptions p ON p.id = pi.prescription_id
    LEFT JOIN drugs d ON d.id = pi.drug_id
    WHERE (p_clinic_id IS NULL OR p.clinic_id = p_clinic_id)
      AND (p_doctor_id IS NULL OR p.doctor_id = p_doctor_id)
      AND (p_start_date IS NULL OR p.created_at >= p_start_date)
      AND (p_end_date IS NULL OR p.created_at <= p_end_date)
    GROUP BY COALESCE(d.category, 'عام')
    ORDER BY count DESC
  ) c;

  SELECT COALESCE(jsonb_agg(drg), '[]'::jsonb) INTO v_top_drugs
  FROM (
    SELECT 
      COALESCE(d.trade_name, 'دواء غير محدد') as name,
      d.generic_name as generic_name,
      COUNT(*)::int as count,
      CASE WHEN v_total_items > 0 
           THEN ROUND(((COUNT(*)::double precision / v_total_items::double precision) * 100)::numeric, 2)
           ELSE 0 
      END as percentage
    FROM prescription_items pi
    JOIN prescriptions p ON p.id = pi.prescription_id
    LEFT JOIN drugs d ON d.id = pi.drug_id
    WHERE (p_clinic_id IS NULL OR p.clinic_id = p_clinic_id)
      AND (p_doctor_id IS NULL OR p.doctor_id = p_doctor_id)
      AND (p_start_date IS NULL OR p.created_at >= p_start_date)
      AND (p_end_date IS NULL OR p.created_at <= p_end_date)
    GROUP BY d.trade_name, d.generic_name
    ORDER BY count DESC LIMIT 10
  ) drg;

  SELECT COALESCE(jsonb_agg(cd), '[]'::jsonb) INTO v_chronic_drugs
  FROM (
    SELECT 
      COALESCE(d.trade_name, 'دواء غير محدد') as name,
      COUNT(*)::int as count,
      CASE WHEN v_total_items > 0 
           THEN ROUND(((COUNT(*)::double precision / v_total_items::double precision) * 100)::numeric, 2)
           ELSE 0 
      END as percentage
    FROM prescription_items pi
    JOIN prescriptions p ON p.id = pi.prescription_id
    LEFT JOIN drugs d ON d.id = pi.drug_id
    WHERE pi.duration = 0
      AND (p_clinic_id IS NULL OR p.clinic_id = p_clinic_id)
      AND (p_doctor_id IS NULL OR p.doctor_id = p_doctor_id)
      AND (p_start_date IS NULL OR p.created_at >= p_start_date)
      AND (p_end_date IS NULL OR p.created_at <= p_end_date)
    GROUP BY d.trade_name
    ORDER BY count DESC
  ) cd;

  -- 4. إحصائيات القوالب (Template Stats)
  SELECT COALESCE(jsonb_agg(ts), '[]'::jsonb) INTO v_template_stats
  FROM (
    SELECT 
      pt.id,
      COALESCE(pt.name, 'قالب') as name,
      COALESCE(pt.user_count, 0)::int as user_count,
      CASE WHEN (SELECT SUM(user_count) FROM prescription_templates) > 0
           THEN ROUND(((COALESCE(pt.user_count, 0)::double precision / (SELECT SUM(user_count) FROM prescription_templates)::double precision) * 100)::numeric, 2)
           ELSE 0
      END as percentage
    FROM prescription_templates pt
    WHERE (p_doctor_id IS NULL OR pt.doctor_id = p_doctor_id)
    ORDER BY pt.user_count DESC
  ) ts;

  -- 5. الاتجاه الشهري (Monthly Trend - 6 Months)
  SELECT COALESCE(jsonb_agg(mt), '[]'::jsonb) INTO v_monthly_trend
  FROM (
    SELECT 
      TO_CHAR(m.m_date, 'YYYY-MM') as month,
      COUNT(DISTINCT p.id)::int as count,
      CASE WHEN COUNT(DISTINCT p.id) > 0 
           THEN ROUND((COUNT(pi.id)::double precision / COUNT(DISTINCT p.id)::double precision)::numeric, 2)
           ELSE 0 
      END as avg_drugs
    FROM generate_series(now() - INTERVAL '5 months', now(), INTERVAL '1 month') AS m(m_date)
    LEFT JOIN prescriptions p ON DATE_TRUNC('month', p.created_at) = DATE_TRUNC('month', m.m_date)
      AND (p_clinic_id IS NULL OR p.clinic_id = p_clinic_id)
      AND (p_doctor_id IS NULL OR p.doctor_id = p_doctor_id)
    LEFT JOIN prescription_items pi ON pi.prescription_id = p.id
    GROUP BY 1
    ORDER BY 1 ASC
  ) mt;

  -- 6. أنماط الجرعات (Common Dosages)
  SELECT COALESCE(jsonb_agg(cdos), '[]'::jsonb) INTO v_common_dosages
  FROM (
    SELECT 
      CASE 
        WHEN pi.is_prn = true THEN 'عند اللزوم (PRN)'
        ELSE COALESCE(pi.frequency::text, '1') || ' مرات daily - ' || COALESCE(pi.duration::text, '7') || ' أيام'
      END as pattern,
      COUNT(*)::int as count,
      CASE WHEN v_total_items > 0 
           THEN ROUND(((COUNT(*)::double precision / v_total_items::double precision) * 100)::numeric, 2)
           ELSE 0 
      END as percentage
    FROM prescription_items pi
    JOIN prescriptions p ON p.id = pi.prescription_id
    WHERE (p_clinic_id IS NULL OR p.clinic_id = p_clinic_id)
      AND (p_doctor_id IS NULL OR p.doctor_id = p_doctor_id)
      AND (p_start_date IS NULL OR p.created_at >= p_start_date)
      AND (p_end_date IS NULL OR p.created_at <= p_end_date)
    GROUP BY 1
    ORDER BY count DESC
  ) cdos;

  -- 7. روابط الدواء بالتشخيص (Drug - Diagnosis Links)
  SELECT COALESCE(jsonb_agg(ddl), '[]'::jsonb) INTO v_drug_diag_links
  FROM (
    SELECT 
      COALESCE(TRIM(p.diagnosis), 'عام') as diagnosis,
      COALESCE(d.trade_name, 'دواء') as drug_name,
      COUNT(*)::int as count
    FROM prescription_items pi
    JOIN prescriptions p ON p.id = pi.prescription_id
    LEFT JOIN drugs d ON d.id = pi.drug_id
    WHERE (p_clinic_id IS NULL OR p.clinic_id = p_clinic_id)
      AND (p_doctor_id IS NULL OR p.doctor_id = p_doctor_id)
      AND (p_start_date IS NULL OR p.created_at >= p_start_date)
      AND (p_end_date IS NULL OR p.created_at <= p_end_date)
    GROUP BY 1, 2
    ORDER BY count DESC
  ) ddl;

  -- 8. الأدوية المكررة لنفس المريض (Repeated Drugs)
  SELECT COALESCE(jsonb_agg(rd), '[]'::jsonb) INTO v_repeated_drugs
  FROM (
    SELECT 
      COALESCE(d.trade_name, 'دواء') as drug_name,
      COUNT(*)::int as repeat_count,
      COUNT(DISTINCT p.patient_id)::int as patient_count
    FROM prescription_items pi
    JOIN prescriptions p ON p.id = pi.prescription_id
    LEFT JOIN drugs d ON d.id = pi.drug_id
    WHERE (p_clinic_id IS NULL OR p.clinic_id = p_clinic_id)
      AND (p_doctor_id IS NULL OR p.doctor_id = p_doctor_id)
      AND (p_start_date IS NULL OR p.created_at >= p_start_date)
      AND (p_end_date IS NULL OR p.created_at <= p_end_date)
    GROUP BY 1
    HAVING COUNT(*) > 1
    ORDER BY repeat_count DESC
  ) rd;

  -- 9. مدى وصول الدواء للمرضى الفريدين (Patient Reach)
  SELECT COALESCE(jsonb_agg(pr), '[]'::jsonb) INTO v_patient_reach
  FROM (
    SELECT 
      COALESCE(d.trade_name, 'دواء') as drug_name,
      COUNT(DISTINCT p.patient_id)::int as unique_patients,
      COUNT(*)::int as total_prescribed_count
    FROM prescription_items pi
    JOIN prescriptions p ON p.id = pi.prescription_id
    LEFT JOIN drugs d ON d.id = pi.drug_id
    WHERE (p_clinic_id IS NULL OR p.clinic_id = p_clinic_id)
      AND (p_doctor_id IS NULL OR p.doctor_id = p_doctor_id)
      AND (p_start_date IS NULL OR p.created_at >= p_start_date)
      AND (p_end_date IS NULL OR p.created_at <= p_end_date)
    GROUP BY 1
    ORDER BY unique_patients DESC
  ) pr;

  RETURN jsonb_build_object(
    'total_prescriptions', v_total_rx,
    'avg_drugs_per_prescription', v_avg_drugs,
    'prn_percentage', v_prn_percentage,
    'top_diagnosis_name', v_top_diagnosis_name,
    'categories', v_categories,
    'by_category', v_categories,
    'top_drugs', v_top_drugs,
    'top_diagnoses', v_top_diagnoses,
    'chronic_drugs', v_chronic_drugs,
    'template_stats', v_template_stats,
    'monthly_trend', v_monthly_trend,
    'common_dosages', v_common_dosages,
    'drug_diagnosis_links', v_drug_diag_links,
    'repeated_drugs', v_repeated_drugs,
    'switched_drugs', '[]'::jsonb,
    'patient_reach', v_patient_reach
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


/* ------------------------------------------------------------------------------
   7. تقرير المرضى المصحح (Patient Stats Report RPC)
   Target Model: PatientStatsModel.fromMap
   Feature Key: 'clinics_reports'
   ------------------------------------------------------------------------------ */
CREATE OR REPLACE FUNCTION get_patient_stats_report_rpc(
  p_clinic_id uuid DEFAULT NULL,
  p_start_date timestamptz DEFAULT NULL,
  p_end_date timestamptz DEFAULT NULL,
  p_owner_id uuid DEFAULT auth.uid()
) RETURNS jsonb AS $$
DECLARE
  v_total int := 0;
  v_new int := 0;
  v_returning int := 0;
  v_return_rate double precision := 0.0;
  v_avg_visits double precision := 0.0;
  v_avg_revenue double precision := 0.0;
  v_new_pct double precision := 0.0;
  v_returning_pct double precision := 0.0;
  v_by_gender jsonb := '{}'::jsonb;
  v_by_age jsonb := '{}'::jsonb;
  v_inactive jsonb := '[]'::jsonb;
BEGIN
  IF p_owner_id IS NOT NULL AND NOT check_subscription_feature_access(p_owner_id, 'clinics_reports') THEN
    RAISE EXCEPTION 'FEATURE_NOT_ALLOWED: clinics_reports' USING ERRCODE = '40301';
  END IF;

  -- 1. إجمالي المرضى
  SELECT COUNT(DISTINCT pat.id) INTO v_total
  FROM patients pat
  WHERE (p_clinic_id IS NULL OR pat.clinic_id = p_clinic_id);

  -- 2. حساب المرضى المستمرين (أكثر من زيارة) ومتوسط الزيارات
  SELECT 
    COUNT(patient_id) FILTER (WHERE visit_count > 1),
    COALESCE(AVG(visit_count), 0.0)
  INTO v_returning, v_avg_visits
  FROM (
    SELECT a.patient_id, COUNT(a.id) as visit_count
    FROM appointments a
    WHERE (p_clinic_id IS NULL OR a.clinic_id = p_clinic_id)
      AND (p_start_date IS NULL OR a.created_at >= p_start_date)
      AND (p_end_date IS NULL OR a.created_at <= p_end_date)
    GROUP BY a.patient_id
  ) appt_stats;

  -- المرضى الجدد هم كل من له زيارة واحدة أو ليس له زيارات بعد (total - returning)
  v_new := GREATEST(v_total - v_returning, 0);

  IF v_total > 0 THEN
    v_return_rate := ROUND(((v_returning::double precision / v_total::double precision) * 100)::numeric, 2);
    v_new_pct := ROUND(((v_new::double precision / v_total::double precision) * 100)::numeric, 2);
    v_returning_pct := ROUND(((v_returning::double precision / v_total::double precision) * 100)::numeric, 2);

    SELECT COALESCE(ROUND((SUM(inv.paid_amount) / v_total::double precision)::numeric, 2), 0.0) INTO v_avg_revenue
    FROM invoices inv
    WHERE (p_clinic_id IS NULL OR inv.clinic_id = p_clinic_id)
      AND (p_start_date IS NULL OR inv.created_at >= p_start_date)
      AND (p_end_date IS NULL OR inv.created_at <= p_end_date);
  END IF;

  -- 3. التوزيع حسب النوع (Gender)
  SELECT COALESCE(jsonb_object_agg(gender, count), '{}'::jsonb) INTO v_by_gender
  FROM (
    SELECT COALESCE(gender, 'male') as gender, COUNT(*)::int as count
    FROM patients
    WHERE (p_clinic_id IS NULL OR clinic_id = p_clinic_id)
    GROUP BY gender
  ) g;

  -- 4. التوزيع حسب الفئة العمرية (Age Groups)
  SELECT COALESCE(jsonb_object_agg(age_group, count), '{}'::jsonb) INTO v_by_age
  FROM (
    SELECT 
      CASE 
        WHEN (EXTRACT(YEAR FROM now()) - EXTRACT(YEAR FROM date_of_birth::date)) <= 18 THEN '0-18'
        WHEN (EXTRACT(YEAR FROM now()) - EXTRACT(YEAR FROM date_of_birth::date)) BETWEEN 19 AND 35 THEN '19-35'
        WHEN (EXTRACT(YEAR FROM now()) - EXTRACT(YEAR FROM date_of_birth::date)) BETWEEN 36 AND 50 THEN '36-50'
        WHEN (EXTRACT(YEAR FROM now()) - EXTRACT(YEAR FROM date_of_birth::date)) BETWEEN 51 AND 65 THEN '51-65'
        ELSE '65+'
      END as age_group,
      COUNT(*)::int as count
    FROM patients
    WHERE (p_clinic_id IS NULL OR clinic_id = p_clinic_id)
      AND date_of_birth IS NOT NULL
    GROUP BY 1
  ) a;

  -- 5. المرضى غير النشطين (لم يزورا العيادة منذ 60 يوماً)
  SELECT COALESCE(jsonb_agg(inp), '[]'::jsonb) INTO v_inactive
  FROM (
    SELECT 
      p.name,
      TO_CHAR(MAX(a.created_at), 'YYYY-MM-DD') as last_visit,
      EXTRACT(DAY FROM (now() - MAX(a.created_at)))::int as days
    FROM patients p
    JOIN appointments a ON a.patient_id = p.id
    WHERE (p_clinic_id IS NULL OR p.clinic_id = p_clinic_id)
    GROUP BY p.id, p.name
    HAVING MAX(a.created_at) < (now() - INTERVAL '60 days')
    ORDER BY MAX(a.created_at) ASC LIMIT 20
  ) inp;

  RETURN jsonb_build_object(
    'total', v_total,
    'new', v_new,
    'returning', v_returning,
    'return_rate', v_return_rate,
    'avg_visits_per_patient', v_avg_visits,
    'avg_revenue_per_patient', v_avg_revenue,
    'new_patients_percentage', v_new_pct,
    'returning_patients_percentage', v_returning_pct,
    'by_gender', v_by_gender,
    'by_age', v_by_age,
    'inactive', v_inactive
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


/* ------------------------------------------------------------------------------
   8. التحقق من إمكانية طباعة واستخراج التقارير (Print & Export Verification RPC)
   Feature Key: 'print_reports'
   ------------------------------------------------------------------------------ */
CREATE OR REPLACE FUNCTION verify_print_report_access_rpc(
  p_owner_id uuid DEFAULT auth.uid()
) RETURNS boolean AS $$
BEGIN
  IF p_owner_id IS NOT NULL AND NOT check_subscription_feature_access(p_owner_id, 'print_reports') THEN
    RAISE EXCEPTION 'FEATURE_NOT_ALLOWED: print_reports' USING ERRCODE = '40301';
  END IF;

  RETURN true;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

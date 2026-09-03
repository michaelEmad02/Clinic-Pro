-- ==============================================================================
-- دوال التقارير المحمية والمفلترة بدقة حسب المالك وعياداته أو حسب الطبيب
-- ==============================================================================

/* ------------------------------------------------------------------------------
   1. تقرير مقارنة وأداء عيادات المالك الشامل (Clinics Overview Report RPC)
   Target Model: ClinicReportEntity / fetchClinicReport
   ------------------------------------------------------------------------------ */
CREATE OR REPLACE FUNCTION get_clinics_report_rpc(
  p_owner_id uuid DEFAULT auth.uid()
) RETURNS jsonb AS $$
DECLARE
  v_owner_id uuid := COALESCE(p_owner_id, auth.uid());
  v_total_active int := 0;
  v_total_exp_rev double precision := 0.0;
  v_total_col_amt double precision := 0.0;
  v_total_exp double precision := 0.0;
  v_total_net double precision := 0.0;
  v_total_appts_today int := 0;
  v_total_docs int := 0;
  v_clinics_list jsonb := '[]'::jsonb;
BEGIN
  IF v_owner_id IS NOT NULL AND NOT check_subscription_feature_access(v_owner_id, 'clinics_reports') THEN
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
      COALESCE(SUM(a.price), 0.0) as expected_rev,
      COALESCE((SELECT SUM(inv.paid_amount) FROM invoices inv WHERE inv.clinic_id = c.id), 0.0) as collected_amt,
      COALESCE((SELECT SUM(e.amount) FROM expenses e WHERE e.clinic_id = c.id AND e.doctor_id IS NULL), 0.0) as exp_amt,
      COUNT(a.id) FILTER (WHERE COALESCE(NULLIF(a.date::text, ''), TO_CHAR(a.created_at, 'YYYY-MM-DD')) = TO_CHAR(CURRENT_DATE, 'YYYY-MM-DD')) as appts_today,
      COUNT(a.id) FILTER (WHERE a.status = 'done') as appts_finished,
      (SELECT COUNT(*) FROM clinic_staff cs WHERE cs.clinic_id = c.id AND cs.role = 'doctor') as doc_count
    FROM appointments a
    WHERE a.clinic_id = c.id
  ) c_data ON true
  WHERE c.owner_id = v_owner_id;

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
   2. تقرير الملخص المالي والإيرادات (Financial Report RPC)
   Target Model: RevenueSummaryModel.fromMap
   Feature Key: 'clinics_reports'
   ------------------------------------------------------------------------------ */
CREATE OR REPLACE FUNCTION get_financial_report_rpc(
  p_clinic_id uuid DEFAULT NULL,
  p_doctor_id uuid DEFAULT NULL,
  p_start_date timestamptz DEFAULT NULL,
  p_end_date timestamptz DEFAULT NULL,
  p_owner_id uuid DEFAULT auth.uid()
) RETURNS jsonb AS $$
DECLARE
  v_owner_id uuid := COALESCE(p_owner_id, auth.uid());
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
  IF p_doctor_id IS NULL AND v_owner_id IS NOT NULL AND NOT check_subscription_feature_access(v_owner_id, 'clinics_reports') THEN
    RAISE EXCEPTION 'FEATURE_NOT_ALLOWED: financial_reports' USING ERRCODE = '40301';
  END IF;

  -- الإيرادات المتوقعة من المواعيد
  SELECT COALESCE(SUM(a.price), 0.0) INTO v_total_revenue
  FROM appointments a
  JOIN clinics c ON c.id = a.clinic_id
  WHERE (p_doctor_id IS NOT NULL OR c.owner_id = v_owner_id)
    AND (p_clinic_id IS NULL OR a.clinic_id = p_clinic_id)
    AND (p_doctor_id IS NULL OR a.doctor_id = p_doctor_id)
    AND (p_start_date IS NULL OR COALESCE(NULLIF(a.date::text, ''), TO_CHAR(a.created_at, 'YYYY-MM-DD')) >= TO_CHAR(p_start_date, 'YYYY-MM-DD'))
    AND (p_end_date IS NULL OR COALESCE(NULLIF(a.date::text, ''), TO_CHAR(a.created_at, 'YYYY-MM-DD')) <= TO_CHAR(p_end_date, 'YYYY-MM-DD'));

  -- المحصل والمتبقي من الفواتير
  IF p_doctor_id IS NOT NULL THEN
    SELECT 
      COALESCE(SUM(inv.paid_amount), 0.0),
      COALESCE(SUM(GREATEST(inv.total_amount - inv.paid_amount, 0.0)), 0.0)
    INTO v_collected, v_pending
    FROM invoices inv
    WHERE (p_clinic_id IS NULL OR inv.clinic_id = p_clinic_id)
      AND inv.doctor_id = p_doctor_id
      AND (p_start_date IS NULL OR inv.created_at >= p_start_date)
      AND (p_end_date IS NULL OR inv.created_at <= p_end_date);
  ELSE
    SELECT 
      COALESCE(SUM(inv.paid_amount), 0.0),
      COALESCE(SUM(GREATEST(inv.total_amount - inv.paid_amount, 0.0)), 0.0)
    INTO v_collected, v_pending
    FROM invoices inv
    JOIN clinics c ON c.id = inv.clinic_id
    WHERE c.owner_id = v_owner_id
      AND (p_clinic_id IS NULL OR inv.clinic_id = p_clinic_id)
      AND (p_start_date IS NULL OR inv.created_at >= p_start_date)
      AND (p_end_date IS NULL OR inv.created_at <= p_end_date);
  END IF;

  -- المصروفات وتوزيعها (إذا كان التقرير لطبيب تخصم مصاريف الطبيب، وإذا كان للمالك تخصم مصاريف العيادة العامة)
  IF p_doctor_id IS NOT NULL THEN
    -- 1. مصروفات الطبيب الشخصية
    SELECT COALESCE(SUM(e.amount), 0.0) INTO v_total_expenses
    FROM expenses e
    WHERE e.doctor_id = p_doctor_id
      AND (p_clinic_id IS NULL OR e.clinic_id = p_clinic_id)
      AND (p_start_date IS NULL OR e.created_at >= p_start_date)
      AND (p_end_date IS NULL OR e.created_at <= p_end_date);

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
      WHERE e.doctor_id = p_doctor_id
        AND (p_clinic_id IS NULL OR e.clinic_id = p_clinic_id)
        AND (p_start_date IS NULL OR e.created_at >= p_start_date)
        AND (p_end_date IS NULL OR e.created_at <= p_end_date)
      GROUP BY COALESCE(ec.name, 'أخرى')
    ) eb;

    SELECT COALESCE(SUM(e.amount), 0.0) INTO v_curr_month_exp
    FROM expenses e
    WHERE e.doctor_id = p_doctor_id
      AND (p_clinic_id IS NULL OR e.clinic_id = p_clinic_id)
      AND DATE_TRUNC('month', e.created_at) = DATE_TRUNC('month', now());

    SELECT COALESCE(SUM(e.amount), 0.0) INTO v_prev_month_exp
    FROM expenses e
    WHERE e.doctor_id = p_doctor_id
      AND (p_clinic_id IS NULL OR e.clinic_id = p_clinic_id)
      AND DATE_TRUNC('month', e.created_at) = DATE_TRUNC('month', now() - INTERVAL '1 month');

    IF v_prev_month_exp > 0 THEN
      v_expenses_change := ROUND(((v_curr_month_exp - v_prev_month_exp) / v_prev_month_exp * 100)::numeric, 0)::text || '%';
    ELSIF v_curr_month_exp > 0 THEN
      v_expenses_change := '+100%';
    END IF;
  ELSE
    -- 2. مصروفات العيادة العامة للمالك
    SELECT COALESCE(SUM(e.amount), 0.0) INTO v_total_expenses
    FROM expenses e
    JOIN clinics c ON c.id = e.clinic_id
    WHERE c.owner_id = v_owner_id
      AND e.doctor_id IS NULL
      AND (p_clinic_id IS NULL OR e.clinic_id = p_clinic_id)
      AND (p_start_date IS NULL OR e.created_at >= p_start_date)
      AND (p_end_date IS NULL OR e.created_at <= p_end_date);

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
      JOIN clinics c ON c.id = e.clinic_id
      LEFT JOIN expense_categories ec ON ec.id = e.category_id
      WHERE c.owner_id = v_owner_id
        AND e.doctor_id IS NULL
        AND (p_clinic_id IS NULL OR e.clinic_id = p_clinic_id)
        AND (p_start_date IS NULL OR e.created_at >= p_start_date)
        AND (p_end_date IS NULL OR e.created_at <= p_end_date)
      GROUP BY COALESCE(ec.name, 'أخرى')
    ) eb;

    SELECT COALESCE(SUM(e.amount), 0.0) INTO v_curr_month_exp
    FROM expenses e
    JOIN clinics c ON c.id = e.clinic_id
    WHERE c.owner_id = v_owner_id
      AND e.doctor_id IS NULL
      AND (p_clinic_id IS NULL OR e.clinic_id = p_clinic_id)
      AND DATE_TRUNC('month', e.created_at) = DATE_TRUNC('month', now());

    SELECT COALESCE(SUM(e.amount), 0.0) INTO v_prev_month_exp
    FROM expenses e
    JOIN clinics c ON c.id = e.clinic_id
    WHERE c.owner_id = v_owner_id
      AND e.doctor_id IS NULL
      AND (p_clinic_id IS NULL OR e.clinic_id = p_clinic_id)
      AND DATE_TRUNC('month', e.created_at) = DATE_TRUNC('month', now() - INTERVAL '1 month');

    IF v_prev_month_exp > 0 THEN
      v_expenses_change := ROUND(((v_curr_month_exp - v_prev_month_exp) / v_prev_month_exp * 100)::numeric, 0)::text || '%';
    ELSIF v_curr_month_exp > 0 THEN
      v_expenses_change := '+100%';
    END IF;
  END IF;

  -- 📈 حساب نسبة التغير في الإيرادات عن الشهر السابق
  IF p_doctor_id IS NOT NULL THEN
    SELECT COALESCE(SUM(inv.paid_amount), 0.0) INTO v_curr_month_rev
    FROM invoices inv
    WHERE (p_clinic_id IS NULL OR inv.clinic_id = p_clinic_id)
      AND inv.doctor_id = p_doctor_id
      AND DATE_TRUNC('month', inv.created_at) = DATE_TRUNC('month', now());

    SELECT COALESCE(SUM(inv.paid_amount), 0.0) INTO v_prev_month_rev
    FROM invoices inv
    WHERE (p_clinic_id IS NULL OR inv.clinic_id = p_clinic_id)
      AND inv.doctor_id = p_doctor_id
      AND DATE_TRUNC('month', inv.created_at) = DATE_TRUNC('month', now() - INTERVAL '1 month');
  ELSE
    SELECT COALESCE(SUM(inv.paid_amount), 0.0) INTO v_curr_month_rev
    FROM invoices inv
    JOIN clinics c ON c.id = inv.clinic_id
    WHERE c.owner_id = v_owner_id
      AND (p_clinic_id IS NULL OR inv.clinic_id = p_clinic_id)
      AND DATE_TRUNC('month', inv.created_at) = DATE_TRUNC('month', now());

    SELECT COALESCE(SUM(inv.paid_amount), 0.0) INTO v_prev_month_rev
    FROM invoices inv
    JOIN clinics c ON c.id = inv.clinic_id
    WHERE c.owner_id = v_owner_id
      AND (p_clinic_id IS NULL OR inv.clinic_id = p_clinic_id)
      AND DATE_TRUNC('month', inv.created_at) = DATE_TRUNC('month', now() - INTERVAL '1 month');
  END IF;

  IF v_prev_month_rev > 0 THEN
    v_revenue_change := ROUND(((v_curr_month_rev - v_prev_month_rev) / v_prev_month_rev * 100)::numeric, 0)::text || '%';
  ELSIF v_curr_month_rev > 0 THEN
    v_revenue_change := '+100%';
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
        WHEN EXTRACT(DAY FROM a.created_at) <= 7 THEN 1
        WHEN EXTRACT(DAY FROM a.created_at) <= 14 THEN 2
        WHEN EXTRACT(DAY FROM a.created_at) <= 21 THEN 3
        ELSE 4
      END as week_num,
      SUM(a.price)::double precision as rev
    FROM appointments a
    JOIN clinics c ON c.id = a.clinic_id
    WHERE (p_doctor_id IS NOT NULL OR c.owner_id = v_owner_id)
      AND SUBSTRING(COALESCE(NULLIF(a.date::text, ''), TO_CHAR(a.created_at, 'YYYY-MM-DD')) FROM 1 FOR 7) = TO_CHAR(now(), 'YYYY-MM')
      AND (p_clinic_id IS NULL OR a.clinic_id = p_clinic_id)
      AND (p_doctor_id IS NULL OR a.doctor_id = p_doctor_id)
    GROUP BY 1
  ) w_rev ON w_rev.week_num = w.week_num
  LEFT JOIN (
    SELECT 
      CASE 
        WHEN EXTRACT(DAY FROM inv.created_at) <= 7 THEN 1
        WHEN EXTRACT(DAY FROM inv.created_at) <= 14 THEN 2
        WHEN EXTRACT(DAY FROM inv.created_at) <= 21 THEN 3
        ELSE 4
      END as week_num,
      SUM(inv.paid_amount)::double precision as col
    FROM invoices inv
    LEFT JOIN clinics c ON c.id = inv.clinic_id
    WHERE (
      (p_doctor_id IS NOT NULL AND inv.doctor_id = p_doctor_id)
      OR (p_doctor_id IS NULL AND c.owner_id = v_owner_id)
    )
      AND DATE_TRUNC('month', inv.created_at) = DATE_TRUNC('month', now())
      AND (p_clinic_id IS NULL OR inv.clinic_id = p_clinic_id)
    GROUP BY 1
  ) w_inv ON w_inv.week_num = w.week_num
  LEFT JOIN (
    SELECT 
      CASE 
        WHEN EXTRACT(DAY FROM e.created_at) <= 7 THEN 1
        WHEN EXTRACT(DAY FROM e.created_at) <= 14 THEN 2
        WHEN EXTRACT(DAY FROM e.created_at) <= 21 THEN 3
        ELSE 4
      END as week_num,
      SUM(e.amount)::double precision as exp
    FROM expenses e
    LEFT JOIN clinics c ON c.id = e.clinic_id
    WHERE (
      (p_doctor_id IS NOT NULL AND e.doctor_id = p_doctor_id)
      OR (p_doctor_id IS NULL AND e.doctor_id IS NULL AND c.owner_id = v_owner_id)
    )
      AND DATE_TRUNC('month', e.created_at) = DATE_TRUNC('month', now())
      AND (p_clinic_id IS NULL OR e.clinic_id = p_clinic_id)
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
   3. تقرير المواعيد الشامل (Appointments Report RPC)
   Target Model: AppointmentStatsModel.fromMap
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
  v_owner_id uuid := COALESCE(p_owner_id, auth.uid());
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
  IF p_doctor_id IS NULL AND v_owner_id IS NOT NULL AND NOT check_subscription_feature_access(v_owner_id, 'appointments_reports') THEN
    RAISE EXCEPTION 'FEATURE_NOT_ALLOWED: appointments_reports' USING ERRCODE = '40301';
  END IF;

  SELECT 
    COUNT(*),
    COUNT(*) FILTER (WHERE a.status IN ('confirmed', 'done', 'in_progress')),
    COUNT(*) FILTER (WHERE a.status = 'cancelled'),
    COUNT(*) FILTER (WHERE a.status IN ('scheduled', 'confirmed') AND COALESCE(NULLIF(a.date::text, ''), TO_CHAR(a.created_at, 'YYYY-MM-DD')) < TO_CHAR(CURRENT_DATE, 'YYYY-MM-DD')),
    COUNT(*) FILTER (WHERE a.is_urgent = true),
    COALESCE(ROUND(AVG(EXTRACT(EPOCH FROM (a.called_at::timestamptz - a.arrived_at::timestamptz)) / 60) FILTER (WHERE a.arrived_at IS NOT NULL AND a.called_at IS NOT NULL AND a.called_at::timestamptz >= a.arrived_at::timestamptz)), 0)::int
  INTO v_total, v_completed, v_cancelled, v_no_show, v_urgent, v_avg_wait_time
  FROM appointments a
  JOIN clinics c ON c.id = a.clinic_id
  WHERE (p_doctor_id IS NOT NULL OR c.owner_id = v_owner_id)
    AND (p_clinic_id IS NULL OR a.clinic_id = p_clinic_id)
    AND (p_doctor_id IS NULL OR a.doctor_id = p_doctor_id)
    AND (p_start_date IS NULL OR COALESCE(NULLIF(a.date::text, ''), TO_CHAR(a.created_at, 'YYYY-MM-DD')) >= TO_CHAR(p_start_date, 'YYYY-MM-DD'))
    AND (p_end_date IS NULL OR COALESCE(NULLIF(a.date::text, ''), TO_CHAR(a.created_at, 'YYYY-MM-DD')) <= TO_CHAR(p_end_date, 'YYYY-MM-DD'));

  IF v_total > 0 THEN
    v_attendance_rate := ROUND(((v_completed::double precision / v_total::double precision) * 100)::numeric, 2);
    v_no_show_rate := ROUND(((v_no_show::double precision / v_total::double precision) * 100)::numeric, 2);
    v_urgent_percentage := ROUND(((v_urgent::double precision / v_total::double precision) * 100)::numeric, 2);
  END IF;

  SELECT COALESCE(jsonb_object_agg(status, count), '{}'::jsonb) INTO v_status_breakdown
  FROM (
    SELECT a.status, COUNT(*)::int as count
    FROM appointments a
    JOIN clinics c ON c.id = a.clinic_id
    WHERE (p_doctor_id IS NOT NULL OR c.owner_id = v_owner_id)
      AND (p_clinic_id IS NULL OR a.clinic_id = p_clinic_id)
      AND (p_doctor_id IS NULL OR a.doctor_id = p_doctor_id)
      AND (p_start_date IS NULL OR COALESCE(NULLIF(a.date::text, ''), TO_CHAR(a.created_at, 'YYYY-MM-DD')) >= TO_CHAR(p_start_date, 'YYYY-MM-DD'))
      AND (p_end_date IS NULL OR COALESCE(NULLIF(a.date::text, ''), TO_CHAR(a.created_at, 'YYYY-MM-DD')) <= TO_CHAR(p_end_date, 'YYYY-MM-DD'))
    GROUP BY a.status
  ) sb;

  SELECT COALESCE(jsonb_agg(ph), '[]'::jsonb) INTO v_peak_hours
  FROM (
    SELECT 
      EXTRACT(HOUR FROM a.created_at)::int as hour, 
      COUNT(*)::int as count
    FROM appointments a
    JOIN clinics c ON c.id = a.clinic_id
    WHERE (p_doctor_id IS NOT NULL OR c.owner_id = v_owner_id)
      AND (p_clinic_id IS NULL OR a.clinic_id = p_clinic_id)
      AND (p_doctor_id IS NULL OR a.doctor_id = p_doctor_id)
      AND (p_start_date IS NULL OR COALESCE(NULLIF(a.date::text, ''), TO_CHAR(a.created_at, 'YYYY-MM-DD')) >= TO_CHAR(p_start_date, 'YYYY-MM-DD'))
      AND (p_end_date IS NULL OR COALESCE(NULLIF(a.date::text, ''), TO_CHAR(a.created_at, 'YYYY-MM-DD')) <= TO_CHAR(p_end_date, 'YYYY-MM-DD'))
    GROUP BY 1 ORDER BY count DESC LIMIT 5
  ) ph;

  SELECT COALESCE(jsonb_agg(pd), '[]'::jsonb) INTO v_peak_days
  FROM (
    SELECT 
      TO_CHAR(a.created_at, 'Day') as day, 
      COUNT(*)::int as count
    FROM appointments a
    JOIN clinics c ON c.id = a.clinic_id
    WHERE (p_doctor_id IS NOT NULL OR c.owner_id = v_owner_id)
      AND (p_clinic_id IS NULL OR a.clinic_id = p_clinic_id)
      AND (p_doctor_id IS NULL OR a.doctor_id = p_doctor_id)
      AND (p_start_date IS NULL OR COALESCE(NULLIF(a.date::text, ''), TO_CHAR(a.created_at, 'YYYY-MM-DD')) >= TO_CHAR(p_start_date, 'YYYY-MM-DD'))
      AND (p_end_date IS NULL OR COALESCE(NULLIF(a.date::text, ''), TO_CHAR(a.created_at, 'YYYY-MM-DD')) <= TO_CHAR(p_end_date, 'YYYY-MM-DD'))
    GROUP BY 1 ORDER BY count DESC
  ) pd;

  -- 🏷️ أنواع الزيارات
  SELECT COALESCE(jsonb_agg(bt), '[]'::jsonb) INTO v_by_type
  FROM (
    SELECT 
      COALESCE(at.name, 'كشف عادي') as name, 
      COUNT(*)::int as count
    FROM appointments a
    JOIN clinics c ON c.id = a.clinic_id
    LEFT JOIN doctor_appointment_types dat ON dat.id = a.type_id
    LEFT JOIN appointment_types at ON at.id = dat.appointment_type_id
    WHERE (p_doctor_id IS NOT NULL OR c.owner_id = v_owner_id)
      AND (p_clinic_id IS NULL OR a.clinic_id = p_clinic_id)
      AND (p_doctor_id IS NULL OR a.doctor_id = p_doctor_id)
      AND (p_start_date IS NULL OR COALESCE(NULLIF(a.date::text, ''), TO_CHAR(a.created_at, 'YYYY-MM-DD')) >= TO_CHAR(p_start_date, 'YYYY-MM-DD'))
      AND (p_end_date IS NULL OR COALESCE(NULLIF(a.date::text, ''), TO_CHAR(a.created_at, 'YYYY-MM-DD')) <= TO_CHAR(p_end_date, 'YYYY-MM-DD'))
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
   4. تقرير المرضى (Patient Stats Report RPC)
   Target Model: PatientStatsModel.fromMap
   Feature Key: 'clinics_reports'
   ------------------------------------------------------------------------------ */
CREATE OR REPLACE FUNCTION get_patient_stats_report_rpc(
  p_clinic_id uuid DEFAULT NULL,
  p_doctor_id uuid DEFAULT NULL,
  p_start_date timestamptz DEFAULT NULL,
  p_end_date timestamptz DEFAULT NULL,
  p_owner_id uuid DEFAULT auth.uid()
) RETURNS jsonb AS $$
DECLARE
  v_owner_id uuid := COALESCE(p_owner_id, auth.uid());
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
  IF p_doctor_id IS NULL AND v_owner_id IS NOT NULL AND NOT check_subscription_feature_access(v_owner_id, 'clinics_reports') THEN
    RAISE EXCEPTION 'FEATURE_NOT_ALLOWED: clinics_reports' USING ERRCODE = '40301';
  END IF;

  -- 1. إجمالي المرضى
  IF p_doctor_id IS NOT NULL THEN
    SELECT COUNT(DISTINCT a.patient_id) INTO v_total
    FROM appointments a
    WHERE (p_clinic_id IS NULL OR a.clinic_id = p_clinic_id)
      AND a.doctor_id = p_doctor_id;
  ELSE
    SELECT COUNT(DISTINCT pat.id) INTO v_total
    FROM patients pat
    JOIN clinics c ON c.id = pat.clinic_id
    WHERE c.owner_id = v_owner_id
      AND (p_clinic_id IS NULL OR pat.clinic_id = p_clinic_id);
  END IF;

  -- 2. حساب المرضى المستمرين ومتوسط الزيارات
  SELECT 
    COUNT(patient_id) FILTER (WHERE visit_count > 1),
    COALESCE(AVG(visit_count), 0.0)
  INTO v_returning, v_avg_visits
  FROM (
    SELECT a.patient_id, COUNT(a.id) as visit_count
    FROM appointments a
    JOIN clinics c ON c.id = a.clinic_id
    WHERE (p_doctor_id IS NOT NULL OR c.owner_id = v_owner_id)
      AND (p_clinic_id IS NULL OR a.clinic_id = p_clinic_id)
      AND (p_doctor_id IS NULL OR a.doctor_id = p_doctor_id)
      AND (p_start_date IS NULL OR COALESCE(NULLIF(a.date::text, ''), TO_CHAR(a.created_at, 'YYYY-MM-DD')) >= TO_CHAR(p_start_date, 'YYYY-MM-DD'))
      AND (p_end_date IS NULL OR COALESCE(NULLIF(a.date::text, ''), TO_CHAR(a.created_at, 'YYYY-MM-DD')) <= TO_CHAR(p_end_date, 'YYYY-MM-DD'))
    GROUP BY a.patient_id
  ) appt_stats;

  v_new := GREATEST(v_total - v_returning, 0);

  IF v_total > 0 THEN
    v_return_rate := ROUND(((v_returning::double precision / v_total::double precision) * 100)::numeric, 2);
    v_new_pct := ROUND(((v_new::double precision / v_total::double precision) * 100)::numeric, 2);
    v_returning_pct := ROUND(((v_returning::double precision / v_total::double precision) * 100)::numeric, 2);

    IF p_doctor_id IS NOT NULL THEN
      SELECT COALESCE(ROUND((SUM(inv.paid_amount) / v_total::double precision)::numeric, 2), 0.0) INTO v_avg_revenue
      FROM invoices inv
      WHERE (p_clinic_id IS NULL OR inv.clinic_id = p_clinic_id)
        AND inv.doctor_id = p_doctor_id
        AND (p_start_date IS NULL OR inv.created_at >= p_start_date)
        AND (p_end_date IS NULL OR inv.created_at <= p_end_date);
    ELSE
      SELECT COALESCE(ROUND((SUM(inv.paid_amount) / v_total::double precision)::numeric, 2), 0.0) INTO v_avg_revenue
      FROM invoices inv
      JOIN clinics c ON c.id = inv.clinic_id
      WHERE c.owner_id = v_owner_id
        AND (p_clinic_id IS NULL OR inv.clinic_id = p_clinic_id)
        AND (p_start_date IS NULL OR inv.created_at >= p_start_date)
        AND (p_end_date IS NULL OR inv.created_at <= p_end_date);
    END IF;
  END IF;

  -- 3. التوزيع حسب النوع (Gender)
  IF p_doctor_id IS NOT NULL THEN
    SELECT COALESCE(jsonb_object_agg(gender, count), '{}'::jsonb) INTO v_by_gender
    FROM (
      SELECT COALESCE(pat.gender, 'male') as gender, COUNT(DISTINCT pat.id)::int as count
      FROM patients pat
      JOIN appointments a ON a.patient_id = pat.id
      WHERE (p_clinic_id IS NULL OR a.clinic_id = p_clinic_id)
        AND a.doctor_id = p_doctor_id
      GROUP BY pat.gender
    ) g;
  ELSE
    SELECT COALESCE(jsonb_object_agg(gender, count), '{}'::jsonb) INTO v_by_gender
    FROM (
      SELECT COALESCE(pat.gender, 'male') as gender, COUNT(*)::int as count
      FROM patients pat
      JOIN clinics c ON c.id = pat.clinic_id
      WHERE c.owner_id = v_owner_id
        AND (p_clinic_id IS NULL OR pat.clinic_id = p_clinic_id)
      GROUP BY pat.gender
    ) g;
  END IF;

  -- 4. التوزيع حسب الفئة العمرية
  IF p_doctor_id IS NOT NULL THEN
    SELECT COALESCE(jsonb_object_agg(age_group, count), '{}'::jsonb) INTO v_by_age
    FROM (
      SELECT 
        CASE 
          WHEN (EXTRACT(YEAR FROM now()) - COALESCE(NULLIF(SUBSTRING(pat.date_of_birth::text FROM 1 FOR 4), '')::int, EXTRACT(YEAR FROM now())::int)) <= 18 THEN '0-18'
          WHEN (EXTRACT(YEAR FROM now()) - COALESCE(NULLIF(SUBSTRING(pat.date_of_birth::text FROM 1 FOR 4), '')::int, EXTRACT(YEAR FROM now())::int)) BETWEEN 19 AND 35 THEN '19-35'
          WHEN (EXTRACT(YEAR FROM now()) - COALESCE(NULLIF(SUBSTRING(pat.date_of_birth::text FROM 1 FOR 4), '')::int, EXTRACT(YEAR FROM now())::int)) BETWEEN 36 AND 50 THEN '36-50'
          WHEN (EXTRACT(YEAR FROM now()) - COALESCE(NULLIF(SUBSTRING(pat.date_of_birth::text FROM 1 FOR 4), '')::int, EXTRACT(YEAR FROM now())::int)) BETWEEN 51 AND 65 THEN '51-65'
          ELSE '65+'
        END as age_group,
        COUNT(DISTINCT pat.id)::int as count
      FROM patients pat
      JOIN appointments a ON a.patient_id = pat.id
      WHERE (p_clinic_id IS NULL OR a.clinic_id = p_clinic_id)
        AND a.doctor_id = p_doctor_id
        AND pat.date_of_birth IS NOT NULL AND TRIM(pat.date_of_birth::text) != ''
      GROUP BY 1
    ) a_grp;
  ELSE
    SELECT COALESCE(jsonb_object_agg(age_group, count), '{}'::jsonb) INTO v_by_age
    FROM (
      SELECT 
        CASE 
          WHEN (EXTRACT(YEAR FROM now()) - COALESCE(NULLIF(SUBSTRING(pat.date_of_birth::text FROM 1 FOR 4), '')::int, EXTRACT(YEAR FROM now())::int)) <= 18 THEN '0-18'
          WHEN (EXTRACT(YEAR FROM now()) - COALESCE(NULLIF(SUBSTRING(pat.date_of_birth::text FROM 1 FOR 4), '')::int, EXTRACT(YEAR FROM now())::int)) BETWEEN 19 AND 35 THEN '19-35'
          WHEN (EXTRACT(YEAR FROM now()) - COALESCE(NULLIF(SUBSTRING(pat.date_of_birth::text FROM 1 FOR 4), '')::int, EXTRACT(YEAR FROM now())::int)) BETWEEN 36 AND 50 THEN '36-50'
          WHEN (EXTRACT(YEAR FROM now()) - COALESCE(NULLIF(SUBSTRING(pat.date_of_birth::text FROM 1 FOR 4), '')::int, EXTRACT(YEAR FROM now())::int)) BETWEEN 51 AND 65 THEN '51-65'
          ELSE '65+'
        END as age_group,
        COUNT(*)::int as count
      FROM patients pat
      JOIN clinics c ON c.id = pat.clinic_id
      WHERE c.owner_id = v_owner_id
        AND (p_clinic_id IS NULL OR pat.clinic_id = p_clinic_id)
        AND pat.date_of_birth IS NOT NULL AND TRIM(pat.date_of_birth::text) != ''
      GROUP BY 1
    ) a_grp;
  END IF;

  -- 5. المرضى غير النشطين
  SELECT COALESCE(jsonb_agg(inp), '[]'::jsonb) INTO v_inactive
  FROM (
    SELECT 
      p.name,
      TO_CHAR(MAX(a.created_at), 'YYYY-MM-DD') as last_visit,
      EXTRACT(DAY FROM (now() - MAX(a.created_at)))::int as days
    FROM patients p
    JOIN clinics c ON c.id = p.clinic_id
    JOIN appointments a ON a.patient_id = p.id
    WHERE (p_doctor_id IS NOT NULL OR c.owner_id = v_owner_id)
      AND (p_clinic_id IS NULL OR p.clinic_id = p_clinic_id)
      AND (p_doctor_id IS NULL OR a.doctor_id = p_doctor_id)
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
   5. تقرير أداء الأطباء (Doctors Performance Report RPC)
   Target Model: List<DoctorPerformanceModel>
   Feature Key: 'doctors_performance_reports'
   ------------------------------------------------------------------------------ */
CREATE OR REPLACE FUNCTION get_doctors_performance_report_rpc(
  p_clinic_id uuid DEFAULT NULL,
  p_start_date timestamptz DEFAULT NULL,
  p_end_date timestamptz DEFAULT NULL,
  p_owner_id uuid DEFAULT auth.uid()
) RETURNS jsonb AS $$
DECLARE
  v_owner_id uuid := COALESCE(p_owner_id, auth.uid());
  v_total_revenue double precision := 0.0;
  v_result jsonb := '[]'::jsonb;
BEGIN
  IF v_owner_id IS NOT NULL AND NOT check_subscription_feature_access(v_owner_id, 'doctors_performance_reports') THEN
    RAISE EXCEPTION 'FEATURE_NOT_ALLOWED: doctors_performance_reports' USING ERRCODE = '40301';
  END IF;

  SELECT COALESCE(SUM(inv.paid_amount), 0.0) INTO v_total_revenue
  FROM invoices inv
  JOIN clinics c ON c.id = inv.clinic_id
  WHERE c.owner_id = v_owner_id
    AND (p_clinic_id IS NULL OR inv.clinic_id = p_clinic_id)
    AND (p_start_date IS NULL OR inv.created_at >= p_start_date)
    AND (p_end_date IS NULL OR inv.created_at <= p_end_date);

  SELECT COALESCE(jsonb_agg(doc_item), '[]'::jsonb) INTO v_result
  FROM (
    SELECT 
      u.id as doctor_id,
      COALESCE(u.name, 'طبيب غير معروف') as doctor_name,
      COALESCE(doc_appts.visit_count, 0)::int as visit_count,
      COALESCE(doc_inv.revenue, 0.0)::double precision as revenue,
      CASE 
        WHEN v_total_revenue > 0 
        THEN ROUND(((COALESCE(doc_inv.revenue, 0.0) / v_total_revenue) * 100)::numeric, 0)::int 
        ELSE 0 
      END as rating,
      CASE 
        WHEN COALESCE(doc_curr.curr_rev, 0.0) >= COALESCE(doc_prev.prev_rev, 0.0) THEN 'up' 
        ELSE 'down' 
      END as trend,
      u.image_url as avatar_url
    FROM (
      SELECT DISTINCT cs.user_id 
      FROM clinic_staff cs
      JOIN clinics c ON c.id = cs.clinic_id
      WHERE c.owner_id = v_owner_id
        AND cs.role = 'doctor' 
        AND (p_clinic_id IS NULL OR cs.clinic_id = p_clinic_id)
    ) docs
    JOIN users u ON u.id = docs.user_id
    LEFT JOIN (
      SELECT 
        a.doctor_id,
        COUNT(a.id) as visit_count
      FROM appointments a
      JOIN clinics c ON c.id = a.clinic_id
      WHERE c.owner_id = v_owner_id
        AND a.status != 'cancelled'
        AND (p_clinic_id IS NULL OR a.clinic_id = p_clinic_id)
        AND (p_start_date IS NULL OR COALESCE(NULLIF(a.date::text, ''), TO_CHAR(a.created_at, 'YYYY-MM-DD')) >= TO_CHAR(p_start_date, 'YYYY-MM-DD'))
        AND (p_end_date IS NULL OR COALESCE(NULLIF(a.date::text, ''), TO_CHAR(a.created_at, 'YYYY-MM-DD')) <= TO_CHAR(p_end_date, 'YYYY-MM-DD'))
      GROUP BY a.doctor_id
    ) doc_appts ON doc_appts.doctor_id = u.id
    LEFT JOIN (
      SELECT 
        inv.doctor_id,
        SUM(inv.paid_amount) as revenue
      FROM invoices inv
      JOIN clinics c ON c.id = inv.clinic_id
      WHERE c.owner_id = v_owner_id
        AND (p_clinic_id IS NULL OR inv.clinic_id = p_clinic_id)
        AND (p_start_date IS NULL OR inv.created_at >= p_start_date)
        AND (p_end_date IS NULL OR inv.created_at <= p_end_date)
      GROUP BY inv.doctor_id
    ) doc_inv ON doc_inv.doctor_id = u.id
    LEFT JOIN (
      SELECT 
        inv.doctor_id,
        SUM(inv.paid_amount) as curr_rev
      FROM invoices inv
      JOIN clinics c ON c.id = inv.clinic_id
      WHERE c.owner_id = v_owner_id
        AND (p_clinic_id IS NULL OR inv.clinic_id = p_clinic_id)
        AND DATE_TRUNC('month', inv.created_at) = DATE_TRUNC('month', now())
      GROUP BY inv.doctor_id
    ) doc_curr ON doc_curr.doctor_id = u.id
    LEFT JOIN (
      SELECT 
        inv.doctor_id,
        SUM(inv.paid_amount) as prev_rev
      FROM invoices inv
      JOIN clinics c ON c.id = inv.clinic_id
      WHERE c.owner_id = v_owner_id
        AND (p_clinic_id IS NULL OR inv.clinic_id = p_clinic_id)
        AND DATE_TRUNC('month', inv.created_at) = DATE_TRUNC('month', now() - INTERVAL '1 month')
      GROUP BY inv.doctor_id
    ) doc_prev ON doc_prev.doctor_id = u.id
    ORDER BY revenue DESC
  ) doc_item;

  RETURN v_result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;




/* ------------------------------------------------------------------------------
   6. تقرير الروشتات والأدوية (Prescriptions & Drugs Report RPC)
   Target Model: DrugStatsModel.fromMap / TemplateStatsModel.fromMap
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
  v_owner_id uuid := COALESCE(p_owner_id, auth.uid());
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
  IF p_doctor_id IS NULL AND v_owner_id IS NOT NULL AND NOT check_subscription_feature_access(v_owner_id, 'prescriptions_reports') THEN
    RAISE EXCEPTION 'FEATURE_NOT_ALLOWED: prescriptions_reports' USING ERRCODE = '40301';
  END IF;

  -- 1. حساب إجمالي الروشتات
  SELECT COUNT(DISTINCT p.id) INTO v_total_rx
  FROM prescriptions p
  JOIN clinics c ON c.id = p.clinic_id
  WHERE (p_doctor_id IS NOT NULL OR c.owner_id = v_owner_id)
    AND (p_clinic_id IS NULL OR p.clinic_id = p_clinic_id)
    AND (p_doctor_id IS NULL OR p.doctor_id = p_doctor_id)
    AND (p_start_date IS NULL OR p.created_at >= p_start_date)
    AND (p_end_date IS NULL OR p.created_at <= p_end_date);

  SELECT COUNT(pi.id), COUNT(pi.id) FILTER (WHERE pi.is_prn = true)
  INTO v_total_items, v_prn_count
  FROM prescription_items pi
  JOIN prescriptions p ON p.id = pi.prescription_id
  JOIN clinics c ON c.id = p.clinic_id
  WHERE (p_doctor_id IS NOT NULL OR c.owner_id = v_owner_id)
    AND (p_clinic_id IS NULL OR p.clinic_id = p_clinic_id)
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
    JOIN clinics c ON c.id = p.clinic_id
    WHERE (p_doctor_id IS NOT NULL OR c.owner_id = v_owner_id)
      AND (p_clinic_id IS NULL OR p.clinic_id = p_clinic_id)
      AND (p_doctor_id IS NULL OR p.doctor_id = p_doctor_id)
      AND (p_start_date IS NULL OR p.created_at >= p_start_date)
      AND (p_end_date IS NULL OR p.created_at <= p_end_date)
      AND p.diagnosis IS NOT NULL AND TRIM(p.diagnosis) != ''
    GROUP BY TRIM(p.diagnosis)
    ORDER BY count DESC
  ) td;

  SELECT COALESCE(v_top_diagnoses->0->>'name', '') INTO v_top_diagnosis_name;

  -- 3. الفئات والأدوية
  SELECT COALESCE(jsonb_agg(cat), '[]'::jsonb) INTO v_categories
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
    JOIN clinics c ON c.id = p.clinic_id
    LEFT JOIN drugs d ON d.id = pi.drug_id
    WHERE (p_doctor_id IS NOT NULL OR c.owner_id = v_owner_id)
      AND (p_clinic_id IS NULL OR p.clinic_id = p_clinic_id)
      AND (p_doctor_id IS NULL OR p.doctor_id = p_doctor_id)
      AND (p_start_date IS NULL OR p.created_at >= p_start_date)
      AND (p_end_date IS NULL OR p.created_at <= p_end_date)
    GROUP BY COALESCE(d.category, 'عام')
    ORDER BY count DESC
  ) cat;

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
    JOIN clinics c ON c.id = p.clinic_id
    LEFT JOIN drugs d ON d.id = pi.drug_id
    WHERE (p_doctor_id IS NOT NULL OR c.owner_id = v_owner_id)
      AND (p_clinic_id IS NULL OR p.clinic_id = p_clinic_id)
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
    JOIN clinics c ON c.id = p.clinic_id
    LEFT JOIN drugs d ON d.id = pi.drug_id
    WHERE (p_doctor_id IS NOT NULL OR c.owner_id = v_owner_id)
      AND pi.duration = 0
      AND (p_clinic_id IS NULL OR p.clinic_id = p_clinic_id)
      AND (p_doctor_id IS NULL OR p.doctor_id = p_doctor_id)
      AND (p_start_date IS NULL OR p.created_at >= p_start_date)
      AND (p_end_date IS NULL OR p.created_at <= p_end_date)
    GROUP BY d.trade_name
    ORDER BY count DESC
  ) cd;

  -- 4. إحصائيات القوالب
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
    WHERE (p_doctor_id IS NOT NULL AND pt.doctor_id = p_doctor_id)
       OR (p_doctor_id IS NULL AND pt.doctor_id IN (
            SELECT cs.user_id FROM clinic_staff cs JOIN clinics c ON c.id = cs.clinic_id WHERE c.owner_id = v_owner_id
          ))
    ORDER BY pt.user_count DESC
  ) ts;

  -- 5. الاتجاه الشهري للروشتات
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
      AND (p_doctor_id IS NOT NULL OR p.clinic_id IN (SELECT id FROM clinics WHERE owner_id = v_owner_id))
    LEFT JOIN prescription_items pi ON pi.prescription_id = p.id
    GROUP BY 1
    ORDER BY 1 ASC
  ) mt;

  -- 6. أنماط الجرعات
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
    JOIN clinics c ON c.id = p.clinic_id
    WHERE (p_doctor_id IS NOT NULL OR c.owner_id = v_owner_id)
      AND (p_clinic_id IS NULL OR p.clinic_id = p_clinic_id)
      AND (p_doctor_id IS NULL OR p.doctor_id = p_doctor_id)
      AND (p_start_date IS NULL OR p.created_at >= p_start_date)
      AND (p_end_date IS NULL OR p.created_at <= p_end_date)
    GROUP BY 1
    ORDER BY count DESC
  ) cdos;

  -- 7. روابط الدواء بالتشخيص
  SELECT COALESCE(jsonb_agg(ddl), '[]'::jsonb) INTO v_drug_diag_links
  FROM (
    SELECT 
      COALESCE(TRIM(p.diagnosis), 'عام') as diagnosis,
      COALESCE(d.trade_name, 'دواء') as drug_name,
      COUNT(*)::int as count
    FROM prescription_items pi
    JOIN prescriptions p ON p.id = pi.prescription_id
    JOIN clinics c ON c.id = p.clinic_id
    LEFT JOIN drugs d ON d.id = pi.drug_id
    WHERE (p_doctor_id IS NOT NULL OR c.owner_id = v_owner_id)
      AND (p_clinic_id IS NULL OR p.clinic_id = p_clinic_id)
      AND (p_doctor_id IS NULL OR p.doctor_id = p_doctor_id)
      AND (p_start_date IS NULL OR p.created_at >= p_start_date)
      AND (p_end_date IS NULL OR p.created_at <= p_end_date)
    GROUP BY 1, 2
    ORDER BY count DESC
  ) ddl;

  -- 8. الأدوية المكررة لنفس المريض
  SELECT COALESCE(jsonb_agg(rd), '[]'::jsonb) INTO v_repeated_drugs
  FROM (
    SELECT 
      COALESCE(d.trade_name, 'دواء') as drug_name,
      COUNT(*)::int as repeat_count,
      COUNT(DISTINCT p.patient_id)::int as patient_count
    FROM prescription_items pi
    JOIN prescriptions p ON p.id = pi.prescription_id
    JOIN clinics c ON c.id = p.clinic_id
    LEFT JOIN drugs d ON d.id = pi.drug_id
    WHERE (p_doctor_id IS NOT NULL OR c.owner_id = v_owner_id)
      AND (p_clinic_id IS NULL OR p.clinic_id = p_clinic_id)
      AND (p_doctor_id IS NULL OR p.doctor_id = p_doctor_id)
      AND (p_start_date IS NULL OR p.created_at >= p_start_date)
      AND (p_end_date IS NULL OR p.created_at <= p_end_date)
    GROUP BY 1
    HAVING COUNT(*) > 1
    ORDER BY repeat_count DESC
  ) rd;

  -- 9. مدى وصول الدواء للمرضى الفريدين
  SELECT COALESCE(jsonb_agg(pr), '[]'::jsonb) INTO v_patient_reach
  FROM (
    SELECT 
      COALESCE(d.trade_name, 'دواء') as drug_name,
      COUNT(DISTINCT p.patient_id)::int as unique_patients,
      COUNT(*)::int as total_prescribed_count
    FROM prescription_items pi
    JOIN prescriptions p ON p.id = pi.prescription_id
    JOIN clinics c ON c.id = p.clinic_id
    LEFT JOIN drugs d ON d.id = pi.drug_id
    WHERE (p_doctor_id IS NOT NULL OR c.owner_id = v_owner_id)
      AND (p_clinic_id IS NULL OR p.clinic_id = p_clinic_id)
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





-- ────────────────────────────────────────────────────────
-- RPC Function: get_financial_receivables_report_rpc
-- حساب تقرير المستحقات المالية وتحليل أعمار الديون وقائمة المرضى المديونين
-- ────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION get_financial_receivables_report_rpc(
    p_owner_id UUID DEFAULT NULL,
    p_clinic_id UUID DEFAULT NULL,
    p_doctor_id UUID DEFAULT NULL,
    p_start_date TIMESTAMPTZ DEFAULT NULL,
    p_end_date TIMESTAMPTZ DEFAULT NULL
)
RETURNS JSONB AS $$
DECLARE
    v_total_receivables NUMERIC := 0.0;
    v_issued_invoices_pending NUMERIC := 0.0;
    v_unbilled_visits_amount NUMERIC := 0.0;
    v_debtor_patients_count INT := 0;

    v_under_7 NUMERIC := 0.0;
    v_days_7_30 NUMERIC := 0.0;
    v_over_30 NUMERIC := 0.0;

    v_debtors JSONB := '[]'::jsonb;
    v_result JSONB;
BEGIN
    -- 1. المبالغ المعلقة من الفواتير الصادرة المرتبطة بمواعيد أو الفواتير المستقلة
    -- المتبقي الفعلي على أي موعد = سعر الموعد - مجموع كافة المدفوعات المسجلة في فواتير هذا الموعد
    WITH appt_invoices AS (
        SELECT 
            source_id,
            COALESCE(SUM(paid_amount), 0.0) AS total_paid,
            COUNT(id) AS inv_count
        FROM invoices
        WHERE source_id IS NOT NULL
        GROUP BY source_id
    ),
    appointment_debts AS (
        SELECT 
            a.patient_id,
            CASE WHEN COALESCE(ai.inv_count, 0) > 0 THEN (COALESCE(a.price, 0.0) - COALESCE(ai.total_paid, 0.0)) ELSE 0.0 END AS issued_debt,
            CASE WHEN COALESCE(ai.inv_count, 0) = 0 THEN (COALESCE(a.price, 0.0) - COALESCE(ai.total_paid, 0.0)) ELSE 0.0 END AS unbilled_debt,
            CASE WHEN COALESCE(ai.inv_count, 0) = 0 THEN 1 ELSE 0 END AS unbilled_count,
            a.created_at AS max_date
        FROM appointments a
        LEFT JOIN clinics c ON c.id = a.clinic_id
        LEFT JOIN appt_invoices ai ON ai.source_id = a.id
        WHERE (p_owner_id IS NULL OR c.owner_id = p_owner_id)
          AND (p_clinic_id IS NULL OR a.clinic_id = p_clinic_id)
          AND (p_doctor_id IS NULL OR a.doctor_id = p_doctor_id)
          AND (p_start_date IS NULL OR a.created_at >= p_start_date)
          AND (p_end_date IS NULL OR a.created_at <= p_end_date)
          AND a.status != 'cancelled'
          AND (COALESCE(a.price, 0.0) - COALESCE(ai.total_paid, 0.0)) > 0.01
    ),
    standalone_invoices AS (
        SELECT 
            inv.patient_id,
            (inv.total_amount - inv.paid_amount) AS issued_debt,
            0.0 AS unbilled_debt,
            0 AS unbilled_count,
            inv.created_at AS max_date
        FROM invoices inv
        LEFT JOIN clinics c ON c.id = inv.clinic_id
        WHERE (inv.source_id IS NULL OR inv.source_type != 'appointment')
          AND (p_owner_id IS NULL OR c.owner_id = p_owner_id)
          AND (p_clinic_id IS NULL OR inv.clinic_id = p_clinic_id)
          AND (p_doctor_id IS NULL OR inv.doctor_id = p_doctor_id)
          AND (p_start_date IS NULL OR inv.created_at >= p_start_date)
          AND (p_end_date IS NULL OR inv.created_at <= p_end_date)
          AND (inv.total_amount - inv.paid_amount) > 0.01
    ),
    all_debts AS (
        SELECT * FROM appointment_debts
        UNION ALL
        SELECT * FROM standalone_invoices
    )
    SELECT 
        COALESCE(SUM(issued_debt), 0.0),
        COALESCE(SUM(unbilled_debt), 0.0),
        COALESCE(SUM(issued_debt + unbilled_debt), 0.0)
    INTO v_issued_invoices_pending, v_unbilled_visits_amount, v_total_receivables
    FROM all_debts;

    -- 2. تجميع قائمة المرضى المديونين
    WITH appt_invoices AS (
        SELECT 
            source_id,
            COALESCE(SUM(paid_amount), 0.0) AS total_paid,
            COUNT(id) AS inv_count
        FROM invoices
        WHERE source_id IS NOT NULL
        GROUP BY source_id
    ),
    appointment_debts AS (
        SELECT 
            a.patient_id,
            CASE WHEN COALESCE(ai.inv_count, 0) > 0 THEN (COALESCE(a.price, 0.0) - COALESCE(ai.total_paid, 0.0)) ELSE 0.0 END AS issued_debt,
            CASE WHEN COALESCE(ai.inv_count, 0) = 0 THEN (COALESCE(a.price, 0.0) - COALESCE(ai.total_paid, 0.0)) ELSE 0.0 END AS unbilled_debt,
            CASE WHEN COALESCE(ai.inv_count, 0) = 0 THEN 1 ELSE 0 END AS unbilled_count,
            a.created_at AS max_date
        FROM appointments a
        LEFT JOIN clinics c ON c.id = a.clinic_id
        LEFT JOIN appt_invoices ai ON ai.source_id = a.id
        WHERE (p_owner_id IS NULL OR c.owner_id = p_owner_id)
          AND (p_clinic_id IS NULL OR a.clinic_id = p_clinic_id)
          AND (p_doctor_id IS NULL OR a.doctor_id = p_doctor_id)
          AND (p_start_date IS NULL OR a.created_at >= p_start_date)
          AND (p_end_date IS NULL OR a.created_at <= p_end_date)
          AND a.status != 'cancelled'
          AND (COALESCE(a.price, 0.0) - COALESCE(ai.total_paid, 0.0)) > 0.01
    ),
    standalone_invoices AS (
        SELECT 
            inv.patient_id,
            (inv.total_amount - inv.paid_amount) AS issued_debt,
            0.0 AS unbilled_debt,
            0 AS unbilled_count,
            inv.created_at AS max_date
        FROM invoices inv
        LEFT JOIN clinics c ON c.id = inv.clinic_id
        WHERE (inv.source_id IS NULL OR inv.source_type != 'appointment')
          AND (p_owner_id IS NULL OR c.owner_id = p_owner_id)
          AND (p_clinic_id IS NULL OR inv.clinic_id = p_clinic_id)
          AND (p_doctor_id IS NULL OR inv.doctor_id = p_doctor_id)
          AND (p_start_date IS NULL OR inv.created_at >= p_start_date)
          AND (p_end_date IS NULL OR inv.created_at <= p_end_date)
          AND (inv.total_amount - inv.paid_amount) > 0.01
    ),
    all_debts AS (
        SELECT * FROM appointment_debts
        UNION ALL
        SELECT * FROM standalone_invoices
    ),
    aggregated_patients AS (
        SELECT 
            ad.patient_id,
            p.name AS patient_name,
            p.phone AS patient_phone,
            SUM(ad.issued_debt) AS total_issued_debt,
            SUM(ad.unbilled_debt) AS total_unbilled_debt,
            SUM(ad.unbilled_count) AS total_unbilled_count,
            (SUM(ad.issued_debt) + SUM(ad.unbilled_debt)) AS total_due,
            MAX(ad.max_date) AS last_activity_date
        FROM all_debts ad
        LEFT JOIN patients p ON p.id = ad.patient_id
        WHERE ad.patient_id IS NOT NULL
        GROUP BY ad.patient_id, p.name, p.phone
        HAVING (SUM(ad.issued_debt) + SUM(ad.unbilled_debt)) > 0.01
    )
    SELECT 
        COUNT(*),
        COALESCE(
            jsonb_agg(
                jsonb_build_object(
                    'patient_id', ap.patient_id,
                    'patient_name', ap.patient_name,
                    'patient_phone', ap.patient_phone,
                    'issued_pending_amount', ap.total_issued_debt,
                    'unbilled_amount', ap.total_unbilled_debt,
                    'unbilled_visits_count', ap.total_unbilled_count,
                    'total_due', ap.total_due,
                    'last_visit_date', ap.last_activity_date
                )
                ORDER BY ap.total_due DESC
            ),
            '[]'::jsonb
        )
    INTO v_debtor_patients_count, v_debtors
    FROM aggregated_patients ap;

    -- 3. تحليل أعمار الديون (Aging Analysis)
    WITH appt_invoices AS (
        SELECT source_id, COALESCE(SUM(paid_amount), 0.0) AS total_paid, COUNT(id) AS inv_count
        FROM invoices WHERE source_id IS NOT NULL GROUP BY source_id
    ),
    all_debts AS (
        SELECT a.patient_id, (COALESCE(a.price, 0.0) - COALESCE(ai.total_paid, 0.0)) AS total_due, a.created_at AS max_date
        FROM appointments a LEFT JOIN clinics c ON c.id = a.clinic_id LEFT JOIN appt_invoices ai ON ai.source_id = a.id
        WHERE (p_owner_id IS NULL OR c.owner_id = p_owner_id) AND (p_clinic_id IS NULL OR a.clinic_id = p_clinic_id)
          AND (p_doctor_id IS NULL OR a.doctor_id = p_doctor_id) AND (p_start_date IS NULL OR a.created_at >= p_start_date)
          AND (p_end_date IS NULL OR a.created_at <= p_end_date) AND a.status != 'cancelled'
          AND (COALESCE(a.price, 0.0) - COALESCE(ai.total_paid, 0.0)) > 0.01
        UNION ALL
        SELECT inv.patient_id, (inv.total_amount - inv.paid_amount) AS total_due, inv.created_at AS max_date
        FROM invoices inv LEFT JOIN clinics c ON c.id = inv.clinic_id
        WHERE (inv.source_id IS NULL OR inv.source_type != 'appointment') AND (p_owner_id IS NULL OR c.owner_id = p_owner_id)
          AND (p_clinic_id IS NULL OR inv.clinic_id = p_clinic_id) AND (p_doctor_id IS NULL OR inv.doctor_id = p_doctor_id)
          AND (p_start_date IS NULL OR inv.created_at >= p_start_date) AND (p_end_date IS NULL OR inv.created_at <= p_end_date)
          AND (inv.total_amount - inv.paid_amount) > 0.01
    )
    SELECT 
        COALESCE(SUM(CASE WHEN (NOW() - last_activity_date) <= INTERVAL '7 days' THEN total_due ELSE 0 END), 0.0),
        COALESCE(SUM(CASE WHEN (NOW() - last_activity_date) > INTERVAL '7 days' AND (NOW() - last_activity_date) <= INTERVAL '30 days' THEN total_due ELSE 0 END), 0.0),
        COALESCE(SUM(CASE WHEN (NOW() - last_activity_date) > INTERVAL '30 days' THEN total_due ELSE 0 END), 0.0)
    INTO v_under_7, v_days_7_30, v_over_30
    FROM (
        SELECT ad.patient_id, SUM(ad.total_due) AS total_due, MAX(ad.max_date) AS last_activity_date
        FROM all_debts ad
        GROUP BY ad.patient_id
    ) ag;

    v_result := jsonb_build_object(
        'total_receivables', v_total_receivables,
        'issued_invoices_pending', v_issued_invoices_pending,
        'unbilled_visits_amount', v_unbilled_visits_amount,
        'debtor_patients_count', v_debtor_patients_count,
        'aging', jsonb_build_object(
            'under_7_days', v_under_7,
            'days_7_to_30', v_days_7_30,
            'over_30_days', v_over_30
        ),
        'debtors', v_debtors
    );

    RETURN v_result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
$$;



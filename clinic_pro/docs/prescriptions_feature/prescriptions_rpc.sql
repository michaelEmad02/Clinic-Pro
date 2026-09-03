-- ==============================================================================
-- دالة جلب الروشتات السريعة والمجمعة عبر السيرفر (get_all_prescriptions_rpc)
-- [نسخة محدثة ومحمية أمنياً: تمنع الأطباء من رؤية روشتات زملائهم وتلزمهم بروشتاتهم فقط]
-- ==============================================================================

CREATE OR REPLACE FUNCTION public.get_all_prescriptions_rpc(
  p_clinic_id uuid DEFAULT NULL,
  p_doctor_id uuid DEFAULT NULL,
  p_patient_id uuid DEFAULT NULL,
  p_limit int DEFAULT 200,
  p_offset int DEFAULT 0
) RETURNS jsonb AS $$
DECLARE
  v_effective_doctor_id uuid := p_doctor_id;
  v_is_doctor boolean := false;
  v_result jsonb := '[]'::jsonb;
BEGIN
  -- 1. التحقق الصريح من تسجيل الدخول
  IF auth.uid() IS NULL THEN
    RETURN '[]'::jsonb;
  END IF;

  -- 2. التحقق مما إذا كان المستخدم الحالي طبيباً
  SELECT EXISTS (
    SELECT 1 FROM public.clinic_staff 
    WHERE user_id = auth.uid() AND role = 'doctor'
  ) INTO v_is_doctor;

  -- 3. إذا كان المستدعي طبيباً، يتم إجباره فقط على رؤية روشتاته الشخصية لمنع أي اختراق
  IF v_is_doctor THEN
    v_effective_doctor_id := auth.uid();
  END IF;

  SELECT COALESCE(jsonb_agg(
    jsonb_build_object(
      'id', sub.id,
      'created_at', sub.created_at,
      'clinic_id', sub.clinic_id,
      'doctor_id', sub.doctor_id,
      'patient_id', sub.patient_id,
      'appointment_id', sub.appointment_id,
      'diagnosis', sub.diagnosis,
      'notes', sub.notes,
      'next_visit_days', sub.next_visit_days,
      'patients', (
        SELECT jsonb_build_object(
          'id', pt.id,
          'name', pt.name,
          'phone', pt.phone,
          'gender', pt.gender,
          'date_of_birth', pt.date_of_birth
        )
        FROM patients pt
        WHERE pt.id = sub.patient_id
      ),
      'prescription_items', COALESCE((
        SELECT jsonb_agg(
          jsonb_build_object(
            'id', pi.id,
            'prescription_id', pi.prescription_id,
            'drug_id', pi.drug_id,
            'frequency', pi.frequency,
            'duration', pi.duration,
            'timing', pi.timing,
            'is_prn', COALESCE(pi.is_prn, false),
            'drug', (
              SELECT jsonb_build_object(
                'id', d.id,
                'trade_name', d.trade_name,
                'generic_name', d.generic_name,
                'category', d.category
              )
              FROM drugs d
              WHERE d.id = pi.drug_id
            )
          )
        )
        FROM prescription_items pi
        WHERE pi.prescription_id = sub.id
      ), '[]'::jsonb)
    )
  ), '[]'::jsonb)
  INTO v_result
  FROM (
    SELECT p.*
    FROM prescriptions p
    WHERE (p_clinic_id IS NULL OR p.clinic_id = p_clinic_id)
      AND (v_effective_doctor_id IS NULL OR p.doctor_id = v_effective_doctor_id)
      AND (p_patient_id IS NULL OR p.patient_id = p_patient_id)
      AND public.is_clinic_member(p.clinic_id)
    ORDER BY p.created_at DESC
    LIMIT p_limit OFFSET p_offset
  ) sub;

  RETURN v_result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

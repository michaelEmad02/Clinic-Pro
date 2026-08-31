-- ==============================================================================
-- دالة جلب الروشتات السريعة والمجمعة عبر السيرفر (get_all_prescriptions_rpc)
-- تقوم بجلب تفاصيل الروشتات مرتبة تنازلياً حسب تاريخ الإنشاء (created_at DESC)
-- مع بيانات المرضى وعناصر الأدوية في استعلام JSON واحد عالي الأداء
-- ==============================================================================

CREATE OR REPLACE FUNCTION get_all_prescriptions_rpc(
  p_clinic_id uuid DEFAULT NULL,
  p_doctor_id uuid DEFAULT NULL,
  p_patient_id uuid DEFAULT NULL,
  p_limit int DEFAULT 200,
  p_offset int DEFAULT 0
) RETURNS jsonb AS $$
DECLARE
  v_result jsonb := '[]'::jsonb;
BEGIN
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
      AND (p_doctor_id IS NULL OR p.doctor_id = p_doctor_id)
      AND (p_patient_id IS NULL OR p.patient_id = p_patient_id)
    ORDER BY p.created_at DESC
    LIMIT p_limit OFFSET p_offset
  ) sub;

  RETURN v_result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

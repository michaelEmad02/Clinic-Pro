-- ────────────────────────────────────────────────────────
-- دالة RPC لجلب المواعيد بكافة تفاصيلها دفعة واحدة وبسرعة فائقة
-- ────────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION get_enriched_appointments_rpc(
    p_clinic_id UUID DEFAULT NULL,
    p_doctor_id UUID DEFAULT NULL,
    p_date DATE DEFAULT NULL,
    p_status VARCHAR DEFAULT NULL,
    p_appointment_id UUID DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_results JSONB;
BEGIN
    SELECT COALESCE(
        jsonb_agg(
            jsonb_build_object(
                'id', a.id,
                'clinic_id', a.clinic_id,
                'doctor_id', a.doctor_id,
                'patient_id', a.patient_id,
                'type_id', a.type_id,
                'date', a.date,
                'time', a.time,
                'status', a.status,
                'price', a.price,
                'notes', a.notes,
                'is_urgent', a.is_urgent,
                'arrived_at', a.arrived_at,
                'called_at', a.called_at,
                'created_by', a.created_by,
                'created_by_name', u_creator.name,
                'created_at', a.created_at,
                
                -- بيانات المريض
                'patients', jsonb_build_object(
                    'id', p.id,
                    'name', p.name,
                    'phone', p.phone
                ),
                
                -- بيانات الطبيب
                'users', jsonb_build_object(
                    'id', u.id,
                    'name', u.name
                ),
                
                -- نوع الكشف
                'appointment_types', jsonb_build_object(
                    'id', at.id,
                    'name', at.name
                ),
                
                -- الروشتات المرتبطة
                'prescriptions', COALESCE(
                    (
                        SELECT jsonb_agg(
                            jsonb_build_object(
                                'id', pr.id,
                                'diagnosis', pr.diagnosis
                            )
                        )
                        FROM prescriptions pr
                        WHERE pr.appointment_id = a.id
                    ),
                    '[]'::jsonb
                ),
                
                -- الفواتير المرتبطة
                'invoices', COALESCE(
                    (
                        SELECT jsonb_agg(
                            jsonb_build_object(
                                'id', inv.id,
                                'total_amount', inv.total_amount,
                                'paid_amount', inv.paid_amount,
                                'created_at', inv.created_at,
                                'created_by', inv.created_by,
                                'creator_name', u_inv.name
                            )
                        )
                        FROM invoices inv
                        LEFT JOIN users u_inv ON u_inv.id = inv.created_by
                        WHERE inv.source_id = a.id
                    ),
                    '[]'::jsonb
                ),
                
                -- الأدوية الموصوفة
                'prescription_drugs', COALESCE(
                    (
                        SELECT jsonb_agg(
                            jsonb_build_object(
                                'id', pi.id,
                                'prescription_id', pi.prescription_id,
                                'drug_id', pi.drug_id,
                                'frequency', pi.frequency,
                                'duration', pi.duration,
                                'is_prn', pi.is_prn,
                                'timing', pi.timing,
                                'drugs', jsonb_build_object(
                                    'id', d.id,
                                    'trade_name', d.trade_name,
                                    'generic_name', d.generic_name,
                                    'category', d.category
                                )
                            )
                        )
                        FROM prescriptions pr
                        JOIN prescription_items pi ON pi.prescription_id = pr.id
                        LEFT JOIN drugs d ON d.id = pi.drug_id
                        WHERE pr.appointment_id = a.id
                    ),
                    '[]'::jsonb
                )
            )
            ORDER BY 
                a.is_urgent DESC,
                a.arrived_at ASC NULLS LAST,
                a.time ASC NULLS LAST,
                a.created_at ASC
        ),
        '[]'::jsonb
    ) INTO v_results
    FROM appointments a
    LEFT JOIN patients p ON p.id = a.patient_id
    LEFT JOIN users u ON u.id = a.doctor_id
    LEFT JOIN users u_creator ON u_creator.id = a.created_by
    LEFT JOIN doctor_appointment_types dat ON dat.id = a.type_id
    LEFT JOIN appointment_types at ON at.id = dat.appointment_type_id
    WHERE (p_clinic_id IS NULL OR a.clinic_id = p_clinic_id)
      AND (p_doctor_id IS NULL OR a.doctor_id = p_doctor_id)
      AND (p_date IS NULL OR a.date = p_date)
      AND (p_status IS NULL OR a.status::TEXT = p_status::TEXT)
      AND (p_appointment_id IS NULL OR a.id = p_appointment_id);

    RETURN v_results;
END;
$$;


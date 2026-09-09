// ────────────────────────────────────────────────────────
// واجهة مصدر البيانات السحابي للسجلات الطبية
// ────────────────────────────────────────────────────────

import 'dart:io';
import '../models/medical_record_model.dart';

abstract class IMedicalRecordsRemoteDataSource {
  /// جلب سجلات المريض مع إمكانية الفلترة
  Future<List<MedicalRecordModel>> getMedicalRecords({
    required String patientId,
    String? type,
  });

  /// جلب سجلات زيارة معينة
  Future<List<MedicalRecordModel>> getRecordsForAppointment({
    required String appointmentId,
  });

  /// رفع الفحص الطبي وتخزينه في Supabase
  Future<MedicalRecordModel> uploadMedicalRecord({
    required String clinicId,
    required String patientId,
    String? doctorId,
    String? appointmentId,
    String? prescriptionId,
    required String type,
    required String title,
    required File imageFile,
    required String recordDate,
    String? notes,
  });

  /// حذف فحص طبي وملفه
  Future<void> deleteMedicalRecord({
    required String recordId,
    required String storagePath,
  });
}

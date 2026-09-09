// ────────────────────────────────────────────────────────
// واجهة مستودع السجلات الطبية (IMedicalRecordsRepository)
// ────────────────────────────────────────────────────────

import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/medical_record_entity.dart';

abstract class IMedicalRecordsRepository {
  /// جلب سجلات وفحوصات مريض معين، مع إمكانية الفلترة بنوع الفحص (تحليل / أشعة)
  Future<Either<Failure, List<MedicalRecordEntity>>> getMedicalRecords({
    required String patientId,
    String? type,
  });

  /// جلب الفحوصات المرتبطة بزيارة/كشف معين
  Future<Either<Failure, List<MedicalRecordEntity>>> getRecordsForAppointment({
    required String appointmentId,
  });

  /// رفع فحص طبي جديد (تحليل / أشعة) وتخزينه
  Future<Either<Failure, MedicalRecordEntity>> uploadMedicalRecord({
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

  /// حذف فحص طبي من قاعدة البيانات وحذف صورته من التخزين السحابي
  Future<Either<Failure, void>> deleteMedicalRecord({
    required String recordId,
    required String storagePath,
  });
}

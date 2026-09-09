// ────────────────────────────────────────────────────────
// حالة استخدام رفع فحص طبي جديد (تحليل / أشعة)
// ────────────────────────────────────────────────────────

import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/medical_record_entity.dart';
import '../repositories/i_medical_records_repository.dart';

@injectable
class UploadMedicalRecordUseCase {
  final IMedicalRecordsRepository _repository;

  UploadMedicalRecordUseCase(this._repository);

  Future<Either<Failure, MedicalRecordEntity>> call({
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
  }) {
    return _repository.uploadMedicalRecord(
      clinicId: clinicId,
      patientId: patientId,
      doctorId: doctorId,
      appointmentId: appointmentId,
      prescriptionId: prescriptionId,
      type: type,
      title: title,
      imageFile: imageFile,
      recordDate: recordDate,
      notes: notes,
    );
  }
}

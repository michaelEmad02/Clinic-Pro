// ────────────────────────────────────────────────────────
// حالة استخدام جلب السجلات والفحوصات الطبية لمريض
// ────────────────────────────────────────────────────────

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/medical_record_entity.dart';
import '../repositories/i_medical_records_repository.dart';

@injectable
class GetMedicalRecordsUseCase {
  final IMedicalRecordsRepository _repository;

  GetMedicalRecordsUseCase(this._repository);

  Future<Either<Failure, List<MedicalRecordEntity>>> call({
    required String patientId,
    String? type,
  }) {
    return _repository.getMedicalRecords(
      patientId: patientId,
      type: type,
    );
  }
}

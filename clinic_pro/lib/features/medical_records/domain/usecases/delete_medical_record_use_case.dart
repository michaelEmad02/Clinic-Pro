// ────────────────────────────────────────────────────────
// حالة استخدام حذف فحص طبي
// ────────────────────────────────────────────────────────

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/i_medical_records_repository.dart';

@injectable
class DeleteMedicalRecordUseCase {
  final IMedicalRecordsRepository _repository;

  DeleteMedicalRecordUseCase(this._repository);

  Future<Either<Failure, void>> call({
    required String recordId,
    required String storagePath,
  }) {
    return _repository.deleteMedicalRecord(
      recordId: recordId,
      storagePath: storagePath,
    );
  }
}

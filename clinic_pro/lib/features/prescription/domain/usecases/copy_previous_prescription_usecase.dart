// ────────────────────────────────────────────────────────
// حالة استخدام نسخ الروشتة السابقة (CopyPreviousPrescriptionUseCase)
// ────────────────────────────────────────────────────────

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/prescription_entity.dart';
import '../repositories/i_prescription_repository.dart';

@injectable
class CopyPreviousPrescriptionUseCase {
  final IPrescriptionRepository _repository;

  CopyPreviousPrescriptionUseCase(this._repository);

  Future<Either<Failure, (List<PrescriptionItemEntity>, List<String>)>> call(
    String patientId,
  ) {
    return _repository.copyPreviousPrescription(patientId);
  }
}

// ────────────────────────────────────────────────────────
// حالة استخدام حفظ الروشتة (SavePrescriptionUseCase)
// ────────────────────────────────────────────────────────

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/prescription_entity.dart';
import '../repositories/i_prescription_repository.dart';

@injectable
class SavePrescriptionUseCase {
  final IPrescriptionRepository _repository;

  SavePrescriptionUseCase(this._repository);

  Future<Either<Failure, void>> call(PrescriptionEntity prescription, String doctorId) {
    if (prescription.items.isEmpty) {
      return Future.value(const Left(ValidationFailure('يجب إضافة دواء واحد على الأقل للروشتة')));
    }
    for (final item in prescription.items) {
      if (!item.isPrn && (item.frequency == null || item.duration == null)) {
        return Future.value(const Left(ValidationFailure('يرجى تحديد الجرعة والمدة لجميع الأدوية')));
      }
      if (item.timing == null || item.timing!.isEmpty) {
        return Future.value(const Left(ValidationFailure('يرجى تحديد توقيت تناول الجرعة لجميع الأدوية')));
      }
    }
    return _repository.savePrescription(prescription, doctorId);
  }
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

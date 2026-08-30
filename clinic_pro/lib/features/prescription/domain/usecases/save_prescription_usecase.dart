// ────────────────────────────────────────────────────────
// حالة استخدام حفظ الروشتة (SavePrescriptionUseCase)
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/strings/failure_strings.dart';
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
      return Future.value(const Left(AtLeastOneDrugRequiredFailure()));
    }
    for (final item in prescription.items) {
      if (!item.isPrn && (item.frequency == null || item.duration == null)) {
        return Future.value(const Left(FrequencyAndDurationRequiredFailure()));
      }
      if (item.timing == null || item.timing!.isEmpty) {
        return Future.value(const Left(DoseTimingRequiredFailure()));
      }
    }
    return _repository.savePrescription(prescription, doctorId);
  }
}

class ValidationFailure extends Failure {
  const ValidationFailure([super.customMessage]);
}

class AtLeastOneDrugRequiredFailure extends Failure {
  const AtLeastOneDrugRequiredFailure([super.customMessage]);

  @override
  String get defaultMessage => FailureStrings.atLeastOneDrugRequired;
}

class FrequencyAndDurationRequiredFailure extends Failure {
  const FrequencyAndDurationRequiredFailure([super.customMessage]);

  @override
  String get defaultMessage => FailureStrings.frequencyAndDurationRequired;
}

class DoseTimingRequiredFailure extends Failure {
  const DoseTimingRequiredFailure([super.customMessage]);

  @override
  String get defaultMessage => FailureStrings.doseTimingRequired;
}

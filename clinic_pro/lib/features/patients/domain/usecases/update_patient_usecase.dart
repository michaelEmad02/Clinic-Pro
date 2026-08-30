// ────────────────────────────────────────────────────────
// حالة استخدام تحديث بيانات مريض (UpdatePatientUseCase)
// ────────────────────────────────────────────────────────

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/patient_entity.dart';
import '../repositories/i_patients_repository.dart';
import 'add_patient_usecase.dart';

@injectable
class UpdatePatientUseCase {
  final IPatientsRepository _repository;

  UpdatePatientUseCase(this._repository);

  Future<Either<Failure, PatientEntity>> call(PatientEntity patient) async {
    // التحقق من الاسم — مطلوب ولا يقل عن حرفين
    if (patient.name.trim().length < 2) {
      return const Left(
        PatientNameRequiredFailure(),
      );
    }

    // التحقق من الجنس — مطلوب
    if (patient.gender.isEmpty) {
      return const Left(
        PatientGenderRequiredFailure(),
      );
    }

    return _repository.updatePatient(patient);
  }
}

class UpdatePatientFailure extends Failure {
  const UpdatePatientFailure([super.customMessage]);
}

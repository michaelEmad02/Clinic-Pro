// ────────────────────────────────────────────────────────
// حالة استخدام حذف مريض (DeletePatientUseCase)
// ────────────────────────────────────────────────────────

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/i_patients_repository.dart';

@injectable
class DeletePatientUseCase {
  final IPatientsRepository _repository;

  DeletePatientUseCase(this._repository);

  Future<Either<Failure, Unit>> call(String patientId) {
    return _repository.deletePatient(patientId);
  }
}

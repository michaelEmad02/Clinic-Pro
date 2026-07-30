// ────────────────────────────────────────────────────────
// حالة استخدام البحث عن مريض بالمعرف (FindPatientByIdUseCase)
// ────────────────────────────────────────────────────────

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/patient_entity.dart';
import '../repositories/i_patients_repository.dart';

@injectable
class FindPatientByIdUseCase {
  final IPatientsRepository _repository;

  FindPatientByIdUseCase(this._repository);

  Future<Either<Failure, PatientEntity>> call(String patientId) {
    return _repository.getPatientById(patientId);
  }
}

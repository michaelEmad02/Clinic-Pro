// ────────────────────────────────────────────────────────
// حالة استخدام تحميل المرضى (LoadPatientsUseCase)
// جلب قائمة مرضى عيادة محددة
// ────────────────────────────────────────────────────────

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/patient_entity.dart';
import '../repositories/i_patients_repository.dart';

@injectable
class LoadPatientsUseCase {
  final IPatientsRepository _repository;

  LoadPatientsUseCase(this._repository);

  Future<Either<Failure, List<PatientEntity>>> call({
    required String clinicId,
  }) {
    return _repository.getPatients(clinicId: clinicId);
  }
}

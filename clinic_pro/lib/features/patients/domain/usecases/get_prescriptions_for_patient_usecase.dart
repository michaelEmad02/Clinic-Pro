// ────────────────────────────────────────────────────────
// حالة استخدام جلب روشتات المريض (GetPrescriptionsForPatientUseCase)
// تتبع الـ Patients Feature وتجلب كافة الروشتات الطبية السابقة الصادرة للمريض
// ────────────────────────────────────────────────────────

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../prescription/domain/entities/prescription_entity.dart';
import '../repositories/i_patients_repository.dart';

@injectable
class GetPrescriptionsForPatientUseCase {
  final IPatientsRepository _repository;

  GetPrescriptionsForPatientUseCase(this._repository);

  Future<Either<Failure, List<PrescriptionEntity>>> call(String patientId) {
    return _repository.getPrescriptionsForPatient(patientId);
  }
}

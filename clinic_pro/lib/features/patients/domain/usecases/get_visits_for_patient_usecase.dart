// ────────────────────────────────────────────────────────
// حالة استخدام جلب زيارات مريض (GetVisitsForPatientUseCase)
// يجلب المواعيد المرتبطة بمريض محدد عبر كل عيادات المالك
// يستخدم AppointmentEntity من feature المواعيد
// ────────────────────────────────────────────────────────

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../appointments/domain/entities/appointment_entity.dart';
import '../repositories/i_patients_repository.dart';

@injectable
class GetVisitsForPatientUseCase {
  final IPatientsRepository _repository;

  GetVisitsForPatientUseCase(this._repository);

  Future<Either<Failure, List<AppointmentEntity>>> call(String patientId) {
    return _repository.getVisitsForPatient(patientId);
  }
}

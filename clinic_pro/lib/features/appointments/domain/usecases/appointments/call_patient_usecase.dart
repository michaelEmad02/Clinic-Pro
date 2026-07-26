// ────────────────────────────────────────────────────────
// حالة استخدام استدعاء المريض (CallPatientUseCase)
// ────────────────────────────────────────────────────────

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../../core/error/failures.dart';
import '../../repositories/i_appointment_repository.dart';

@injectable
class CallPatientUseCase {
  final IAppointmentRepository _repository;

  CallPatientUseCase(this._repository);

  Future<Either<Failure, Unit>> call(String appointmentId) {
    return _repository.callPatient(appointmentId);
  }
}

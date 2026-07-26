// ────────────────────────────────────────────────────────
// حالة استخدام إلغاء الموعد (CancelAppointmentUseCase)
// ────────────────────────────────────────────────────────

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../../core/error/failures.dart';
import '../../repositories/i_appointment_repository.dart';

@injectable
class CancelAppointmentUseCase {
  final IAppointmentRepository _repository;

  CancelAppointmentUseCase(this._repository);

  Future<Either<Failure, Unit>> call(String appointmentId) {
    return _repository.cancelAppointment(appointmentId);
  }
}

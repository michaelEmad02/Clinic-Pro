// ────────────────────────────────────────────────────────
// حالة استخدام حذف الموعد (DeleteAppointmentUseCase)
// ────────────────────────────────────────────────────────

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../../core/error/failures.dart';
import '../../repositories/i_appointment_repository.dart';

@injectable
class DeleteAppointmentUseCase {
  final IAppointmentRepository _repository;

  DeleteAppointmentUseCase(this._repository);

  Future<Either<Failure, Unit>> call(String appointmentId) {
    return _repository.deleteAppointment(appointmentId);
  }
}

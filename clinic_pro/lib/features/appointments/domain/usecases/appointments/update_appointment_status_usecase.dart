// ────────────────────────────────────────────────────────
// حالة استخدام تحديث حالة الموعد (UpdateAppointmentStatusUseCase)
// ────────────────────────────────────────────────────────

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../../core/error/failures.dart';
import '../../repositories/i_appointment_repository.dart';

@injectable
class UpdateAppointmentStatusUseCase {
  final IAppointmentRepository _repository;

  UpdateAppointmentStatusUseCase(this._repository);

  Future<Either<Failure, Unit>> call({
    required String appointmentId,
    required String newStatus,
  }) {
    return _repository.updateStatus(
      appointmentId: appointmentId,
      newStatus: newStatus,
    );
  }
}

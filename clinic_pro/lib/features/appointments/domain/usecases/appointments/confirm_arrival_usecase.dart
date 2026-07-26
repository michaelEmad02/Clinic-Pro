// ────────────────────────────────────────────────────────
// حالة استخدام تأكيد وصول المريض (ConfirmArrivalUseCase)
// ────────────────────────────────────────────────────────

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../../core/error/failures.dart';
import '../../repositories/i_appointment_repository.dart';

@injectable
class ConfirmArrivalUseCase {
  final IAppointmentRepository _repository;

  ConfirmArrivalUseCase(this._repository);

  Future<Either<Failure, Unit>> call(String appointmentId) {
    return _repository.confirmArrival(appointmentId);
  }
}

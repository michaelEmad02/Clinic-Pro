// ────────────────────────────────────────────────────────
// حالة استخدام تعديل موعد (UpdateAppointmentUseCase)
// ────────────────────────────────────────────────────────

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../../core/error/failures.dart';
import '../../entities/appointment_entity.dart';
import '../../repositories/i_appointment_repository.dart';

@injectable
class UpdateAppointmentUseCase {
  final IAppointmentRepository _repository;

  UpdateAppointmentUseCase(this._repository);

  Future<Either<Failure, Unit>> call(AppointmentEntity appointment) async {
    if (appointment.id.isEmpty) {
      return const Left(UpdateAppointmentFailure('معرف الموعد مطلوب لتعديله'));
    }
    return _repository.updateAppointment(appointment);
  }
}

class UpdateAppointmentFailure extends Failure {
  const UpdateAppointmentFailure(super.message);
}

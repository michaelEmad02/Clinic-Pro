// ────────────────────────────────────────────────────────
// حالة استخدام جلب موعد بمعرفه (GetAppointmentByIdUseCase)
// ────────────────────────────────────────────────────────

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../../core/error/failures.dart';
import '../../entities/appointment_entity.dart';
import '../../repositories/i_appointment_repository.dart';

@injectable
class GetAppointmentByIdUseCase {
  final IAppointmentRepository _repository;

  GetAppointmentByIdUseCase(this._repository);

  Future<Either<Failure, AppointmentEntity>> call(String appointmentId) {
    return _repository.getAppointmentById(appointmentId);
  }
}

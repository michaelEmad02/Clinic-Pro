// ────────────────────────────────────────────────────────
// حالة استخدام تغيير حالة الاستعجال (ToggleUrgentUseCase)
// ────────────────────────────────────────────────────────

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../../core/error/failures.dart';
import '../../repositories/i_appointment_repository.dart';

@injectable
class ToggleUrgentUseCase {
  final IAppointmentRepository _repository;

  ToggleUrgentUseCase(this._repository);

  Future<Either<Failure, Unit>> call({
    required String appointmentId,
    required bool isUrgent,
  }) {
    return _repository.toggleUrgent(
      appointmentId: appointmentId,
      isUrgent: isUrgent,
    );
  }
}

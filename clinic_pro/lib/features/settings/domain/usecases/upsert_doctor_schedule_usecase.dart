// ────────────────────────────────────────────────────────
// UseCase: حفظ وتعديل موعد عمل للطبيب
// ────────────────────────────────────────────────────────

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/doctor_schedule_entity.dart';
import '../repositories/i_settings_repository.dart';

@injectable
class UpsertDoctorScheduleUseCase {
  final ISettingsRepository _repository;
  UpsertDoctorScheduleUseCase(this._repository);

  Future<Either<Failure, Unit>> call(List<DoctorScheduleEntity> schedule) {
    return _repository.upsertDoctorSchedule(schedule);
  }
}

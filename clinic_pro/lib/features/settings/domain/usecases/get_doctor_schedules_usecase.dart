// ────────────────────────────────────────────────────────
// UseCase: جلب مواعيد وساعات عمل الطبيب
// ────────────────────────────────────────────────────────

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/doctor_schedule_entity.dart';
import '../repositories/i_settings_repository.dart';

@injectable
class GetDoctorSchedulesUseCase {
  final ISettingsRepository _repository;
  GetDoctorSchedulesUseCase(this._repository);

  Future<Either<Failure, List<DoctorScheduleEntity>>> call({
    required String doctorId,
    required String clinicId,
  }) {
    return _repository.getDoctorSchedules(
      doctorId: doctorId,
      clinicId: clinicId,
    );
  }
}

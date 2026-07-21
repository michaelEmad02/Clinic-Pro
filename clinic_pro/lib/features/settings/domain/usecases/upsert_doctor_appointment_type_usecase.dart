// ────────────────────────────────────────────────────────
// UseCase: إضافة أو تحديث تسعيرة زيارة لطبيب بالعيادة
// ────────────────────────────────────────────────────────

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/doctor_appointment_type_entity.dart';
import '../repositories/i_settings_repository.dart';

@injectable
class UpsertDoctorAppointmentTypeUseCase {
  final ISettingsRepository _repository;
  UpsertDoctorAppointmentTypeUseCase(this._repository);

  Future<Either<Failure, Unit>> call(DoctorAppointmentTypeEntity typePrice) {
    return _repository.upsertDoctorAppointmentType(typePrice);
  }
}

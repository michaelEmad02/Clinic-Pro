// ────────────────────────────────────────────────────────
// UseCase: مزامنة تسعيرات زيارات الطبيب (حذف وإعادة إدخال)
// ────────────────────────────────────────────────────────

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/doctor_appointment_type_entity.dart';
import '../repositories/i_settings_repository.dart';

@injectable
class SyncDoctorAppointmentTypesUseCase {
  final ISettingsRepository _repository;
  SyncDoctorAppointmentTypesUseCase(this._repository);

  Future<Either<Failure, Unit>> call({
    required String doctorId,
    required String clinicId,
    required List<DoctorAppointmentTypeEntity> types,
  }) {
    return _repository.syncDoctorAppointmentTypes(
      doctorId: doctorId,
      clinicId: clinicId,
      types: types,
    );
  }
}

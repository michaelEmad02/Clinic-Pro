// ────────────────────────────────────────────────────────
// UseCase: جلب تسعيرة وأنواع زيارات الطبيب بالعيادة
// ────────────────────────────────────────────────────────

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/doctor_appointment_type_entity.dart';
import '../repositories/i_settings_repository.dart';

@injectable
class GetDoctorAppointmentTypesUseCase {
  final ISettingsRepository _repository;
  GetDoctorAppointmentTypesUseCase(this._repository);

  Future<Either<Failure, List<DoctorAppointmentTypeEntity>>> call({
    required String doctorId,
    required String clinicId,
  }) {
    return _repository.getDoctorAppointmentTypes(
      doctorId: doctorId,
      clinicId: clinicId,
    );
  }
}

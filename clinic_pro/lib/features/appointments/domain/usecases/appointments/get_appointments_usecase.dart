// ────────────────────────────────────────────────────────
// حالة استخدام جلب المواعيد (GetAppointmentsUseCase)
// جلب قائمة المواعيد لعيادة محددة مع إمكانية الفلترة
// ────────────────────────────────────────────────────────

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../../core/error/failures.dart';
import '../../entities/appointment_entity.dart';
import '../../repositories/i_appointment_repository.dart';

@injectable
class GetAppointmentsUseCase {
  final IAppointmentRepository _repository;

  GetAppointmentsUseCase(this._repository);

  Future<Either<Failure, List<AppointmentEntity>>> call(GetAppointmentsParams params) {
    return _repository.getAppointments(
      clinicId: params.clinicId,
      doctorId: params.doctorId,
      date: params.date,
      status: params.status,
    );
  }
}

class GetAppointmentsParams {
  final String clinicId;
  final String? doctorId;
  final String? date;
  final String? status;

  const GetAppointmentsParams({
    required this.clinicId,
    this.doctorId,
    this.date,
    this.status,
  });
}

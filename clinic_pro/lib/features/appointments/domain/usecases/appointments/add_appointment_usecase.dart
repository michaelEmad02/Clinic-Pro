// ────────────────────────────────────────────────────────
// حالة استخدام إضافة موعد جديد (AddAppointmentUseCase)
// يتحقق من صحة المدخلات ويقوم بإرسال الكيان للمستودع لحفظه
// ────────────────────────────────────────────────────────

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../../core/error/failures.dart';
import '../../entities/appointment_entity.dart';
import '../../repositories/i_appointment_repository.dart';

@injectable
class AddAppointmentUseCase {
  final IAppointmentRepository _repository;

  AddAppointmentUseCase(this._repository);

  Future<Either<Failure, AppointmentEntity>> call(AppointmentEntity appointment) async {
    if (appointment.patientId.isEmpty) {
      return const Left(AddAppointmentFailure('معرف المريض مطلوب لإضافة موعد'));
    }
    if (appointment.doctorId.isEmpty) {
      return const Left(AddAppointmentFailure('معرف الطبيب مطلوب لإضافة موعد'));
    }
    if (appointment.typeId.isEmpty) {
      return const Left(AddAppointmentFailure('نوع الموعد مطلوب لإضافة موعد'));
    }
    if (appointment.date.isEmpty) {
      return const Left(AddAppointmentFailure('تاريخ الموعد مطلوب لإضافة موعد'));
    }

    return _repository.addAppointment(appointment);
  }
}

class AddAppointmentFailure extends Failure {
  const AddAppointmentFailure(super.message);
}

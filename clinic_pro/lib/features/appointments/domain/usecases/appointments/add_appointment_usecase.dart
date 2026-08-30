// ────────────────────────────────────────────────────────
// حالة استخدام إضافة موعد جديد (AddAppointmentUseCase)
// يتحقق من صحة المدخلات ويقوم بإرسال الكيان للمستودع لحفظه
// ────────────────────────────────────────────────────────

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../../core/error/failures.dart';
import '../../../../../../core/strings/failure_strings.dart';
import '../../entities/appointment_entity.dart';
import '../../repositories/i_appointment_repository.dart';

@injectable
class AddAppointmentUseCase {
  final IAppointmentRepository _repository;

  AddAppointmentUseCase(this._repository);

  Future<Either<Failure, AppointmentEntity>> call(AppointmentEntity appointment) async {
    if (appointment.patientId.isEmpty) {
      return const Left(PatientIdRequiredFailure());
    }
    if (appointment.doctorId.isEmpty) {
      return const Left(DoctorIdRequiredFailure());
    }
    if (appointment.typeId.isEmpty) {
      return const Left(TypeIdRequiredFailure());
    }
    if (appointment.date.isEmpty) {
      return const Left(DateRequiredFailure());
    }

    return _repository.addAppointment(appointment);
  }
}

class AddAppointmentFailure extends Failure {
  const AddAppointmentFailure([super.customMessage]);
}

class PatientIdRequiredFailure extends Failure {
  const PatientIdRequiredFailure([super.customMessage]);

  @override
  String get defaultMessage => FailureStrings.patientIdRequired;
}

class DoctorIdRequiredFailure extends Failure {
  const DoctorIdRequiredFailure([super.customMessage]);

  @override
  String get defaultMessage => FailureStrings.doctorIdRequired;
}

class TypeIdRequiredFailure extends Failure {
  const TypeIdRequiredFailure([super.customMessage]);

  @override
  String get defaultMessage => FailureStrings.typeIdRequired;
}

class DateRequiredFailure extends Failure {
  const DateRequiredFailure([super.customMessage]);

  @override
  String get defaultMessage => FailureStrings.dateRequired;
}

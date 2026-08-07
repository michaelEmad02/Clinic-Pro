import 'package:injectable/injectable.dart';

import '../../entities/appointment_entity.dart';
import '../../repositories/i_appointment_repository.dart';

@lazySingleton
class SubscribeAppointmentsUseCase {
  final IAppointmentRepository _repository;

  SubscribeAppointmentsUseCase(this._repository);

  Stream<List<AppointmentEntity>> call({
    required String clinicId,
    String? doctorId,
  }) {
    return _repository.subscribeAppointments(
      clinicId: clinicId,
      doctorId: doctorId,
    );
  }
}

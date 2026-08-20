import 'package:equatable/equatable.dart';
import '../../../appointments/domain/entities/appointment_entity.dart';

class SecretaryDashboardDataEntity extends Equatable {
  final String secretaryName;
  final String clinicName;
  final String doctorName;
  final List<AppointmentEntity> liveQueue;
  final int todayAppointmentsCount;
  final int completedCount;
  final int waitingCount;
  final String avgWaitingTime;

  const SecretaryDashboardDataEntity({
    required this.secretaryName,
    required this.clinicName,
    required this.doctorName,
    required this.liveQueue,
    required this.todayAppointmentsCount,
    required this.completedCount,
    required this.waitingCount,
    required this.avgWaitingTime,
  });

  @override
  List<Object?> get props => [
        secretaryName,
        clinicName,
        doctorName,
        liveQueue,
        todayAppointmentsCount,
        completedCount,
        waitingCount,
        avgWaitingTime,
      ];
}

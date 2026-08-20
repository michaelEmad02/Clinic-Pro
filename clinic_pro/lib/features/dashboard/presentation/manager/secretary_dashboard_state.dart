// ─────────────────────────────────────────
// هذا الملف يحتوي على حالات لوحة تحكم السكرتير
// ─────────────────────────────────────────

import 'package:equatable/equatable.dart';
import '../../../appointments/domain/entities/appointment_entity.dart';

abstract class SecretaryDashboardState extends Equatable {
  const SecretaryDashboardState();

  @override
  List<Object?> get props => [];
}

class SecretaryDashboardInitial extends SecretaryDashboardState {}

class SecretaryDashboardLoading extends SecretaryDashboardState {}

class SecretaryDashboardLoaded extends SecretaryDashboardState {
  final String secretaryName;
  final String clinicName;
  final String doctorName;
  final List<AppointmentEntity> liveQueue;
  final int todayAppointmentsCount;
  final int completedCount;
  final int waitingCount;
  final String avgWaitingTime;

  const SecretaryDashboardLoaded({
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

class SecretaryDashboardError extends SecretaryDashboardState {
  final String message;

  const SecretaryDashboardError(this.message);

  @override
  List<Object?> get props => [message];
}

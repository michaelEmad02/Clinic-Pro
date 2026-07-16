// ─────────────────────────────────────────
// هذا الملف يحتوي على حالات لوحة تحكم السكرتير
// ─────────────────────────────────────────

import 'package:equatable/equatable.dart';
import '../../../appointments/presentation/manager/appointments_state.dart';

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
  final List<AppointmentItem> liveQueue;
  final String totalInvoiced;
  final String totalCollected;
  final int totalAppointmentsCount;

  const SecretaryDashboardLoaded({
    required this.secretaryName,
    required this.clinicName,
    required this.doctorName,
    required this.liveQueue,
    required this.totalInvoiced,
    required this.totalCollected,
    required this.totalAppointmentsCount,
  });

  @override
  List<Object?> get props => [
        secretaryName,
        clinicName,
        doctorName,
        liveQueue,
        totalInvoiced,
        totalCollected,
        totalAppointmentsCount,
      ];
}

class SecretaryDashboardError extends SecretaryDashboardState {
  final String message;

  const SecretaryDashboardError(this.message);

  @override
  List<Object?> get props => [message];
}

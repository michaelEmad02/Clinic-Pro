import 'package:equatable/equatable.dart';

class AppointmentMock extends Equatable {
  final String id;
  final String patientName;
  final String doctorName;
  final String time;
  final String type; // 'normal', 'urgent'
  final String status; // 'scheduled', 'confirmed', 'in_progress', 'done', 'cancelled'

  const AppointmentMock({
    required this.id,
    required this.patientName,
    required this.doctorName,
    required this.time,
    required this.type,
    required this.status,
  });

  @override
  List<Object?> get props => [id, patientName, doctorName, time, type, status];
}

abstract class SecretaryDashboardState extends Equatable {
  const SecretaryDashboardState();

  @override
  List<Object?> get props => [];
}

class SecretaryDashboardInitial extends SecretaryDashboardState {}

class SecretaryDashboardLoading extends SecretaryDashboardState {}

class SecretaryDashboardLoaded extends SecretaryDashboardState {
  final String secretaryName;
  final List<AppointmentMock> liveQueue;
  final List<AppointmentMock> todayAppointments;
  final String totalInvoiced;
  final String totalCollected;
  final int totalAppointmentsCount;

  const SecretaryDashboardLoaded({
    required this.secretaryName,
    required this.liveQueue,
    required this.todayAppointments,
    required this.totalInvoiced,
    required this.totalCollected,
    required this.totalAppointmentsCount,
  });

  @override
  List<Object?> get props => [
        secretaryName,
        liveQueue,
        todayAppointments,
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

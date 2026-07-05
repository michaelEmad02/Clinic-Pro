import 'package:equatable/equatable.dart';
import '../../../appointments/presentation/manager/appointments_state.dart';

abstract class DoctorDashboardState extends Equatable {
  const DoctorDashboardState();

  @override
  List<Object?> get props => [];
}

class DoctorDashboardInitial extends DoctorDashboardState {}

class DoctorDashboardLoading extends DoctorDashboardState {}

class DoctorDashboardLoaded extends DoctorDashboardState {
  final String doctorName;
  final String clinicName;
  final AppointmentItem? currentPatient;
  final List<AppointmentItem> waitingQueue;
  final int completedCount;
  final int waitingCount;
  final String avgWaitingTime; // e.g. "١٥ دقيقة"

  const DoctorDashboardLoaded({
    required this.doctorName,
    required this.clinicName,
    this.currentPatient,
    required this.waitingQueue,
    required this.completedCount,
    required this.waitingCount,
    required this.avgWaitingTime,
  });

  @override
  List<Object?> get props => [
        doctorName,
        clinicName,
        currentPatient,
        waitingQueue,
        completedCount,
        waitingCount,
        avgWaitingTime,
      ];
}

class DoctorDashboardError extends DoctorDashboardState {
  final String message;

  const DoctorDashboardError(this.message);

  @override
  List<Object?> get props => [message];
}


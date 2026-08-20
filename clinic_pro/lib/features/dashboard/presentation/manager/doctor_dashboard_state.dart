import 'package:equatable/equatable.dart';
import '../../../appointments/domain/entities/appointment_entity.dart';

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
  final AppointmentEntity? currentPatient;
  final List<AppointmentEntity> waitingQueue;
  final int todayAppointmentsCount;
  final int completedCount;
  final int waitingCount;
  final String avgWaitingTime; // e.g. "١٥ دقيقة"
  final double todayRevenue;
  final double collectedAmount;

  const DoctorDashboardLoaded({
    required this.doctorName,
    required this.clinicName,
    this.currentPatient,
    required this.waitingQueue,
    required this.todayAppointmentsCount,
    required this.completedCount,
    required this.waitingCount,
    required this.avgWaitingTime,
    required this.todayRevenue,
    required this.collectedAmount,
  });

  @override
  List<Object?> get props => [
        doctorName,
        clinicName,
        currentPatient,
        waitingQueue,
        todayAppointmentsCount,
        completedCount,
        waitingCount,
        avgWaitingTime,
        todayRevenue,
        collectedAmount,
      ];
}

class DoctorDashboardError extends DoctorDashboardState {
  final String message;

  const DoctorDashboardError(this.message);

  @override
  List<Object?> get props => [message];
}

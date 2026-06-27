import 'package:equatable/equatable.dart';

class PatientMock extends Equatable {
  final String id;
  final String name;
  final String age;
  final String condition; // e.g. "متابعة ضغط الدم"
  final String type; // 'normal', 'urgent'
  final String time;

  const PatientMock({
    required this.id,
    required this.name,
    required this.age,
    required this.condition,
    required this.type,
    required this.time,
  });

  @override
  List<Object?> get props => [id, name, age, condition, type, time];
}

abstract class DoctorDashboardState extends Equatable {
  const DoctorDashboardState();

  @override
  List<Object?> get props => [];
}

class DoctorDashboardInitial extends DoctorDashboardState {}

class DoctorDashboardLoading extends DoctorDashboardState {}

class DoctorDashboardLoaded extends DoctorDashboardState {
  final String doctorName;
  final PatientMock? currentPatient;
  final List<PatientMock> waitingQueue;
  final int completedCount;
  final int waitingCount;
  final String avgWaitingTime; // e.g. "١٥ دقيقة"

  const DoctorDashboardLoaded({
    required this.doctorName,
    this.currentPatient,
    required this.waitingQueue,
    required this.completedCount,
    required this.waitingCount,
    required this.avgWaitingTime,
  });

  @override
  List<Object?> get props => [
        doctorName,
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

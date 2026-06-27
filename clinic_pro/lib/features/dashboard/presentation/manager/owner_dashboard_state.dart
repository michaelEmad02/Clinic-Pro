import 'package:equatable/equatable.dart';

class ClinicMock extends Equatable {
  final String id;
  final String name;
  final String location;
  final int doctorsCount;
  final int patientsCount;
  final bool isActive;

  const ClinicMock({
    required this.id,
    required this.name,
    required this.location,
    required this.doctorsCount,
    required this.patientsCount,
    required this.isActive,
  });

  @override
  List<Object?> get props => [id, name, location, doctorsCount, patientsCount, isActive];
}

class DashboardAlertMock extends Equatable {
  final String id;
  final String title;
  final String message;
  final String type; // 'warning', 'info'

  const DashboardAlertMock({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
  });

  @override
  List<Object?> get props => [id, title, message, type];
}

abstract class OwnerDashboardState extends Equatable {
  const OwnerDashboardState();

  @override
  List<Object?> get props => [];
}

class OwnerDashboardInitial extends OwnerDashboardState {}

class OwnerDashboardLoading extends OwnerDashboardState {}

class OwnerDashboardLoaded extends OwnerDashboardState {
  final String ownerName;
  final String totalRevenue;
  final int totalPatients;
  final int todayAppointments;
  final int activeClinics;
  final List<ClinicMock> clinics;
  final List<DashboardAlertMock> alerts;
  final List<double> weeklyRevenue; // 7 days of revenue starting from Sun to Sat

  const OwnerDashboardLoaded({
    required this.ownerName,
    required this.totalRevenue,
    required this.totalPatients,
    required this.todayAppointments,
    required this.activeClinics,
    required this.clinics,
    required this.alerts,
    required this.weeklyRevenue,
  });

  @override
  List<Object?> get props => [
        ownerName,
        totalRevenue,
        totalPatients,
        todayAppointments,
        activeClinics,
        clinics,
        alerts,
        weeklyRevenue,
      ];
}

class OwnerDashboardError extends OwnerDashboardState {
  final String message;

  const OwnerDashboardError(this.message);

  @override
  List<Object?> get props => [message];
}

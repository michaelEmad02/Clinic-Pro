// ───────────── حالات تفاصيل المريض ─────────────

import 'package:clinic_pro/features/appointments/domain/entities/appointment_entity.dart';
import 'package:clinic_pro/features/patients/domain/entities/patient_entity.dart';
import 'package:equatable/equatable.dart';

abstract class PatientDetailsState extends Equatable {
  const PatientDetailsState();

  @override
  List<Object?> get props => [];
}

class PatientDetailsInitial extends PatientDetailsState {}

class PatientDetailsLoading extends PatientDetailsState {}

class PatientDetailsLoaded extends PatientDetailsState {
  final PatientEntity patient;
  final List<AppointmentEntity> visits;
  final bool visitsLoading;

  const PatientDetailsLoaded({
    required this.patient,
    this.visits = const [],
    this.visitsLoading = false,
  });

  PatientDetailsLoaded copyWith({
    PatientEntity? patient,
    List<AppointmentEntity>? visits,
    bool? visitsLoading,
  }) {
    return PatientDetailsLoaded(
      patient: patient ?? this.patient,
      visits: visits ?? this.visits,
      visitsLoading: visitsLoading ?? this.visitsLoading,
    );
  }

  @override
  List<Object?> get props => [patient, visits, visitsLoading];
}

class PatientDetailsError extends PatientDetailsState {
  final String message;

  const PatientDetailsError(this.message);

  @override
  List<Object?> get props => [message];
}

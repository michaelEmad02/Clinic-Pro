// ────────────────────────────────────────────────────────
// حالات تبويب روشتات المريض (PatientPrescriptionsState)
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/features/prescription/domain/entities/prescription_entity.dart';
import 'package:equatable/equatable.dart';

abstract class PatientPrescriptionsState extends Equatable {
  const PatientPrescriptionsState();

  @override
  List<Object?> get props => [];
}

class PatientPrescriptionsInitial extends PatientPrescriptionsState {}

class PatientPrescriptionsLoading extends PatientPrescriptionsState {}

class PatientPrescriptionsLoaded extends PatientPrescriptionsState {
  final List<PrescriptionEntity> prescriptions;

  const PatientPrescriptionsLoaded(this.prescriptions);

  @override
  List<Object?> get props => [prescriptions];
}

class PatientPrescriptionsError extends PatientPrescriptionsState {
  final String message;

  const PatientPrescriptionsError(this.message);

  @override
  List<Object?> get props => [message];
}

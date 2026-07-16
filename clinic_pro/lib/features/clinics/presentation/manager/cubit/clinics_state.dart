// ────────────────────────────────────────────────────────
// حالات شاشة العيادات
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/features/clinics/domain/entities/clinic_entity.dart';
import 'package:equatable/equatable.dart';

abstract class ClinicsState extends Equatable {
  const ClinicsState();

  @override
  List<Object?> get props => [];
}

class ClinicsInitial extends ClinicsState {}

class ClinicsLoading extends ClinicsState {}

class ClinicsLoaded extends ClinicsState {
  final List<ClinicEntity> clinics;

  const ClinicsLoaded({required this.clinics});

  @override
  List<Object?> get props => [clinics];
}

class ClinicsError extends ClinicsState {
  final String message;

  const ClinicsError(this.message);

  @override
  List<Object?> get props => [message];
}

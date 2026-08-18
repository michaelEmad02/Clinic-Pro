// ─────────────────────────────────────────
// حالات Cubit قائمة عيادات المالك النشطة
// ─────────────────────────────────────────

import 'package:equatable/equatable.dart';
import '../../domain/entities/clinic_summary_entity.dart';

abstract class OwnerClinicsScrollState extends Equatable {
  const OwnerClinicsScrollState();

  @override
  List<Object?> get props => [];
}

class OwnerClinicsScrollInitial extends OwnerClinicsScrollState {}

class OwnerClinicsScrollLoading extends OwnerClinicsScrollState {}

class OwnerClinicsScrollLoaded extends OwnerClinicsScrollState {
  final List<ClinicSummaryEntity> clinics;

  const OwnerClinicsScrollLoaded(this.clinics);

  @override
  List<Object?> get props => [clinics];
}

class OwnerClinicsScrollError extends OwnerClinicsScrollState {
  final String message;

  const OwnerClinicsScrollError(this.message);

  @override
  List<Object?> get props => [message];
}

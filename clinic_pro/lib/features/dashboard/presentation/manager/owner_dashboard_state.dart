// ─────────────────────────────────────────
// حالات OwnerDashboardCubit
// تحتوي على الحالات المختلفة: Initial, Loading, Loaded, Error
// ─────────────────────────────────────────

import 'package:equatable/equatable.dart';
import '../../domain/entities/owner_dashboard_entity.dart';

abstract class OwnerDashboardState extends Equatable {
  const OwnerDashboardState();

  @override
  List<Object?> get props => [];
}

class OwnerDashboardInitial extends OwnerDashboardState {}

class OwnerDashboardLoading extends OwnerDashboardState {}

class OwnerDashboardLoaded extends OwnerDashboardState {
  final OwnerDashboardEntity dashboard;

  const OwnerDashboardLoaded({required this.dashboard});

  @override
  List<Object?> get props => [dashboard];
}

class OwnerDashboardError extends OwnerDashboardState {
  final String message;

  const OwnerDashboardError(this.message);

  @override
  List<Object?> get props => [message];
}

// ─────────────────────────────────────────
// حالات Cubit التنبيهات الذكية للمالك
// ─────────────────────────────────────────

import 'package:equatable/equatable.dart';
import '../../domain/entities/dashboard_alert_entity.dart';

abstract class OwnerAlertsState extends Equatable {
  const OwnerAlertsState();

  @override
  List<Object?> get props => [];
}

class OwnerAlertsInitial extends OwnerAlertsState {}

class OwnerAlertsLoading extends OwnerAlertsState {}

class OwnerAlertsLoaded extends OwnerAlertsState {
  final List<DashboardAlertEntity> alerts;

  const OwnerAlertsLoaded(this.alerts);

  @override
  List<Object?> get props => [alerts];
}

class OwnerAlertsError extends OwnerAlertsState {
  final String message;

  const OwnerAlertsError(this.message);

  @override
  List<Object?> get props => [message];
}

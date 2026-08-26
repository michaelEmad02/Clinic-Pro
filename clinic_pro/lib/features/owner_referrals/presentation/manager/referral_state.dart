// ─────────────────────────────────────────────────────────────────────────────
// حالات إدارة حالة إحالات الملاك (Referral State)
// ─────────────────────────────────────────────────────────────────────────────

import 'package:equatable/equatable.dart';
import 'package:clinic_pro/features/owner_referrals/domain/entities/referral_dashboard_entity.dart';

abstract class ReferralState extends Equatable {
  const ReferralState();

  @override
  List<Object?> get props => [];
}

class ReferralInitial extends ReferralState {}

class ReferralLoading extends ReferralState {}

class ReferralDashboardLoaded extends ReferralState {
  final ReferralDashboardEntity dashboard;

  const ReferralDashboardLoaded(this.dashboard);

  @override
  List<Object?> get props => [dashboard];
}

class ReferralError extends ReferralState {
  final String message;

  const ReferralError(this.message);

  @override
  List<Object?> get props => [message];
}

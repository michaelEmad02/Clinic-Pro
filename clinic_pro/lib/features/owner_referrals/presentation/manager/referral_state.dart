import 'package:equatable/equatable.dart';
import 'package:clinic_pro/features/owner_referrals/domain/entities/apply_referral_result_entity.dart';
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

class ApplyReferralCodeSuccess extends ReferralState {
  final ApplyReferralResultEntity result;

  const ApplyReferralCodeSuccess(this.result);

  @override
  List<Object?> get props => [result];
}

class ReferralError extends ReferralState {
  final String message;

  const ReferralError(this.message);

  @override
  List<Object?> get props => [message];
}

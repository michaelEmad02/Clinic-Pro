// ─────────────────────────────────────────────────────────────────────────────
// مدير حالة إحالات الملاك (Referral Cubit)
// يدير جلب بيانات لوحة تحكم الدعوات والمحطات المفتوحة والمتبقية
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:clinic_pro/features/owner_referrals/domain/entities/referral_dashboard_entity.dart';
import 'package:clinic_pro/features/owner_referrals/domain/usecases/owner_referral_usecases.dart';
import 'package:clinic_pro/features/owner_referrals/presentation/manager/referral_state.dart';

@injectable
class ReferralCubit extends Cubit<ReferralState> {
  final GetReferralDashboardUseCase _getReferralDashboardUseCase;
  final ApplyReferralCodeOnRegistrationUseCase _applyReferralCodeUseCase;

  ReferralDashboardEntity? _dashboard;
  ReferralDashboardEntity? get dashboard => _dashboard;

  ReferralCubit(
    this._getReferralDashboardUseCase,
    this._applyReferralCodeUseCase,
  ) : super(ReferralInitial());

  /// جلب لوحة بيانات الدعوات والمحطات للمالك
  Future<void> loadReferralDashboard(String ownerId) async {
    emit(ReferralLoading());
    final result = await _getReferralDashboardUseCase(ownerId);
    result.fold(
      (failure) => emit(ReferralError(failure.message)),
      (dashboardData) {
        _dashboard = dashboardData;
        emit(ReferralDashboardLoaded(dashboardData));
      },
    );
  }

  /// تطبيق كود دعوة عند تسجيل مالك جديد
  Future<bool> applyReferralCode({
    required String referralCode,
    required String newOwnerId,
  }) async {
    final result = await _applyReferralCodeUseCase(
      referralCode: referralCode,
      newOwnerId: newOwnerId,
    );

    return result.fold(
      (failure) {
        emit(ReferralError(failure.message));
        return false;
      },
      (_) => true,
    );
  }
}

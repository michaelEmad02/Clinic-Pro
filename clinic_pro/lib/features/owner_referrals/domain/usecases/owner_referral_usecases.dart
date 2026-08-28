// ─────────────────────────────────────────────────────────────────────────────
// حالات استخدام نظام الإحالات والمكافآت (Owner Referral UseCases)
// ─────────────────────────────────────────────────────────────────────────────

import 'package:clinic_pro/core/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:clinic_pro/features/owner_referrals/domain/entities/apply_referral_result_entity.dart';
import 'package:clinic_pro/features/owner_referrals/domain/entities/referral_dashboard_entity.dart';
import 'package:clinic_pro/features/owner_referrals/domain/repositories/owner_referral_repository.dart';

/// حالة استخدام جلب لوحة إحصائيات ومحطات الدعوات للمالك
@lazySingleton
class GetReferralDashboardUseCase {
  final IOwnerReferralRepository _repository;

  GetReferralDashboardUseCase(this._repository);

  Future<Either<Failure, ReferralDashboardEntity>> call(String ownerId) {
    return _repository.getReferralDashboard(ownerId);
  }
}

/// حالة استخدام تطبيق كود الدعوة عند تسجيل طبيب جديد
@lazySingleton
class ApplyReferralCodeOnRegistrationUseCase {
  final IOwnerReferralRepository _repository;

  ApplyReferralCodeOnRegistrationUseCase(this._repository);

  Future<Either<Failure, ApplyReferralResultEntity>> call({
    required String referralCode,
    required String newOwnerId,
  }) {
    return _repository.applyReferralCodeOnRegistration(
      referralCode: referralCode,
      newOwnerId: newOwnerId,
    );
  }
}

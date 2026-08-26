// ─────────────────────────────────────────────────────────────────────────────
// ملف واجهة مستودع إحالات الملاك (Owner Referral Repository Interface)
// ─────────────────────────────────────────────────────────────────────────────

import 'package:clinic_pro/core/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:clinic_pro/features/owner_referrals/domain/entities/referral_dashboard_entity.dart';

abstract class IOwnerReferralRepository {
  /// جلب لوحة بيانات إحالات المالك والمحطات المحققة والقادمة من السيرفر
  Future<Either<Failure, ReferralDashboardEntity>> getReferralDashboard(String ownerId);

  /// تسجيل واستخدام كود دعوة عند تسجيل مالك عيادة جديد
  Future<Either<Failure, void>> applyReferralCodeOnRegistration({
    required String referralCode,
    required String newOwnerId,
  });
}

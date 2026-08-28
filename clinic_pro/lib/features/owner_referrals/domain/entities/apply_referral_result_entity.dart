// ─────────────────────────────────────────────────────────────────────────────
// كيان نتيجة تطبيق كود الإحالة عند التسجيل (Apply Referral Result Entity)
// ─────────────────────────────────────────────────────────────────────────────

import 'package:equatable/equatable.dart';
import 'package:clinic_pro/core/constants/supabase_constants.dart';

class ApplyReferralResultEntity extends Equatable {
  final bool success;
  final String message;
  final String triggerEvent; // 'after_register' | 'after_subscription'
  final CouponRewardType rewardType; // 'free_days' | 'free_month' | 'discount_percent' | 'fixed_amount'
  final double rewardValue;
  final String? couponCode;

  const ApplyReferralResultEntity({
    required this.success,
    required this.message,
    required this.triggerEvent,
    required this.rewardType,
    required this.rewardValue,
    this.couponCode,
  });

  /// هل تمنح المكافأة أياماً أو شهوراً مجانية؟ (100% Free Plan)
  bool get isFreePeriodReward =>
      rewardType == CouponRewardType.freeDays ||
      rewardType == CouponRewardType.freeMonth;

  /// هل تمنح المكافأة خصماً مالياً أو نسبة مئوية؟
  bool get isDiscountReward =>
      rewardType == CouponRewardType.discountPercent ||
      rewardType == CouponRewardType.fixedAmount;

  @override
  List<Object?> get props => [
        success,
        message,
        triggerEvent,
        rewardType,
        rewardValue,
        couponCode,
      ];
}

// ─────────────────────────────────────────────────────────────────────────────
// نموذج نتيجة التحقق من الكوبون (Coupon Validation Result Model)
// ─────────────────────────────────────────────────────────────────────────────

import 'package:clinic_pro/core/constants/supabase_constants.dart';
import 'package:clinic_pro/features/coupons/domain/entities/coupon_validation_result_entity.dart';

class CouponValidationResultModel extends CouponValidationResultEntity {
  const CouponValidationResultModel({
    required super.isValid,
    super.message,
    super.couponId,
    super.code,
    super.rewardType,
    super.rewardValue,
    required super.originalAmount,
    required super.discountAmount,
    required super.finalAmount,
    super.description,
    super.freeDaysGranted = 0,
    super.hasActiveSubscription = false,
  });

  /// تحويل كائن JSON القادم من دالة السيرفر `validate_coupon`
  factory CouponValidationResultModel.fromJson(Map<String, dynamic> json) {
    return CouponValidationResultModel(
      isValid: json['is_valid'] as bool? ?? false,
      message: json['message'] as String?,
      couponId: json['coupon_id'] as String?,
      code: json['code'] as String?,
      rewardType: _mapRewardType(json['reward_type'] as String?),
      rewardValue: (json['reward_value'] as num?)?.toDouble(),
      originalAmount: (json['original_amount'] as num?)?.toDouble() ?? 0.0,
      discountAmount: (json['discount_amount'] as num?)?.toDouble() ?? 0.0,
      finalAmount: (json['final_amount'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] as String?,
      freeDaysGranted: (json['free_days_granted'] as num?)?.toInt() ?? 0,
      hasActiveSubscription: json['has_active_subscription'] as bool? ?? false,
    );
  }

  static CouponRewardType? _mapRewardType(String? type) {
    if (type == null) return null;
    switch (type) {
      case 'discount_percent':
        return CouponRewardType.discountPercent;
      case 'fixed_amount':
        return CouponRewardType.fixedAmount;
      case 'free_month':
        return CouponRewardType.freeMonth;
      case 'free_days':
        return CouponRewardType.freeDays;
      default:
        return null;
    }
  }
}

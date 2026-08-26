// ─────────────────────────────────────────────────────────────────────────────
// ملف نتيجة التحقق من الكوبون من السيرفر (Coupon Validation Result Entity)
// يمثل الاستجابة الآمنة من دالة السيرفر (RPC validate_coupon)
// السيرفر يجلب السعر الأصلي ويحسب الخصم والمبلغ النهائي
// ─────────────────────────────────────────────────────────────────────────────

import 'package:equatable/equatable.dart';
import 'package:clinic_pro/core/constants/supabase_constants.dart';

/// كيان نتيجة فحص الكوبون وحساب الخصم بالسيرفر
class CouponValidationResultEntity extends Equatable {
  final bool isValid;
  final String? message;
  final String? couponId;
  final String? code;
  final CouponRewardType? rewardType;
  final double? rewardValue;
  final double originalAmount;
  final double discountAmount;
  final double finalAmount;
  final String? description;
  final int freeDaysGranted;
  final bool hasActiveSubscription;

  const CouponValidationResultEntity({
    required this.isValid,
    this.message,
    this.couponId,
    this.code,
    this.rewardType,
    this.rewardValue,
    required this.originalAmount,
    required this.discountAmount,
    required this.finalAmount,
    this.description,
    this.freeDaysGranted = 0,
    this.hasActiveSubscription = false,
  });

  /// هل الكوبون يمنح اشتراكاً أو تمديداً مجانياً؟
  bool get isFreeSubscriptionOrExtension =>
      freeDaysGranted > 0 || (isValid && finalAmount == 0.0 && originalAmount > 0);

  @override
  List<Object?> get props => [
        isValid,
        message,
        couponId,
        code,
        rewardType,
        rewardValue,
        originalAmount,
        discountAmount,
        finalAmount,
        description,
        freeDaysGranted,
        hasActiveSubscription,
      ];
}

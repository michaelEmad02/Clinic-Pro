// ─────────────────────────────────────────────────────────────────────────────
// ملف واجهة مستودع الكوبونات (Coupons Repository Interface)
// ─────────────────────────────────────────────────────────────────────────────

import 'package:clinic_pro/core/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:clinic_pro/features/coupons/domain/entities/coupon_entity.dart';
import 'package:clinic_pro/features/coupons/domain/entities/coupon_validation_result_entity.dart';

abstract class ICouponsRepository {
  /// التحقق من صلاحية الكوبون وحساب المبلغ والخصم من السيرفر مباشرة
  Future<Either<Failure, CouponValidationResultEntity>> validateCoupon({
    required String code,
    required String ownerId,
    required String planId,
    String billingCycle = 'monthly',
  });

  /// جلب قائمة الكوبونات المتاحة والصالحة لهذا الطبيب (العامة + الخاصة بإحالاته)
  Future<Either<Failure, List<CouponEntity>>> getAvailableCoupons(String ownerId);

  /// استهلاك وتأكيد تطبيق الكوبون في السيرفر وتفعيل/تمديد الاشتراك
  Future<Either<Failure, void>> redeemCoupon({
    required String couponId,
    required String ownerId,
    String? planId,
    String billingCycle = 'monthly',
    String? transactionId,
  });
}

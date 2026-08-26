// ─────────────────────────────────────────────────────────────────────────────
// حالات استخدام نظام الكوبونات (Coupons UseCases)
// ─────────────────────────────────────────────────────────────────────────────

import 'package:clinic_pro/core/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:clinic_pro/features/coupons/domain/entities/coupon_entity.dart';
import 'package:clinic_pro/features/coupons/domain/entities/coupon_validation_result_entity.dart';
import 'package:clinic_pro/features/coupons/domain/repositories/coupons_repository.dart';

/// حالة استخدام التحقق من الكوبون وحساب الخصم بالسيرفر
@lazySingleton
class ValidateCouponUseCase {
  final ICouponsRepository _repository;

  ValidateCouponUseCase(this._repository);

  Future<Either<Failure, CouponValidationResultEntity>> call({
    required String code,
    required String ownerId,
    required String planId,
    String billingCycle = 'monthly',
  }) {
    return _repository.validateCoupon(
      code: code,
      ownerId: ownerId,
      planId: planId,
      billingCycle: billingCycle,
    );
  }
}

/// حالة استخدام جلب الكوبونات المتاحة للطبيب
@lazySingleton
class GetAvailableCouponsUseCase {
  final ICouponsRepository _repository;

  GetAvailableCouponsUseCase(this._repository);

  Future<Either<Failure, List<CouponEntity>>> call(String ownerId) {
    return _repository.getAvailableCoupons(ownerId);
  }
}

/// حالة استخدام تأكيد واستهلاك الكوبون بالسيرفر وتفعيل/تمديد الاشتراك
@lazySingleton
class RedeemCouponUseCase {
  final ICouponsRepository _repository;

  RedeemCouponUseCase(this._repository);

  Future<Either<Failure, void>> call({
    required String couponId,
    required String ownerId,
    String? planId,
    String billingCycle = 'monthly',
    String? transactionId,
  }) {
    return _repository.redeemCoupon(
      couponId: couponId,
      ownerId: ownerId,
      planId: planId,
      billingCycle: billingCycle,
      transactionId: transactionId,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// حالات إدارة حالة الكوبونات (Coupons State)
// ─────────────────────────────────────────────────────────────────────────────

import 'package:equatable/equatable.dart';
import 'package:clinic_pro/features/coupons/domain/entities/coupon_entity.dart';
import 'package:clinic_pro/features/coupons/domain/entities/coupon_validation_result_entity.dart';

abstract class CouponsState extends Equatable {
  const CouponsState();

  @override
  List<Object?> get props => [];
}

class CouponsInitial extends CouponsState {}

class CouponsLoading extends CouponsState {}

/// حالة توفر قائمة الكوبونات الخاصة والعامة للطبيب
class AvailableCouponsLoaded extends CouponsState {
  final List<CouponEntity> coupons;

  const AvailableCouponsLoaded(this.coupons);

  @override
  List<Object?> get props => [coupons];
}

/// حالة فحص وتطبيق الكوبون
class CouponValidationSuccess extends CouponsState {
  final CouponValidationResultEntity validationResult;

  const CouponValidationSuccess(this.validationResult);

  @override
  List<Object?> get props => [validationResult];
}

class CouponValidationError extends CouponsState {
  final String message;

  const CouponValidationError(this.message);

  @override
  List<Object?> get props => [message];
}

/// حالة نجاح استهلاك الكوبون مباشرة (بدون بوابة دفع)
class CouponRedeemSuccess extends CouponsState {
  final String message;

  const CouponRedeemSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

/// حالة فشل استهلاك الكوبون
class CouponRedeemError extends CouponsState {
  final String message;

  const CouponRedeemError(this.message);

  @override
  List<Object?> get props => [message];
}

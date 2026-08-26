// ─────────────────────────────────────────────────────────────────────────────
// مدير حالة الكوبونات (Coupons Cubit)
// يدير التحقق من الكوبونات وجلب الكوبونات المتاحة للطبيب
// يتم حساب السعر والخصم بالسيرفر مباشرة
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:clinic_pro/features/coupons/domain/entities/coupon_entity.dart';
import 'package:clinic_pro/features/coupons/domain/entities/coupon_validation_result_entity.dart';
import 'package:clinic_pro/features/coupons/domain/usecases/coupon_usecases.dart';
import 'package:clinic_pro/features/coupons/presentation/manager/coupons_state.dart';

@injectable
class CouponsCubit extends Cubit<CouponsState> {
  final ValidateCouponUseCase _validateCouponUseCase;
  final GetAvailableCouponsUseCase _getAvailableCouponsUseCase;
  final RedeemCouponUseCase _redeemCouponUseCase;

  List<CouponEntity> _cachedAvailableCoupons = [];
  List<CouponEntity> get availableCoupons => _cachedAvailableCoupons;

  CouponValidationResultEntity? _appliedCoupon;
  CouponValidationResultEntity? get appliedCoupon => _appliedCoupon;

  CouponsCubit(
    this._validateCouponUseCase,
    this._getAvailableCouponsUseCase,
    this._redeemCouponUseCase,
  ) : super(CouponsInitial());

  // ─────────────────────────────────────────────────────────────────────────
  // هل يجب تخطي بوابة الدفع؟
  // يُستخدم من الـ UI لتحديد المسار بعد التحقق من الكوبون
  // ─────────────────────────────────────────────────────────────────────────
  // الحالات التي نتخطى فيها بوابة الدفع:
  //   1. المكافأة أيام/شهور مجانية (freeDaysGranted > 0)
  //   2. المبلغ النهائي = 0 (خصم 100% أو free)
  // ─────────────────────────────────────────────────────────────────────────
  bool get shouldSkipPaymentGateway {
    if (_appliedCoupon == null || !_appliedCoupon!.isValid) return false;

    // أيام/شهور مجانية → دائماً نتخطى بوابة الدفع
    if (_appliedCoupon!.freeDaysGranted > 0) return true;

    // خصم 100% → المبلغ النهائي = 0
    if (_appliedCoupon!.finalAmount == 0.0) return true;

    return false;
  }

  /// جلب الكوبونات المتاحة للطبيب للتحقق من شرط الظهور (Conditional Visibility)
  Future<void> loadAvailableCoupons(String ownerId) async {
    final result = await _getAvailableCouponsUseCase(ownerId);
    result.fold(
      (failure) {
        _cachedAvailableCoupons = [];
        emit(CouponsInitial());
      },
      (coupons) {
        _cachedAvailableCoupons = coupons;
        emit(AvailableCouponsLoaded(coupons));
      },
    );
  }

  /// التحقق من الكوبون المدخل أو المختار وتطبيقه (حساب السعر والخصم بالسيرفر)
  Future<void> validateAndApplyCoupon({
    required String code,
    required String ownerId,
    required String planId,
    String billingCycle = 'monthly',
  }) async {
    if (code.trim().isEmpty) {
      emit(const CouponValidationError('يرجى إدخال كود الكوبون'));
      return;
    }

    emit(CouponsLoading());

    final result = await _validateCouponUseCase(
      code: code.trim(),
      ownerId: ownerId,
      planId: planId,
      billingCycle: billingCycle,
    );

    result.fold(
      (failure) {
        _appliedCoupon = null;
        emit(CouponValidationError(failure.message));
      },
      (validationResult) {
        if (validationResult.isValid) {
          _appliedCoupon = validationResult;
          emit(CouponValidationSuccess(validationResult));
        } else {
          _appliedCoupon = null;
          emit(CouponValidationError(validationResult.message ?? 'كوبون غير صالح'));
        }
      },
    );
  }

  /// استهلاك الكوبون مباشرة بدون بوابة الدفع
  /// يُستدعى عندما shouldSkipPaymentGateway == true
  /// السيرفر هو من يقوم بتفعيل/تمديد الاشتراك تلقائياً
  Future<void> redeemCouponDirectly({
    required String ownerId,
    String? planId,
    String billingCycle = 'monthly',
  }) async {
    if (_appliedCoupon == null || _appliedCoupon!.couponId == null) {
      emit(const CouponRedeemError('لم يتم تطبيق كوبون بعد'));
      return;
    }

    emit(CouponsLoading());

    final result = await _redeemCouponUseCase(
      couponId: _appliedCoupon!.couponId!,
      ownerId: ownerId,
      planId: planId,
      billingCycle: billingCycle,
    );

    result.fold(
      (failure) => emit(CouponRedeemError(failure.message)),
      (_) {
        final message = _appliedCoupon!.freeDaysGranted > 0
            ? 'تم تفعيل ${_appliedCoupon!.freeDaysGranted} يوم مجاناً بنجاح!'
            : 'تم تفعيل الاشتراك بنجاح!';
        _appliedCoupon = null;
        emit(CouponRedeemSuccess(message));
      },
    );
  }

  /// إزالة الكوبون المطبق
  void removeAppliedCoupon() {
    _appliedCoupon = null;
    emit(CouponsInitial());
  }
}


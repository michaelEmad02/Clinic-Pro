// ─────────────────────────────────────────────────────────────────────────────
// مصدر بيانات الكوبونات عن بُعد (Coupons Remote Data Source)
// ينفذ استدعاءات السيرفر عبر الـ RPCs حصراً لضمان أمان العمليات والأسعار
// ─────────────────────────────────────────────────────────────────────────────

import 'package:injectable/injectable.dart';
import 'package:clinic_pro/core/services/i_cloud_service.dart';
import 'package:clinic_pro/features/coupons/data/models/coupon_model.dart';
import 'package:clinic_pro/features/coupons/data/models/coupon_validation_result_model.dart';

abstract class ICouponsRemoteDataSource {
  Future<CouponValidationResultModel> validateCoupon({
    required String code,
    required String ownerId,
    required String planId,
    String billingCycle = 'monthly',
  });

  Future<List<CouponModel>> getAvailableCoupons(String ownerId);

  Future<void> redeemCoupon({
    required String couponId,
    required String ownerId,
    String? planId,
    String billingCycle = 'monthly',
    String? transactionId,
  });
}

@LazySingleton(as: ICouponsRemoteDataSource)
class CouponsRemoteDataSourceImpl implements ICouponsRemoteDataSource {
  final ICloudService _cloudService;

  CouponsRemoteDataSourceImpl(this._cloudService);

  @override
  Future<CouponValidationResultModel> validateCoupon({
    required String code,
    required String ownerId,
    required String planId,
    String billingCycle = 'monthly',
  }) async {
    final response = await _cloudService.rpc(
      'validate_coupon',
      params: {
        'p_code': code,
        'p_owner_id': ownerId,
        'p_plan_id': planId,
        'p_billing_cycle': billingCycle,
      },
    );

    final data = Map<String, dynamic>.from(response as Map);
    return CouponValidationResultModel.fromJson(data);
  }


  // بترجع الكوبونات الخاصه بمالك معين وليست كوبنات عامه
  @override
  Future<List<CouponModel>> getAvailableCoupons(String ownerId) async {
    final response = await _cloudService.rpc(
      'get_available_coupons_for_owner',
      params: {'p_owner_id': ownerId},
    );

    if (response is List) {
      return response
          .map((item) => CouponModel.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    }
    return [];
  }

  @override
  Future<void> redeemCoupon({
    required String couponId,
    required String ownerId,
    String? planId,
    String billingCycle = 'monthly',
    String? transactionId,
  }) async {
    await _cloudService.rpc(
      'redeem_coupon',
      params: {
        'p_coupon_id': couponId,
        'p_owner_id': ownerId,
        'p_plan_id': planId,
        'p_billing_cycle': billingCycle,
        'p_transaction_id': transactionId,
      },
    );
  }
}

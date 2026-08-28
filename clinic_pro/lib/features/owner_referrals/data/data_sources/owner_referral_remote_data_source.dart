// ─────────────────────────────────────────────────────────────────────────────
// مصدر بيانات الإحالات عن بُعد (Owner Referral Remote Data Source)
// يستدعي دوال الـ RPC من السيرفر لجلب ملخص الدعوات وتسجيل العمليات
// ─────────────────────────────────────────────────────────────────────────────

import 'package:clinic_pro/core/constants/supabase_constants.dart';
import 'package:injectable/injectable.dart';
import 'package:clinic_pro/core/services/i_cloud_service.dart';
import 'package:clinic_pro/features/owner_referrals/data/models/referral_dashboard_model.dart';
import 'package:clinic_pro/features/owner_referrals/domain/entities/apply_referral_result_entity.dart';

abstract class IOwnerReferralRemoteDataSource {
  Future<ReferralDashboardModel> getReferralDashboard(String ownerId);

  Future<ApplyReferralResultEntity> applyReferralCodeOnRegistration({
    required String referralCode,
    required String newOwnerId,
  });
}

@LazySingleton(as: IOwnerReferralRemoteDataSource)
class OwnerReferralRemoteDataSourceImpl implements IOwnerReferralRemoteDataSource {
  final ICloudService _cloudService;

  OwnerReferralRemoteDataSourceImpl(this._cloudService);

  @override
  Future<ReferralDashboardModel> getReferralDashboard(String ownerId) async {
    final response = await _cloudService.rpc(
      'get_owner_referral_dashboard',
      params: {'p_owner_id': ownerId},
    );

    final data = Map<String, dynamic>.from(response as Map);
    return ReferralDashboardModel.fromJson(data);
  }

  @override
  Future<ApplyReferralResultEntity> applyReferralCodeOnRegistration({
    required String referralCode,
    required String newOwnerId,
  }) async {

    final response = await _cloudService.rpc(
      'apply_referral_code_on_registration',
      params: {
        'p_referral_code': referralCode.trim().toUpperCase(),
        'p_referee_owner_id': newOwnerId,
      },
    );

    if (response is Map) {
      final isSuccess = response['success'] as bool? ?? false;
      final message = response['message'] as String? ?? '';
      if (!isSuccess) {
        throw Exception(message.isNotEmpty ? message : 'فشل تطبيق كود الدعوة');
      }

      final rewardTypeStr = response['reward_type'] as String?;
      final rewardValue = (response['reward_value'] as num?)?.toDouble() ?? 0.0;
      final triggerEvent = response['trigger_event'] as String? ?? 'after_subscription';
      final couponCode = response['referee_coupon_code'] as String?;

      return ApplyReferralResultEntity(
        success: true,
        message: message,
        triggerEvent: triggerEvent,
        rewardType: _mapRewardType(rewardTypeStr),
        rewardValue: rewardValue,
        couponCode: couponCode,
      );
    }

    throw Exception('استجابة غير صحيحة من السيرفر');
  }

  static CouponRewardType _mapRewardType(String? type) {
    switch (type) {
      case 'discount_percent':
        return CouponRewardType.discountPercent;
      case 'fixed_amount':
        return CouponRewardType.fixedAmount;
      case 'free_month':
        return CouponRewardType.freeMonth;
      case 'free_days':
      default:
        return CouponRewardType.freeDays;
    }
  }
}

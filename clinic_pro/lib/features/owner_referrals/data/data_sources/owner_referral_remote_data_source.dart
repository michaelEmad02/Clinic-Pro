// ─────────────────────────────────────────────────────────────────────────────
// مصدر بيانات الإحالات عن بُعد (Owner Referral Remote Data Source)
// يستدعي دوال الـ RPC من السيرفر لجلب ملخص الدعوات وتسجيل العمليات
// ─────────────────────────────────────────────────────────────────────────────

import 'package:injectable/injectable.dart';
import 'package:clinic_pro/core/services/i_cloud_service.dart';
import 'package:clinic_pro/features/owner_referrals/data/models/referral_dashboard_model.dart';

abstract class IOwnerReferralRemoteDataSource {
  Future<ReferralDashboardModel> getReferralDashboard(String ownerId);

  Future<void> applyReferralCodeOnRegistration({
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
  Future<void> applyReferralCodeOnRegistration({
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
      if (!isSuccess) {
        throw Exception(response['message'] as String? ?? 'فشل تطبيق كود الدعوة');
      }
    }
  }
}

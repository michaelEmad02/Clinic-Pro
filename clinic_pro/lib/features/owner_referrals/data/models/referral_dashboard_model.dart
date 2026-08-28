// ─────────────────────────────────────────────────────────────────────────────
// نماذج بيانات الإحالات والمحطات (Referral & Milestone Models)
// ─────────────────────────────────────────────────────────────────────────────

import 'package:clinic_pro/core/constants/supabase_constants.dart';
import 'package:clinic_pro/features/owner_referrals/domain/entities/referral_dashboard_entity.dart';

class MilestoneRewardModel extends MilestoneRewardEntity {
  const MilestoneRewardModel({
    required super.id,
    required super.targetCount,
    required super.title,
    super.description,
    required super.rewardType,
    required super.rewardValue,
    required super.isAchieved,
    required super.isClaimed,
    super.claimedAt,
    super.couponCode,
  });

  factory MilestoneRewardModel.fromJson(Map<String, dynamic> json) {
    return MilestoneRewardModel(
      id: json['id'] as String,
      targetCount: json['target_count'] as int? ?? 1,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      rewardType: _mapRewardType(json['referrer_reward_type'] as String? ?? json['reward_type'] as String?),
      rewardValue: (json['referrer_reward_value'] as num?)?.toDouble() ?? (json['reward_value'] as num?)?.toDouble() ?? 0.0,
      isAchieved: json['is_achieved'] as bool? ?? false,
      isClaimed: json['is_claimed'] as bool? ?? false,
      claimedAt: json['claimed_at'] != null
          ? DateTime.parse(json['claimed_at'] as String)
          : null,
      couponCode: json['coupon_code'] as String?,
    );
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

class ReferralDashboardModel extends ReferralDashboardEntity {
  const ReferralDashboardModel({
    required super.referralCode,
    required super.totalInvites,
    required super.successfulInvites,
    super.availableInvites = 0,
    required super.milestones,
  });

  factory ReferralDashboardModel.fromJson(Map<String, dynamic> json) {
    final milestonesJson = json['milestones'] as List<dynamic>? ?? [];
    return ReferralDashboardModel(
      referralCode: json['referral_code'] as String? ?? '',
      totalInvites: json['total_invites'] as int? ?? 0,
      successfulInvites: json['successful_invites'] as int? ?? 0,
      availableInvites: json['available_invites'] as int? ?? 0,
      milestones: milestonesJson
          .map((m) => MilestoneRewardModel.fromJson(Map<String, dynamic>.from(m as Map)))
          .toList(),
    );
  }
}

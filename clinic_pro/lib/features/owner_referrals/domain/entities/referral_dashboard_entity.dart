// ─────────────────────────────────────────────────────────────────────────────
// ملف كيانات نظام الإحالة والمحطات (Owner Referral & Milestone Entities)
// يمثل بيانات كود المالك، إحصائيات الدعوات، ومحطات الجوائز
// ─────────────────────────────────────────────────────────────────────────────

import 'package:equatable/equatable.dart';
import 'package:clinic_pro/core/constants/supabase_constants.dart';

/// كيان محطة الهدف والمكافأة (مثل 5 دعوات = شهر مجاني)
class MilestoneRewardEntity extends Equatable {
  final String id;
  final int targetCount;
  final String title;
  final String? description;
  final CouponRewardType rewardType;
  final double rewardValue;
  final bool isAchieved;
  final bool isClaimed;
  final DateTime? claimedAt;
  final String? couponCode;

  const MilestoneRewardEntity({
    required this.id,
    required this.targetCount,
    required this.title,
    this.description,
    required this.rewardType,
    required this.rewardValue,
    required this.isAchieved,
    required this.isClaimed,
    this.claimedAt,
    this.couponCode,
  });

  @override
  List<Object?> get props => [
        id,
        targetCount,
        title,
        description,
        rewardType,
        rewardValue,
        isAchieved,
        isClaimed,
        claimedAt,
        couponCode,
      ];
}

/// كيان لوحة تحكم إحالات المالك
class ReferralDashboardEntity extends Equatable {
  final String referralCode;
  final int totalInvites;
  final int successfulInvites;
  final int availableInvites;
  final List<MilestoneRewardEntity> milestones;

  const ReferralDashboardEntity({
    required this.referralCode,
    required this.totalInvites,
    required this.successfulInvites,
    this.availableInvites = 0,
    required this.milestones,
  });

  /// الحصول على الهدف القادم النشط الذي لم يتحقق بعد
  MilestoneRewardEntity? get nextMilestone {
    for (final milestone in milestones) {
      if (!milestone.isAchieved) return milestone;
    }
    return null;
  }

  /// عدد الدعوات المتبقية لتحقيق الهدف القادم بناءً على الرصيد المتاح
  int get remainingForNextMilestone {
    final next = nextMilestone;
    if (next == null) return 0;
    return (next.targetCount - availableInvites).clamp(0, next.targetCount);
  }

  @override
  List<Object?> get props => [
        referralCode,
        totalInvites,
        successfulInvites,
        availableInvites,
        milestones,
      ];
}

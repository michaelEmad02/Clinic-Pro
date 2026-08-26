// ─────────────────────────────────────────────────────────────────────────────
// ويدجت شريط التقدم للهدف والمحطة القادمة (Milestone Progress Card)
// يدعم التخصيص التلقائي للثيم (context color getters) وتعدد اللغات (AppStrings)
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:clinic_pro/core/strings/app_strings.dart';
import 'package:clinic_pro/core/themes/app_colors.dart';
import 'package:clinic_pro/core/themes/app_text_styles.dart';
import 'package:clinic_pro/features/owner_referrals/domain/entities/referral_dashboard_entity.dart';

class MilestoneProgressCard extends StatelessWidget {
  final ReferralDashboardEntity dashboard;

  const MilestoneProgressCard({
    super.key,
    required this.dashboard,
  });

  @override
  Widget build(BuildContext context) {
    final nextMilestone = dashboard.nextMilestone;
    final successful = dashboard.successfulInvites;
    final target = nextMilestone?.targetCount ?? successful;
    final progress = target > 0 ? (successful / target).clamp(0.0, 1.0) : 1.0;
    final remaining = dashboard.remainingForNextMilestone;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(TablerIcons.target_arrow, color: context.warning, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      AppStrings.nextTarget,
                      style: AppTextStyles.bodyMedium(context).copyWith(
                        color: context.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        nextMilestone != null ? nextMilestone.title : AppStrings.allTargetsAchieved,
                        style: AppTextStyles.bodyLarge(context).copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: context.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  AppStrings.doctorsCountProgress(successful, target),
                  style: AppTextStyles.caption(context).copyWith(
                    color: context.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: context.borderColor,
              valueColor: AlwaysStoppedAnimation<Color>(context.primary),
            ),
          ),
          const SizedBox(height: 12),
          if (remaining > 0)
            Text(
              AppStrings.remainingInvitesMsg(remaining),
              style: AppTextStyles.caption(context).copyWith(
                color: context.warning,
                fontWeight: FontWeight.w600,
              ),
            )
          else
            Text(
              AppStrings.targetAchievedSuccessMsg,
              style: AppTextStyles.caption(context).copyWith(
                color: context.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }
}

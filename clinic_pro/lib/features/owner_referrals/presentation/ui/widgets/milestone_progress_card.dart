// ─────────────────────────────────────────────────────────────────────────────
// ويدجت شريط التقدم للهدف والمحطة القادمة (Milestone Progress Card)
// يدعم التخصيص التلقائي للثيم (context color getters) وتعدد اللغات (AppStrings)
// ─────────────────────────────────────────────────────────────────────────────

import 'package:clinic_pro/core/constants/app_constants.dart';
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
    final available = dashboard.availableInvites;
    final target = nextMilestone?.targetCount ?? (available > 0 ? available : 1);
    final progress = target > 0 ? (available / target).clamp(0.0, 1.0) : 1.0;
    final remaining = dashboard.remainingForNextMilestone;

    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusCard),
        border: Border.all(color: context.borderColor),
        boxShadow: AppConstants.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 320;

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(TablerIcons.target_arrow,
                            color: context.warning, size: 20),
                        const SizedBox(width: AppConstants.spaceSm),
                        if (!isNarrow) ...[
                          Text(
                            AppStrings.nextTarget,
                            style: AppTextStyles.bodyMedium(context).copyWith(
                              color: context.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 4),
                        ],
                        Expanded(
                          child: Text(
                            nextMilestone != null
                                ? nextMilestone.title
                                : AppStrings.allTargetsAchieved,
                            style: AppTextStyles.bodyLarge(context).copyWith(
                              fontWeight: FontWeight.bold,
                              color: context.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppConstants.spaceSm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spaceSm + 2,
                      vertical: AppConstants.spaceXs,
                    ),
                    decoration: BoxDecoration(
                      color: context.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppConstants.radiusChip),
                    ),
                    child: Text(
                      AppStrings.doctorsCountProgress(available, target),
                      style: AppTextStyles.caption(context).copyWith(
                        color: context.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: AppConstants.spaceSm + 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.radiusXs + 2),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: context.borderColor,
              valueColor: AlwaysStoppedAnimation<Color>(context.primary),
            ),
          ),
          const SizedBox(height: AppConstants.spaceSm + 2),
          if (remaining > 0)
            Text(
              AppStrings.remainingInvitesMsg(remaining),
              style: AppTextStyles.caption(context).copyWith(
                color: context.warning,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            )
          else
            Text(
              AppStrings.targetAchievedSuccessMsg,
              style: AppTextStyles.caption(context).copyWith(
                color: context.accent,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
        ],
      ),
    );
  }
}

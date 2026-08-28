// ─────────────────────────────────────────────────────────────────────────────
// ويدجت عنصر قائمة المحطات والأهداف (Milestone List Item)
// يدعم التخصيص التلقائي للثيم (context color getters) وتعدد اللغات (AppStrings)
// ─────────────────────────────────────────────────────────────────────────────

import 'package:clinic_pro/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:clinic_pro/core/strings/app_strings.dart';
import 'package:clinic_pro/core/themes/app_colors.dart';
import 'package:clinic_pro/core/themes/app_text_styles.dart';
import 'package:clinic_pro/features/owner_referrals/domain/entities/referral_dashboard_entity.dart';

class MilestoneListItem extends StatelessWidget {
  final MilestoneRewardEntity milestone;

  const MilestoneListItem({
    super.key,
    required this.milestone,
  });

  @override
  Widget build(BuildContext context) {
    final isAchieved = milestone.isAchieved;

    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spaceSm + 4),
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceMd,
        vertical: AppConstants.spaceSm + 4,
      ),
      decoration: BoxDecoration(
        color:
            isAchieved ? context.accent.withOpacity(0.04) : context.surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusButton),
        border: Border.all(
          color: isAchieved
              ? context.accent.withOpacity(0.3)
              : context.borderColor,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: isAchieved
                  ? context.accent.withOpacity(0.12)
                  : context.borderColor.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isAchieved ? TablerIcons.circle_check : TablerIcons.lock,
              color: isAchieved ? context.accent : context.textSecondary,
              size: 18,
            ),
          ),
          const SizedBox(width: AppConstants.spaceSm + 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  milestone.title,
                  style: AppTextStyles.bodyMedium(context).copyWith(
                    fontWeight: FontWeight.bold,
                    color:
                        isAchieved ? context.textPrimary : context.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                if (milestone.description != null &&
                    milestone.description!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    milestone.description!,
                    style: AppTextStyles.caption(context).copyWith(
                      color: context.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ],
                if (milestone.couponCode != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    AppStrings.yourCouponCodeIs(milestone.couponCode!),
                    style: AppTextStyles.caption(context).copyWith(
                      color: context.primary,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
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
              color: isAchieved
                  ? context.accent.withOpacity(0.1)
                  : context.borderColor.withOpacity(0.4),
              borderRadius: BorderRadius.circular(AppConstants.radiusSm),
            ),
            child: Text(
              isAchieved
                  ? AppStrings.rewardClaimedBadge
                  : AppStrings.doctorsRequiredCount(milestone.targetCount),
              style: AppTextStyles.caption(context).copyWith(
                color: isAchieved ? context.accent : context.textSecondary,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}

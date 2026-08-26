// ─────────────────────────────────────────────────────────────────────────────
// ويدجت عنصر قائمة المحطات والأهداف (Milestone List Item)
// يدعم التخصيص التلقائي للثيم (context color getters) وتعدد اللغات (AppStrings)
// ─────────────────────────────────────────────────────────────────────────────

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
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isAchieved ? context.accent.withOpacity(0.04) : context.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAchieved ? context.accent.withOpacity(0.3) : context.borderColor,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isAchieved
                  ? context.accent.withOpacity(0.12)
                  : context.borderColor.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isAchieved ? TablerIcons.circle_check : TablerIcons.lock,
              color: isAchieved ? context.accent : context.textSecondary,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  milestone.title,
                  style: AppTextStyles.bodyMedium(context).copyWith(
                    fontWeight: FontWeight.bold,
                    color: isAchieved ? context.textPrimary : context.textSecondary,
                  ),
                ),
                if (milestone.description != null && milestone.description!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    milestone.description!,
                    style: AppTextStyles.caption(context).copyWith(
                      color: context.textSecondary,
                    ),
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
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isAchieved
                  ? context.accent.withOpacity(0.1)
                  : context.borderColor.withOpacity(0.4),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isAchieved
                  ? AppStrings.rewardClaimedBadge
                  : AppStrings.doctorsRequiredCount(milestone.targetCount),
              style: AppTextStyles.caption(context).copyWith(
                color: isAchieved ? context.accent : context.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

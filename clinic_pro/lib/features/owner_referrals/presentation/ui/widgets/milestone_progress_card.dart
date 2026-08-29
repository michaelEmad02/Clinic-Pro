// ─────────────────────────────────────────────────────────────────────────────
// ويدجت شريط التقدم للهدف والمحطة القادمة (Milestone Progress Card)
// يدعم التخصيص التلقائي للثيم (context color getters) وتعدد اللغات (AppStrings)
// ─────────────────────────────────────────────────────────────────────────────

import 'package:clinic_pro/core/constants/app_constants.dart';
import 'package:clinic_pro/core/constants/supabase_constants.dart';
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
          // 1. شريط العنوان العلوي: أيقونة الهدف + تسمية الهدف القادم + عداد التقدم
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(TablerIcons.target_arrow, color: context.warning, size: 20),
                  const SizedBox(width: AppConstants.spaceSm),
                  Text(
                    AppStrings.nextTarget,
                    style: AppTextStyles.bodyMedium(context).copyWith(
                      color: context.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
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
          ),
          const SizedBox(height: 6),
          // 2. عنوان التحدي يأخذ العرض بالكامل
          Text(
            nextMilestone != null
                ? nextMilestone.title
                : AppStrings.allTargetsAchieved,
            style: AppTextStyles.bodyLarge(context).copyWith(
              fontWeight: FontWeight.bold,
              color: context.textPrimary,
              fontSize: 16,
            ),
          ),
          if (nextMilestone?.description != null &&
              nextMilestone!.description!.isNotEmpty) ...[
            const SizedBox(height: 3),
            Text(
              nextMilestone.description!,
              style: AppTextStyles.caption(context).copyWith(
                color: context.textSecondary,
              ),
            ),
          ],
          if (nextMilestone != null) ...[
            const SizedBox(height: AppConstants.spaceSm + 2),
            // 3. بطاقات مكافأة الداعي والمدعو كاملة العرض بالتساوي
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: context.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(AppConstants.radiusXs + 2),
                      border: Border.all(color: context.primary.withOpacity(0.15)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(TablerIcons.gift, size: 14, color: context.primary),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            AppStrings.referrerRewardBadge(_formatRewardText(
                              nextMilestone.rewardType,
                              nextMilestone.rewardValue,
                            )),
                            style: AppTextStyles.caption(context).copyWith(
                              color: context.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 11.5,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (nextMilestone.refereeRewardType != null &&
                    nextMilestone.refereeRewardValue != null) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: context.accent.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(AppConstants.radiusXs + 2),
                        border: Border.all(color: context.accent.withOpacity(0.15)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(TablerIcons.user_plus, size: 14, color: context.accent),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              AppStrings.refereeRewardBadge(_formatRewardText(
                                nextMilestone.refereeRewardType!,
                                nextMilestone.refereeRewardValue!,
                              )),
                              style: AppTextStyles.caption(context).copyWith(
                                color: context.accent,
                                fontWeight: FontWeight.w600,
                                fontSize: 11.5,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
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

  String _formatRewardText(CouponRewardType type, double value) {
    final isAr = AppStrings.isArabic;
    switch (type) {
      case CouponRewardType.discountPercent:
        return isAr ? 'خصم ${value.toInt()}%' : '${value.toInt()}% Discount';
      case CouponRewardType.fixedAmount:
        return isAr ? 'خصم ${value.toInt()} ج.م' : '${value.toInt()} EGP Off';
      case CouponRewardType.freeMonth:
        return isAr ? 'شهر كامل مجاناً' : '1 Free Month';
      case CouponRewardType.freeDays:
        return isAr ? '${value.toInt()} يوم مجاناً' : '${value.toInt()} Free Days';
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ويدجت عنصر قائمة المحطات والأهداف (Milestone List Item)
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

class MilestoneListItem extends StatelessWidget {
  final MilestoneRewardEntity milestone;

  const MilestoneListItem({
    super.key,
    required this.milestone,
  });

  String _formatRewardText(BuildContext context, CouponRewardType type, double value) {
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

  @override
  Widget build(BuildContext context) {
    final isAchieved = milestone.isAchieved;
    final referrerReward = _formatRewardText(
      context,
      milestone.rewardType,
      milestone.rewardValue,
    );
    final refereeReward = milestone.refereeRewardType != null &&
            milestone.refereeRewardValue != null
        ? _formatRewardText(
            context,
            milestone.refereeRewardType!,
            milestone.refereeRewardValue!,
          )
        : null;

    final targetBadge = Container(
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
          fontSize: 11,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 360;

        return Container(
          margin: const EdgeInsets.only(bottom: AppConstants.spaceSm + 4),
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spaceMd,
            vertical: AppConstants.spaceSm + 4,
          ),
          decoration: BoxDecoration(
            color: isAchieved
                ? context.accent.withOpacity(0.04)
                : context.surfaceColor,
            borderRadius: BorderRadius.circular(AppConstants.radiusButton),
            border: Border.all(
              color: isAchieved
                  ? context.accent.withOpacity(0.3)
                  : context.borderColor,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // الصف العلوي: الأيقونة + العنوان + شارة الهدف
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
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
                    child: Text(
                      milestone.title,
                      style: AppTextStyles.bodyMedium(context).copyWith(
                        fontWeight: FontWeight.bold,
                        color: isAchieved
                            ? context.textPrimary
                            : context.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(width: AppConstants.spaceSm),
                  targetBadge,
                ],
              ),
              if (milestone.description != null &&
                  milestone.description!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Text(
                    milestone.description!,
                    style: AppTextStyles.caption(context).copyWith(
                      color: context.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              // بطاقات المكافأة تأخذ كامل عرض الكرت
              if (isNarrow)
                // في الشاشات الضيقة: عمودياً كامل العرض
                Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                              AppStrings.referrerRewardBadge(referrerReward),
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
                    if (refereeReward != null) ...[
                      const SizedBox(height: 4),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                                AppStrings.refereeRewardBadge(refereeReward),
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
                    ],
                  ],
                )
              else
                // في الشاشات العادية: صف كامل العرض متساوي المسافات
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                        decoration: BoxDecoration(
                          color: context.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(AppConstants.radiusXs + 2),
                          border: Border.all(color: context.primary.withOpacity(0.15)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(TablerIcons.gift, size: 14, color: context.primary),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                AppStrings.referrerRewardBadge(referrerReward),
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
                    if (refereeReward != null) ...[
                      const SizedBox(width: 6),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                          decoration: BoxDecoration(
                            color: context.accent.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(AppConstants.radiusXs + 2),
                            border: Border.all(color: context.accent.withOpacity(0.15)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(TablerIcons.user_plus, size: 14, color: context.accent),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  AppStrings.refereeRewardBadge(refereeReward),
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
              if (milestone.couponCode != null) ...[
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Text(
                    '${AppStrings.isArabic ? "كود الكوبون:" : "Coupon Code:"} ${milestone.couponCode}',
                    style: AppTextStyles.caption(context).copyWith(
                      color: context.primary,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

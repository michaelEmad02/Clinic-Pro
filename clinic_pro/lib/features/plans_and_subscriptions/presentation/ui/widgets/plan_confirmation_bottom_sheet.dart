// ────────────────────────────────────────────────────────
// شيت تفاصيل وتأكيد الترقية/الاشتراك (PlanConfirmationBottomSheet)
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/constants/app_constants.dart';
import 'package:clinic_pro/core/strings/app_strings.dart';
import 'package:clinic_pro/core/themes/app_colors.dart';
import 'package:clinic_pro/core/themes/app_text_styles.dart';
import 'package:clinic_pro/features/plans_and_subscriptions/domain/entities/plan_entity.dart';
import 'package:flutter/material.dart';

class PlanConfirmationBottomSheet extends StatelessWidget {
  final PlanEntity targetPlan;
  final String subscriptionType; // 'monthly', 'yearly', 'lifetime'
  final bool isUpgrade;
  final int remainingDays;
  final VoidCallback onConfirm;

  const PlanConfirmationBottomSheet({
    super.key,
    required this.targetPlan,
    required this.subscriptionType,
    required this.isUpgrade,
    required this.remainingDays,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    double price = targetPlan.monthlyPrice;
    String cycleText = AppStrings.monthlyLabel;
    if (subscriptionType == 'yearly') {
      price = targetPlan.yearlyPrice;
      cycleText = AppStrings.yearlyLabel;
    } else if (subscriptionType == 'lifetime') {
      price = targetPlan.lifetimePrice;
      cycleText = AppStrings.lifetimeLabel;
    }

    final maxClinicsText = targetPlan.features != null && targetPlan.features!.maxClinics <= 0
        ? AppStrings.unlimited
        : '${targetPlan.features?.maxClinics ?? 1}';

    final maxStaffText = targetPlan.features != null && targetPlan.features!.maxStaff <= 0
        ? AppStrings.unlimited
        : '${targetPlan.features?.maxStaff ?? 2}';

    final maxPatientsText = targetPlan.features != null && targetPlan.features!.maxPatients <= 0
        ? AppStrings.unlimited
        : '${targetPlan.features?.maxPatients ?? 500}';

    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceLg),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppConstants.radiusSheet),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // مقبض السحب (Drag Handle)
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.borderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppConstants.spaceMd),

            // عنوان الشيت
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: context.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isUpgrade ? Icons.rocket_launch_rounded : Icons.card_membership_rounded,
                    color: context.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isUpgrade ? AppStrings.confirmUpgradeTitle : AppStrings.confirmPlanSelectionTitle,
                    style: AppTextStyles.headlineSmall(context).copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spaceLg),

            // ترويسة تفاصيل السعر والباقة المختارة
            Container(
              padding: const EdgeInsets.all(AppConstants.spaceMd),
              decoration: BoxDecoration(
                color: context.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.borderColor),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${AppStrings.basicPlan.isEmpty ? "خطة" : ""} ${targetPlan.name.toUpperCase()}',
                          style: AppTextStyles.headlineSmall(context).copyWith(
                            fontWeight: FontWeight.bold,
                            color: context.primary,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${AppStrings.billingCycle}: $cycleText',
                          style: AppTextStyles.bodyMedium(context).copyWith(
                            color: context.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${price.toInt()}',
                        style: AppTextStyles.headlineMedium(context).copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.primary,
                        ),
                        textDirection: TextDirection.ltr,
                      ),
                      Text(
                        '/$cycleText',
                        style: AppTextStyles.caption(context).copyWith(
                          color: context.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            if (isUpgrade && remainingDays > 0) ...[
              const SizedBox(height: AppConstants.spaceMd),
              Container(
                padding: const EdgeInsets.all(AppConstants.spaceMd),
                decoration: BoxDecoration(
                  color: context.warningBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: context.warningText.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded, color: context.warningText, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        AppStrings.remainingDaysNotice(remainingDays),
                        style: AppTextStyles.caption(context).copyWith(
                          color: context.warningText,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: AppConstants.spaceLg),

            Text(
              AppStrings.planFeaturesListTitle,
              style: AppTextStyles.bodyLarge(context).copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.spaceSm),
            _buildFeatureRow(context, Icons.store_rounded, AppStrings.clinicsCountLabel, maxClinicsText),
            _buildFeatureRow(context, Icons.badge_rounded, AppStrings.staffCountLabel, maxStaffText),
            _buildFeatureRow(context, Icons.people_alt_rounded, AppStrings.patientsCapacityLabel, maxPatientsText),

            const SizedBox(height: AppConstants.spaceXl),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppConstants.radiusButton),
                      ),
                    ),
                    child: Text(
                      AppStrings.cancel,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ),
                const SizedBox(width: AppConstants.spaceMd),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onConfirm();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.primary,
                      foregroundColor: context.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppConstants.radiusButton),
                      ),
                    ),
                    child: Text(
                      isUpgrade ? AppStrings.confirmUpgradeAction : AppStrings.confirmRequestAction,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: context.primary),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: AppTextStyles.bodyMedium(context).copyWith(color: context.textSecondary),
          ),
          Text(
            value,
            style: AppTextStyles.bodyMedium(context).copyWith(
              fontWeight: FontWeight.bold,
              color: context.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

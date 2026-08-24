// ────────────────────────────────────────────────────────
// نافذة تأكيد الترقية عند وجود اشتراك نشط بمستويات مختلفة (UpgradeConfirmationDialog)
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/constants/app_constants.dart';
import 'package:clinic_pro/core/strings/app_strings.dart';
import 'package:clinic_pro/core/themes/app_colors.dart';
import 'package:clinic_pro/core/themes/app_text_styles.dart';
import 'package:flutter/material.dart';

class UpgradeConfirmationDialog extends StatelessWidget {
  final String currentPlanName;
  final String targetPlanName;
  final int remainingDays;
  final VoidCallback onConfirmUpgrade;

  const UpgradeConfirmationDialog({
    super.key,
    required this.currentPlanName,
    required this.targetPlanName,
    required this.remainingDays,
    required this.onConfirmUpgrade,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusSheet),
      ),
      child: ConstrainedBox(
        constraints:
            const BoxConstraints(maxWidth: AppConstants.maxDialogWidth),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spaceLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: context.warningText.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: context.warningText,
                  size: 32,
                ),
              ),
              const SizedBox(height: AppConstants.spaceMd),
              Text(
                AppStrings.confirmUpgradeTitle,
                style: AppTextStyles.headlineSmall(context).copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.spaceSm),
              Text(
                AppStrings.confirmUpgradeDialogMsg(
                  currentPlanName.toUpperCase(),
                  targetPlanName.toUpperCase(),
                  remainingDays,
                ),
                style: AppTextStyles.bodyMedium(context).copyWith(
                  color: context.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.spaceLg),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppConstants.radiusButton),
                        ),
                      ),
                      child: Text(
                        AppStrings.cancel,
                        style: AppTextStyles.bodyMedium(context).copyWith(
                          color: context.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppConstants.spaceMd),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        onConfirmUpgrade();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.primary,
                        foregroundColor: context.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppConstants.radiusButton),
                        ),
                      ),
                      child: Text(
                        AppStrings.agreeUpgrade,
                        style: AppTextStyles.bodyMedium(context).copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.onPrimary,
                        ),
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
      ),
    );
  }
}


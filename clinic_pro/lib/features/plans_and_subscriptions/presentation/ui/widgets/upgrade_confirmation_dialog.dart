// ────────────────────────────────────────────────────────
// نافذة تأكيد الترقية عند وجود اشتراك نشط بمستويات مختلفة (UpgradeConfirmationDialog)
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/constants/app_constants.dart';
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
                'تأكيد ترقية الاشتراك',
                style: AppTextStyles.headlineSmall(context).copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.spaceSm),
              Text(
                'اشتراكك الحالي في خطة (${currentPlanName.toUpperCase()}) لا يزال نشطاً ومتبقياً فيه ($remainingDays يوماً).\nهل ترغب في تأكيد طلب الترقية إلى خطة (${targetPlanName.toUpperCase()}) الآن؟',
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
                      child: const Text('إلغاء'),
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
                      child: const Text('موافق، ترقية'),
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

import 'package:flutter/material.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';

// ────────────────────────────────────────────────────────
// شريط الأزرار السفلي للروشتة: حفظ - طباعة - إرسال
// ────────────────────────────────────────────────────────

class PrescriptionBottomActionsBar extends StatelessWidget {
  final VoidCallback onSave;
  final VoidCallback onPrint;
  final VoidCallback onWhatsApp;
  final VoidCallback onFinishWithoutSaving;

  const PrescriptionBottomActionsBar({
    super.key,
    required this.onSave,
    required this.onPrint,
    required this.onWhatsApp,
    required this.onFinishWithoutSaving,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        border: Border(top: BorderSide(color: context.borderColor, width: 1)),
        boxShadow: AppConstants.cardShadow,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceMd,
        vertical: AppConstants.spaceSm + 4,
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: AppConstants.maxContentWidth),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            onPressed: onSave,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.primary,
                              foregroundColor: context.onPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppConstants.radiusButton),
                              ),
                              elevation: 0,
                            ),
                            icon: Icon(Icons.save, size: AppConstants.iconSizeXl, color: context.onPrimary),
                            label: Text(
                              AppStrings.saveAndFinish,
                              style: AppTextStyles.headlineSmall(context).copyWith(
                                fontWeight: FontWeight.bold,
                                color: context.onPrimary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppConstants.spaceSm),
                        Expanded(
                          flex: 1,
                          child: OutlinedButton.icon(
                            onPressed: onPrint,
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: context.borderColor),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppConstants.radiusButton),
                              ),
                            ),
                            icon: Icon(Icons.print, size: AppConstants.iconSizeXl, color: context.primary),
                            label: Text(
                              AppStrings.print,
                              style: AppTextStyles.bodyMedium(context).copyWith(
                                fontWeight: FontWeight.bold,
                                color: context.primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.spaceSm),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton.icon(
                        onPressed: onFinishWithoutSaving,
                        style: TextButton.styleFrom(
                          backgroundColor: context.dangerBg,
                          foregroundColor: context.danger,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppConstants.radiusButton),
                          ),
                        ),
                        icon: Icon(Icons.close_rounded, size: AppConstants.iconSizeLg, color: context.danger),
                        label: Text(
                          AppStrings.finishWithoutPrescription,
                          style: AppTextStyles.bodyMedium(context).copyWith(
                            fontWeight: FontWeight.bold,
                            color: context.danger,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

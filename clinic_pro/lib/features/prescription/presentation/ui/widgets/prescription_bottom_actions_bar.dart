import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';

// ────────────────────────────────────────────────────────
// شريط الأزرار السفلي للروشتة: حفظ - طباعة - إرسال
// ────────────────────────────────────────────────────────

class PrescriptionBottomActionsBar extends StatelessWidget {
  final VoidCallback onSaveAndFinish;
  final VoidCallback onSaveAndPrint;
  final VoidCallback onSaveAndSend;
  final VoidCallback onFinish;

  const PrescriptionBottomActionsBar({
    super.key,
    required this.onSaveAndFinish,
    required this.onSaveAndPrint,
    required this.onSaveAndSend,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    final isArabic = AppStrings.isArabic;

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
                        // 1. حفظ وإنهاء
                        Expanded(
                          flex: 1,
                          child: ElevatedButton.icon(
                            onPressed: onSaveAndFinish,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.primary,
                              foregroundColor: context.onPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppConstants.radiusButton),
                              ),
                              elevation: 0,
                            ),
                            icon: Icon(Icons.check_circle_outline_rounded, size: 17, color: context.onPrimary),
                            label: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                isArabic ? 'حفظ وإنهاء' : 'Save & Finish',
                                style: AppTextStyles.bodyMedium(context).copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: context.onPrimary,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),

                        // 2. حفظ وطباعة
                        Expanded(
                          flex: 1,
                          child: OutlinedButton.icon(
                            onPressed: onSaveAndPrint,
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: context.primary.withOpacity(0.5)),
                              backgroundColor: context.primaryLightColor,
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppConstants.radiusButton),
                              ),
                            ),
                            icon: Icon(Icons.print_rounded, size: 17, color: context.primary),
                            label: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                isArabic ? 'حفظ وطباعة' : 'Save & Print',
                                style: AppTextStyles.bodyMedium(context).copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: context.primary,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),

                        // 3. حفظ وإرسال (واتساب)
                        Expanded(
                          flex: 1,
                          child: ElevatedButton.icon(
                            onPressed: onSaveAndSend,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF25D366),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppConstants.radiusButton),
                              ),
                              elevation: 0,
                            ),
                            icon: const Icon(TablerIcons.brand_whatsapp, size: 17, color: Colors.white),
                            label: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                isArabic ? 'حفظ وإرسال' : 'Save & Send',
                                style: AppTextStyles.bodyMedium(context).copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // 4. إنهاء (بدون روشتة)
                    SizedBox(
                      width: double.infinity,
                      child: TextButton.icon(
                        onPressed: onFinish,
                        style: TextButton.styleFrom(
                          backgroundColor: context.dangerBg,
                          foregroundColor: context.danger,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppConstants.radiusButton),
                          ),
                        ),
                        icon: Icon(Icons.close_rounded, size: 18, color: context.danger),
                        label: Text(
                          isArabic ? 'إنهاء الكشف' : 'Finish',
                          style: AppTextStyles.bodyMedium(context).copyWith(
                            fontWeight: FontWeight.bold,
                            color: context.danger,
                            fontSize: 12,
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

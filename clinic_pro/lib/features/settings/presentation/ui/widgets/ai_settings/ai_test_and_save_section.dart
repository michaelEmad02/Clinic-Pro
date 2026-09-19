// ────────────────────────────────────────────────────────
// هذا الملف مسؤول عن أزرار اختبار الاتصال وحفظ الإعدادات مع المؤشرات المباشرة
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/constants/app_constants.dart';
import 'package:clinic_pro/core/strings/app_strings.dart';
import 'package:clinic_pro/core/themes/app_colors.dart';
import 'package:clinic_pro/core/themes/app_text_styles.dart';
import 'package:clinic_pro/core/widgets/app_loading.dart';
import 'package:clinic_pro/features/settings/presentation/manager/ai_settings_state.dart';
import 'package:flutter/material.dart';

class AiTestAndSaveSection extends StatelessWidget {
  final AiSettingsState state;
  final VoidCallback onTestConnection;
  final VoidCallback onSave;

  const AiTestAndSaveSection({
    super.key,
    required this.state,
    required this.onTestConnection,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ─── 1. زر اختبار الاتصال ───
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 13),
              side: BorderSide(color: context.primary.withOpacity(0.5)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: state.testStatus == AiTestStatus.testing
                ? null
                : onTestConnection,
            icon: state.testStatus == AiTestStatus.testing
                ? const AppLoadingWidget(size: AppLoadingSize.small)
                : Icon(Icons.wifi_tethering_rounded, size: 18, color: context.primary),
            label: Text(
              state.testStatus == AiTestStatus.testing
                  ? AppStrings.testingConnection
                  : AppStrings.testConnection,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: context.primary,
              ),
            ),
          ),
        ),

        // ─── 2. شريط حالة الاختبار التفاعلي ───
        if (state.testStatus == AiTestStatus.testing) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: context.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: context.primary.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const AppLoadingWidget(size: AppLoadingSize.small),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    AppStrings.testingConnection,
                    style: AppTextStyles.caption(context).copyWith(
                      color: context.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ] else if (state.testStatus == AiTestStatus.success) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.green, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    AppStrings.connectionSuccess,
                    style: AppTextStyles.caption(context).copyWith(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ] else if (state.testStatus == AiTestStatus.error &&
            state.testErrorMessage != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.red, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    state.testErrorMessage!,
                    style: AppTextStyles.caption(context).copyWith(
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: AppConstants.spaceLg),

        // ─── 3. زر الحفظ الرئيسي ───
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: context.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: state.status == AiSettingsStatus.saving ? null : onSave,
            child: state.status == AiSettingsStatus.saving
                ? const AppLoadingWidget(
                    size: AppLoadingSize.small,
                    color: Colors.white,
                  )
                : Text(
                    AppStrings.save,
                    style: AppTextStyles.bodyMedium(context).copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

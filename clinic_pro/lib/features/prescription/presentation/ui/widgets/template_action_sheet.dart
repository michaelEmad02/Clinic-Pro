import 'package:flutter/material.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/widgets/app_bottom_sheet.dart';

// ────────────────────────────────────────────────────────
// شاشة خيارات القالب (حذف)
// ────────────────────────────────────────────────────────

class TemplateActionSheet {
  static Future<void> show({
    required BuildContext context,
    required Map<String, dynamic> template,
    required VoidCallback onDelete,
    required VoidCallback onEdit,
  }) {
    return AppBottomSheet.show(
      context: context,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              template['title'] ?? '',
              style: AppTextStyles.headlineMedium(context).copyWith(
                fontWeight: FontWeight.bold,
                color: context.primary,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.edit_document, color: context.primary),
              title: Text(
                AppStrings.editTemplate,
                style: AppTextStyles.bodyMedium(context).copyWith(
                  color: context.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                onEdit();
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.delete_outline, color: context.danger),
              title: Text(
                AppStrings.deleteTemplate,
                style: AppTextStyles.bodyMedium(context).copyWith(
                  color: context.danger,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                onDelete();
              },
            ),
          ],
        ),
      ),
    );
  }
}

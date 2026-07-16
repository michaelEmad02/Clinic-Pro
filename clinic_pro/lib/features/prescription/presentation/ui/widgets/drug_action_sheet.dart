import 'package:flutter/material.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/widgets/app_bottom_sheet.dart';

// ────────────────────────────────────────────────────────
// شاشة خيارات الدواء (تعديل / حذف)
// ────────────────────────────────────────────────────────

class DrugActionSheet {
  static Future<void> show({
    required BuildContext context,
    required Map<String, dynamic> drug,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
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
              drug['trade_name'] ?? '',
              style: AppTextStyles.headlineMedium(context).copyWith(
                fontWeight: FontWeight.bold,
                color: context.primary,
              ),
            ),
            Text(
              drug['generic_name'] ?? '',
              style: AppTextStyles.bodyMedium(context).copyWith(
                color: context.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.edit_outlined, color: context.primary),
              title: Text(
                AppStrings.editDrug,
                style: AppTextStyles.bodyMedium(context).copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                onEdit();
              },
            ),
            Divider(color: context.border, height: 1),
            ListTile(
              leading: Icon(Icons.delete_outline, color: context.danger),
              title: Text(
                AppStrings.deleteDrug,
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

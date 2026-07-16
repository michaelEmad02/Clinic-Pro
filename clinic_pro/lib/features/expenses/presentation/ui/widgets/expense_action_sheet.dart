// ────────────────────────────────────────────────────────
// Bottom Sheet إجراءات المصروف — تعديل وحذف
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/widgets/app_bottom_sheet.dart';
import '../../manager/expenses_state.dart';

class ExpenseActionSheet {
  static Future<void> show({
    required BuildContext context,
    required ExpenseItem expense,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    return AppBottomSheet.show(
      context: context,
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              expense.title,
              style: AppTextStyles.headlineSmall(context).copyWith(
                fontWeight: FontWeight.bold,
                color: context.primary,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: context.primaryLightColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                expense.categoryLabel,
                style: AppTextStyles.labelChip(context).copyWith(
                  color: context.primary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _DetailRow(
              label: AppStrings.amount,
              value: '${expense.amount.toStringAsFixed(0)} ${AppStrings.egp}',
              valueColor: context.dangerText,
            ),
            _DetailRow(
              label: AppStrings.date,
              value: expense.formattedDate,
            ),
            if (expense.notes.isNotEmpty)
              _DetailRow(label: AppStrings.notes, value: expense.notes),
            const SizedBox(height: 16),
            _ActionTile(
              icon: Icons.edit_outlined,
              label: AppStrings.editExpense,
              color: context.primary,
              onTap: () {
                Navigator.pop(context);
                onEdit();
              },
            ),
            _ActionTile(
              icon: Icons.delete_outline,
              label: AppStrings.deleteExpense,
              color: context.danger,
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

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: AppTextStyles.bodyMedium(context)
                  .copyWith(color: context.textSecondary)),
          Text(value,
              style: AppTextStyles.bodyMedium(context).copyWith(
                fontWeight: FontWeight.bold,
                color: valueColor ?? context.textPrimary,
              )),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label,
          style: AppTextStyles.bodyMedium(context)
              .copyWith(fontWeight: FontWeight.w600)),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}

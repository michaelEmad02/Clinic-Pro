// ────────────────────────────────────────────────────────
// ExpenseListItem — عنصر المصروف في قائمة المصروفات
// يعرض العنوان، التاريخ، التصنيف، والمبلغ مع التنسيق المناسب
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/services/numbers_format.dart';
import 'package:clinic_pro/core/themes/app_colors.dart';
import 'package:clinic_pro/core/themes/app_text_styles.dart';
import 'package:clinic_pro/features/expenses/domain/entities/expenses_entity.dart';
import 'package:flutter/material.dart';
import 'expense_action_sheet.dart';

class ExpenseListItem extends StatelessWidget {
  final ExpensesEntity expense;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ExpenseListItem({
    super.key,
    required this.expense,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.borderColor),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 3,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            InkWell(
              onTap: () => ExpenseActionSheet.show(
                context: context,
                expense: expense,
                onEdit: onEdit,
                onDelete: onDelete,
              ),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: context.backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _categoryIcon(expense.categoryName),
                  color: context.primary,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.title,
                    style: AppTextStyles.headlineSmall(context).copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        expense.formattedDate,
                        style: AppTextStyles.caption(context).copyWith(
                          color: context.textHint,
                        ),
                      ),
                      if (expense.categoryName.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: context.primaryLightColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            expense.categoryName,
                            style: AppTextStyles.labelChip(context).copyWith(
                              fontSize: 10,
                              color: context.primary,
                            ),
                          ),
                        ),
                      if (expense.createdByName != null &&
                          expense.createdByName!.trim().isNotEmpty)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.person_outline,
                                size: 12, color: context.primary),
                            const SizedBox(width: 2),
                            Flexible(
                              child: Text(
                                expense.createdByName!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.caption(context).copyWith(
                                  color: context.primary,
                                  fontSize: 11.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '- ${formatNumber(expense.amount)}',
              style: AppTextStyles.dataNumeric(context).copyWith(
                color: context.danger,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _categoryIcon(String categoryName) {
    if (categoryName.contains('إيجار')) return Icons.home_work_outlined;
    if (categoryName.contains('كهرباء') || categoryName.contains('طاقه')) {
      return Icons.bolt_outlined;
    }
    if (categoryName.contains('مستلزمات') || categoryName.contains('طبية')) {
      return Icons.medical_services_outlined;
    }
    if (categoryName.contains('رواتب')) return Icons.groups_outlined;
    if (categoryName.contains('صيانه')) return Icons.build_outlined;
    if (categoryName.contains('انترنت')) return Icons.wifi_outlined;
    if (categoryName.contains('تسويق')) return Icons.campaign_outlined;
    if (categoryName.contains('مياه')) return Icons.water_drop_outlined;
    return Icons.receipt_long_outlined;
  }
}

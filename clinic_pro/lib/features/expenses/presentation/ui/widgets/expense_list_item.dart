import 'package:flutter/material.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../manager/expenses_state.dart';

class ExpenseListItem extends StatelessWidget {
  final ExpenseItem expense;
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
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
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
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _categoryIcon(expense.categoryId),
                color: AppColors.primary,
                size: 24,
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    expense.formattedDate,
                    style: AppTextStyles.caption(context).copyWith(
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '- ${expense.amount.toStringAsFixed(0)}',
              style: AppTextStyles.dataNumeric(context).copyWith(
                color: AppColors.danger,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _categoryIcon(String categoryId) {
    switch (categoryId) {
      case 'ec-1':
        return Icons.home_work;
      case 'ec-2':
        return Icons.bolt;
      case 'ec-3':
        return Icons.medical_services;
      case 'ec-4':
        return Icons.groups;
      case 'ec-5':
        return Icons.build;
      case 'ec-6':
        return Icons.more_horiz;
      default:
        return Icons.more_horiz;
    }
  }
}
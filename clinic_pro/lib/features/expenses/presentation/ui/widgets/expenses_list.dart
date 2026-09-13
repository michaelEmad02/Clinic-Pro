// ────────────────────────────────────────────────────────
// ExpensesList — قائمة المصروفات
// تعرض العناصر عبر ListView.builder مع حالة الفراغ EmptyState
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/strings/app_strings.dart';
import 'package:clinic_pro/core/widgets/empty_state.dart';
import 'package:clinic_pro/features/expenses/domain/entities/expenses_entity.dart';
import 'package:flutter/material.dart';
import 'expense_list_item.dart';

class ExpensesList extends StatelessWidget {
  final List<ExpensesEntity> expenses;
  final ValueChanged<ExpensesEntity> onEdit;
  final ValueChanged<ExpensesEntity> onDelete;

  const ExpensesList({
    super.key,
    required this.expenses,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (expenses.isEmpty) {
      return EmptyState(
        title: AppStrings.noExpenses,
        subtitle: AppStrings.isArabic
            ? 'لم يتم تسجيل أي مصروفات بعد'
            : 'No expenses recorded yet',
        icon: Icons.account_balance_wallet_outlined,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final int columns = (constraints.maxWidth / 360).floor().clamp(1, 3);

        if (columns > 1) {
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: expenses.length,
            padding: EdgeInsets.zero,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisExtent: 96,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (context, index) {
              final expense = expenses[index];
              return ExpenseListItem(
                expense: expense,
                onEdit: () => onEdit(expense),
                onDelete: () => onDelete(expense),
              );
            },
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: expenses.length,
          padding: EdgeInsets.zero,
          itemBuilder: (context, index) {
            final expense = expenses[index];
            return ExpenseListItem(
              expense: expense,
              onEdit: () => onEdit(expense),
              onDelete: () => onDelete(expense),
            );
          },
        );
      },
    );
  }
}

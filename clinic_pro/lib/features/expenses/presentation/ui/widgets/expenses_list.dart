// ────────────────────────────────────────────────────────
// قائمة المصروفات — ListView.builder مع EmptyState
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../../core/widgets/empty_state.dart';
import '../../manager/expenses_state.dart';
import 'expense_list_item.dart';

class ExpensesList extends StatelessWidget {
  final List<ExpenseItem> expenses;
  final ValueChanged<ExpenseItem> onEdit;
  final ValueChanged<ExpenseItem> onDelete;

  const ExpensesList({
    super.key,
    required this.expenses,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (expenses.isEmpty) {
      return const EmptyState(
        title: 'لا توجد مصروفات',
        subtitle: 'لم يتم تسجيل أي مصروفات بعد.',
        icon: Icons.account_balance_wallet_outlined,
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
  }
}

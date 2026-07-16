// ────────────────────────────────────────────────────────
// شاشة المصروفات — عرض وإدارة مصروفات العيادة
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/strings/app_strings.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/widgets/shimmer_list.dart';
import '../manager/expenses_cubit.dart';
import '../manager/expenses_state.dart';
import 'widgets/add_edit_expense_sheet.dart';
import 'widgets/expenses_category_chips.dart';
import 'widgets/expenses_list.dart';
import 'widgets/expenses_total_card.dart';

class ExpensesScreen extends StatelessWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ExpensesCubit>()..loadExpenses(),
      child: const _ExpensesBody(),
    );
  }
}

class _ExpensesBody extends StatelessWidget {
  const _ExpensesBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        toolbarHeight: 64,
        backgroundColor: context.surfaceColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          AppStrings.expenses,
          style: AppTextStyles.headlineMedium(context).copyWith(
            fontWeight: FontWeight.bold,
            color: context.primary,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: context.borderColor, height: 1),
        ),
      ),
      body: BlocBuilder<ExpensesCubit, ExpensesState>(
        builder: (context, state) {
          if (state is ExpensesLoading) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: ShimmerList(itemCount: 5),
            );
          }
          if (state is ExpensesError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<ExpensesCubit>().loadExpenses(),
                    child: Text(AppStrings.retry),
                  ),
                ],
              ),
            );
          }
          if (state is ExpensesLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<ExpensesCubit>().loadExpenses();
                await Future.delayed(const Duration(milliseconds: 600));
              },
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 16),
                children: [
                  ExpensesTotalCard(state: state),
                  const SizedBox(height: 12),
                  ExpensesCategoryChips(
                    categories: state.categories,
                    activeCategoryId: state.activeCategoryId,
                    onChanged: (catId) =>
                        context.read<ExpensesCubit>().changeCategory(catId),
                  ),
                  const SizedBox(height: 12),
                  ExpensesList(
                    expenses: state.filteredExpenses,
                    onEdit: (exp) {
                      AddEditExpenseSheet.show(
                        context,
                        expense: exp,
                        categories: state.categories,
                      );
                    },
                    onDelete: (exp) {
                      _confirmDelete(context, exp);
                    },
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final state = context.read<ExpensesCubit>().state;
          if (state is ExpensesLoaded) {
            AddEditExpenseSheet.show(
              context,
              categories: state.categories,
            );
          }
        },
        backgroundColor: context.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }

  void _confirmDelete(BuildContext context, ExpenseItem expense) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.deleteExpense),
        content: Text('هل أنت متأكد من حذف "${expense.title}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              context.read<ExpensesCubit>().deleteExpense(expense.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(AppStrings.expenseDeleted)),
              );
            },
            child: Text(AppStrings.delete,
                style: TextStyle(color: context.danger)),
          ),
        ],
      ),
    );
  }
}

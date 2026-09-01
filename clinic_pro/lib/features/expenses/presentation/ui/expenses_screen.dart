// ────────────────────────────────────────────────────────
// ExpensesScreen — شاشة المصروفات
// تعرض المصروفات وتعزل تلقائياً بين مصاريف العيادة العامة (للمالك)
// ومصاريف الطبيب الخاصة (للطبيب)
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/constants/app_constants.dart';
import 'package:clinic_pro/core/constants/staff_roles.dart';
import 'package:clinic_pro/core/di/injection_container.dart';
import 'package:clinic_pro/core/strings/app_strings.dart';
import 'package:clinic_pro/core/themes/app_colors.dart';
import 'package:clinic_pro/core/themes/app_text_styles.dart';
import 'package:clinic_pro/core/utils/responsive_helper.dart';
import 'package:clinic_pro/core/widgets/app_error_widget.dart';
import 'package:clinic_pro/core/widgets/app_snackbar.dart';
import 'package:clinic_pro/core/widgets/shimmer_list.dart';
import 'package:clinic_pro/features/auth/presentation/manager/auth_cubit.dart';
import 'package:clinic_pro/features/expenses/domain/entities/expenses_entity.dart';
import 'package:clinic_pro/features/expenses/presentation/manager/expenses_cubit.dart';
import 'package:clinic_pro/features/expenses/presentation/manager/expenses_state.dart';
import 'package:clinic_pro/features/settings/presentation/manager/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'widgets/add_edit_expense_sheet.dart';
import 'widgets/expenses_category_chips.dart';
import 'widgets/expenses_list.dart';
import 'widgets/expenses_target_chips.dart';
import 'widgets/expenses_total_card.dart';

class ExpensesScreen extends StatelessWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsState = context.read<SettingsCubit>().state;
    final clinicId = settingsState.clinicEntity?.id ?? AppConstants.activeClinicId;
    final authUser = context.read<AuthCubit>().state.user;
    final isDoctor = authUser?.role == StaffRoles.doctor;
    final activeDoctorId = isDoctor
        ? authUser?.id
        : (settingsState.currentDoctorId ??
            (AppConstants.activeDoctorId.isNotEmpty
                ? AppConstants.activeDoctorId
                : null));

    return BlocProvider(
      create: (_) => sl<ExpensesCubit>()
        ..loadExpenses(
          clinicId: clinicId,
          doctorId: activeDoctorId,
          onlyClinicExpenses: false,
        ),
      child: const _ExpensesBody(),
    );
  }
}

class _ExpensesBody extends StatelessWidget {
  const _ExpensesBody();

  @override
  Widget build(BuildContext context) {
    final settingsState = context.watch<SettingsCubit>().state;
    final clinicId = settingsState.clinicEntity?.id ?? AppConstants.activeClinicId;
    final authUser = context.watch<AuthCubit>().state.user;
    final isDoctor = authUser?.role == StaffRoles.doctor;
    final activeDoctorId = isDoctor
        ? authUser?.id
        : (settingsState.currentDoctorId ??
            (AppConstants.activeDoctorId.isNotEmpty
                ? AppConstants.activeDoctorId
                : null));

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
            return AppErrorWidget.buildErrorView(
              context: context,
              error: state.message,
              onRetry: () => context.read<ExpensesCubit>().loadExpenses(
                    clinicId: clinicId,
                    doctorId: activeDoctorId,
                    onlyClinicExpenses: false,
                  ),
            );
          }

          if (state is ExpensesLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                await context.read<ExpensesCubit>().loadExpenses(
                      clinicId: clinicId,
                      doctorId: activeDoctorId,
                      onlyClinicExpenses: false,
                    );
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: ResponsiveHelper.responsiveCenter(
                  maxWidth: 900,
                  child: Column(
                    children: [
                      ExpensesTotalCard(state: state),
                      if (!isDoctor) ...[
                        const SizedBox(height: 12),
                        ExpensesTargetChips(
                          activeTargetFilter: state.activeTargetFilter,
                          onChanged: (target) => context
                              .read<ExpensesCubit>()
                              .changeTargetFilter(target),
                        ),
                      ],
                      const SizedBox(height: 12),
                      ExpensesCategoryChips(
                        categories: state.categories,
                        activeCategoryId: state.activeCategoryId,
                        onChanged: (catId) =>
                            context.read<ExpensesCubit>().changeCategory(catId),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppStrings.expenses,
                              style:
                                  AppTextStyles.bodyMedium(context).copyWith(
                                fontWeight: FontWeight.bold,
                                color: context.textPrimary,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: context.primaryLightColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: context.primary.withOpacity(0.15),
                                ),
                              ),
                              child: Text(
                                AppStrings.isArabic
                                    ? '${state.filteredExpenses.length} مصروف'
                                    : '${state.filteredExpenses.length} items',
                                style: AppTextStyles.caption(context).copyWith(
                                  color: context.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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
                ),
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

  void _confirmDelete(BuildContext context, ExpensesEntity expense) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.deleteExpense),
        content: Text(
          AppStrings.isArabic
              ? 'هل أنت متأكد من حذف "${expense.title}"؟'
              : 'Are you sure you want to delete "${expense.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success =
                  await context.read<ExpensesCubit>().deleteExpense(expense.id);
              if (success && context.mounted) {
                AppSnackbar.success(context, message: AppStrings.expenseDeleted);
              }
            },
            child: Text(
              AppStrings.delete,
              style: TextStyle(color: context.danger),
            ),
          ),
        ],
      ),
    );
  }
}

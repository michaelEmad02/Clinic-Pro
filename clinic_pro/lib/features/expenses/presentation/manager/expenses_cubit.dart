// ────────────────────────────────────────────────────────
// Cubit شاشة المصروفات — تحميل وإضافة وتعديل وحذف (Mock)
// ────────────────────────────────────────────────────────

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/mocks/mock_data.dart';
import 'expenses_state.dart';

class ExpensesCubit extends Cubit<ExpensesState> {
  ExpensesCubit() : super(ExpensesInitial());

  /// قائمة بفئات المصروفات لعرضها في الفلاتر
  List<Map<String, dynamic>> get categories => MockData.expenseCategories;

  Future<void> loadExpenses() async {
    emit(ExpensesLoading());
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final items = _mapExpensesFromMock();
      emit(ExpensesLoaded(allExpenses: items));
    } catch (_) {
      emit(const ExpensesError('تعذّر تحميل المصروفات'));
    }
  }

  void changeCategory(String? categoryId) {
    if (state is ExpensesLoaded) {
      emit((state as ExpensesLoaded).copyWith(
          activeCategoryId: categoryId));
    }
  }

  Future<void> addExpense({
    required String title,
    required double amount,
    required String categoryId,
    required String categoryLabel,
    String notes = '',
  }) async {
    if (state is! ExpensesLoaded) return;
    final loaded = state as ExpensesLoaded;
    await Future.delayed(const Duration(milliseconds: 400));

    final newExpense = ExpenseItem(
      id: 'exp-new-${DateTime.now().millisecondsSinceEpoch}',
      clinicId: 'c-1',
      title: title,
      amount: amount,
      categoryId: categoryId,
      categoryLabel: categoryLabel,
      date: DateTime.now().toIso8601String().substring(0, 10),
      notes: notes,
      createdBy: 'u-owner-1',
    );

    emit(loaded.copyWith(
        allExpenses: [newExpense, ...loaded.allExpenses]));
  }

  Future<void> updateExpense({
    required String expenseId,
    required String title,
    required double amount,
    required String categoryId,
    required String categoryLabel,
    String notes = '',
  }) async {
    if (state is! ExpensesLoaded) return;
    final loaded = state as ExpensesLoaded;
    await Future.delayed(const Duration(milliseconds: 300));

    final list = loaded.allExpenses.map((e) {
      if (e.id != expenseId) return e;
      return e.copyWith(
        title: title,
        amount: amount,
        categoryId: categoryId,
        categoryLabel: categoryLabel,
        notes: notes,
      );
    }).toList();

    emit(loaded.copyWith(allExpenses: list));
  }

  Future<void> deleteExpense(String expenseId) async {
    if (state is! ExpensesLoaded) return;
    final loaded = state as ExpensesLoaded;
    await Future.delayed(const Duration(milliseconds: 300));

    final list = loaded.allExpenses
        .where((e) => e.id != expenseId)
        .toList();

    emit(loaded.copyWith(allExpenses: list));
  }

  List<ExpenseItem> _mapExpensesFromMock() {
    final categories = MockData.expenseCategories;
    final catMap = {for (var c in categories) c['id'] as String: c['label'] as String};

    return MockData.expenses.map((exp) {
      final catId = exp['category_id'] as String;
      return ExpenseItem(
        id: exp['id'] as String,
        clinicId: exp['clinic_id'] as String? ?? 'c-1',
        title: exp['title'] as String,
        amount: (exp['amount'] as num).toDouble(),
        categoryId: catId,
        categoryLabel: catMap[catId] ?? 'أخرى',
        date: exp['date'] as String,
        notes: (exp['notes'] as String?) ?? '',
        createdBy: exp['created_by'] as String,
      );
    }).toList();
  }
}

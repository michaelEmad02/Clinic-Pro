// ────────────────────────────────────────────────────────
// Cubit شاشة المصروفات — تحميل وإضافة وتعديل وحذف (Repository)
// ────────────────────────────────────────────────────────

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'expenses_repository.dart';
import 'expenses_state.dart';

@injectable
class ExpensesCubit extends Cubit<ExpensesState> {
  final ExpensesRepository _repository;

  ExpensesCubit(this._repository) : super(ExpensesInitial());

  Future<void> loadExpenses() async {
    emit(ExpensesLoading());

    try {
      final categories = await _repository.loadCategories();
      final items = await _repository.loadExpenses();
      emit(ExpensesLoaded(
        allExpenses: items,
        categories: categories,
      ));
    } catch (_) {
      emit(const ExpensesError('تعذّر تحميل المصروفات'));
    }
  }

  void changeCategory(String? categoryId) {
    if (state is ExpensesLoaded) {
      final loaded = state as ExpensesLoaded;
      emit(ExpensesLoaded(
        allExpenses: loaded.allExpenses,
        categories: loaded.categories,
        activeCategoryId: categoryId,
      ));
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

    try {
      final newExpense = await _repository.addExpense(
        title: title,
        amount: amount,
        categoryId: categoryId,
        categoryLabel: categoryLabel,
        notes: notes,
      );
      emit(loaded.copyWith(
          allExpenses: [newExpense, ...loaded.allExpenses]));
    } catch (_) {
      emit(const ExpensesError('تعذّر إضافة المصروف'));
    }
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

    try {
      final updated = await _repository.updateExpense(
        expenseId: expenseId,
        title: title,
        amount: amount,
        categoryId: categoryId,
        categoryLabel: categoryLabel,
        notes: notes,
      );
      final list = loaded.allExpenses.map((e) {
        return e.id == expenseId ? updated : e;
      }).toList();
      emit(loaded.copyWith(allExpenses: list));
    } catch (_) {
      emit(const ExpensesError('تعذّر تعديل المصروف'));
    }
  }

  Future<void> deleteExpense(String expenseId) async {
    if (state is! ExpensesLoaded) return;
    final loaded = state as ExpensesLoaded;

    try {
      await _repository.deleteExpense(expenseId);
      final list = loaded.allExpenses
          .where((e) => e.id != expenseId)
          .toList();
      emit(loaded.copyWith(allExpenses: list));
    } catch (_) {
      emit(const ExpensesError('تعذّر حذف المصروف'));
    }
  }
}

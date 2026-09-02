// ────────────────────────────────────────────────────────
// ExpensesCubit — إدارة حالة شاشة المصروفات
// يتفاعل حصراً مع Domain UseCases لعزل منطق الأعمال عن الواجهة
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/features/expenses/domain/entities/expense_category_entity.dart';
import 'package:clinic_pro/features/expenses/domain/entities/expenses_entity.dart';
import 'package:clinic_pro/features/expenses/domain/use_cases/add_expenses_use_case.dart';
import 'package:clinic_pro/features/expenses/domain/use_cases/delete_expenses_use_case.dart';
import 'package:clinic_pro/features/expenses/domain/use_cases/edit_expenses_use_case.dart';
import 'package:clinic_pro/features/expenses/domain/use_cases/fetch_categories_use_case.dart';
import 'package:clinic_pro/features/expenses/domain/use_cases/fetch_expenses_use_case.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'expenses_state.dart';

@injectable
class ExpensesCubit extends Cubit<ExpensesState> {
  final FetchExpensesUseCase _fetchExpensesUseCase;
  final FetchCategoriesUseCase _fetchCategoriesUseCase;
  final AddExpensesUseCase _addExpensesUseCase;
  final EditExpensesUseCase _editExpensesUseCase;
  final DeleteExpensesUseCase _deleteExpensesUseCase;

  ExpensesCubit(
    this._fetchExpensesUseCase,
    this._fetchCategoriesUseCase,
    this._addExpensesUseCase,
    this._editExpensesUseCase,
    this._deleteExpensesUseCase,
  ) : super(ExpensesInitial());

  /// تحميل المصروفات والتصنيفات
  /// - للمالك: يتم تمرير [onlyClinicExpenses] = true لعرض مصاريف العيادة العامة فقط.
  /// - للطبيب: يتم تمرير [doctorId] = معرف الطبيب لعرض مصاريفه الشخصية فقط.
  Future<void> loadExpenses({
    required String clinicId,
    String? ownerId,
    String? doctorId,
    bool onlyClinicExpenses = false,
  }) async {
    emit(ExpensesLoading());

    // 1. جلب التصنيفات
    final categoriesResult = await _fetchCategoriesUseCase();
    List<ExpenseCategoryEntity> categories = [];
    categoriesResult.fold(
      (failure) => null,
      (cats) => categories = cats,
    );

    // 2. جلب المصروفات
    final expensesResult = await _fetchExpensesUseCase(
      clinicId: clinicId,
      ownerId: ownerId,
      doctorId: doctorId,
      onlyClinicExpenses: onlyClinicExpenses,
    );

    expensesResult.fold(
      (failure) => emit(ExpensesError(failure.message)),
      (expenses) => emit(ExpensesLoaded(
        allExpenses: expenses,
        categories: categories,
        currentDoctorId: doctorId,
        activeTargetFilter:
            (doctorId != null && doctorId.isNotEmpty) ? 'doctor' : 'clinic',
      )),
    );
  }

  /// تغيير التصنيف النشط في شريط الفلترة
  void changeCategory(String? categoryId) {
    if (state is! ExpensesLoaded) return;
    final loaded = state as ExpensesLoaded;

    if (categoryId == null || categoryId.isEmpty) {
      emit(loaded.copyWith(clearActiveCategory: true));
    } else {
      emit(loaded.copyWith(activeCategoryId: categoryId));
    }
  }

  /// تغيير فلتر الجهة المتحملة للمصروف (الكل / العيادة / الأطباء / طبيب معين)
  void changeTargetFilter(String targetFilter) {
    if (state is! ExpensesLoaded) return;
    final loaded = state as ExpensesLoaded;

    emit(loaded.copyWith(activeTargetFilter: targetFilter));
  }

  /// إضافة مصروف جديد
  Future<bool> addExpense({
    required String clinicId,
    required String title,
    required double amount,
    required String categoryId,
    required String categoryName,
    String? notes,
    String? doctorId,
    required String createdBy,
  }) async {
    if (state is! ExpensesLoaded) return false;
    final loaded = state as ExpensesLoaded;

    final newExpense = ExpensesEntity(
      id: '',
      clinicId: clinicId,
      categoryId: categoryId,
      categoryName: categoryName,
      title: title,
      amount: amount,
      notes: notes,
      doctorId: doctorId,
      createdBy: createdBy,
      createdAt: DateTime.now(),
    );

    final result = await _addExpensesUseCase(newExpense);

    return result.fold(
      (failure) {
        emit(ExpensesError(failure.message));
        return false;
      },
      (createdExpense) {
        emit(loaded.copyWith(
          allExpenses: [createdExpense, ...loaded.allExpenses],
        ));
        return true;
      },
    );
  }

  /// تعديل مصروف موجود
  Future<bool> updateExpense(ExpensesEntity updatedExpense) async {
    if (state is! ExpensesLoaded) return false;
    final loaded = state as ExpensesLoaded;

    final result = await _editExpensesUseCase(updatedExpense);

    return result.fold(
      (failure) {
        emit(ExpensesError(failure.message));
        return false;
      },
      (savedExpense) {
        final updatedList = loaded.allExpenses.map((exp) {
          return exp.id == savedExpense.id ? savedExpense : exp;
        }).toList();

        emit(loaded.copyWith(allExpenses: updatedList));
        return true;
      },
    );
  }

  /// حذف مصروف
  Future<bool> deleteExpense(String expenseId) async {
    if (state is! ExpensesLoaded) return false;
    final loaded = state as ExpensesLoaded;

    final result = await _deleteExpensesUseCase(expenseId);

    return result.fold(
      (failure) {
        emit(ExpensesError(failure.message));
        return false;
      },
      (_) {
        final updatedList =
            loaded.allExpenses.where((exp) => exp.id != expenseId).toList();
        emit(loaded.copyWith(allExpenses: updatedList));
        return true;
      },
    );
  }
}

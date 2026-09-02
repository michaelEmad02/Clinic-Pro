// ────────────────────────────────────────────────────────
// ExpensesState — حالات شاشة المصروفات
// تدير عرض المصروفات وفلترة التصنيفات وحساب الإجماليات
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/features/expenses/domain/entities/expense_category_entity.dart';
import 'package:clinic_pro/features/expenses/domain/entities/expenses_entity.dart';
import 'package:equatable/equatable.dart';

abstract class ExpensesState extends Equatable {
  const ExpensesState();

  @override
  List<Object?> get props => [];
}

class ExpensesInitial extends ExpensesState {}

class ExpensesLoading extends ExpensesState {}

class ExpensesLoaded extends ExpensesState {
  final List<ExpensesEntity> allExpenses;
  final List<ExpenseCategoryEntity> categories;
  final String? activeCategoryId;
  final String activeTargetFilter; // 'clinic' | 'doctor'
  final String? currentDoctorId;

  const ExpensesLoaded({
    required this.allExpenses,
    required this.categories,
    this.activeCategoryId,
    this.activeTargetFilter = 'clinic',
    this.currentDoctorId,
  });

  /// المصروفات بعد تطبيق فلترة التصنيف والجهة المتحملة (العيادة أو الطبيب الحالي)
  List<ExpensesEntity> get filteredExpenses {
    final expenses = allExpenses.where((e) {
      // 1. فلترة التصنيف
      if (activeCategoryId != null && activeCategoryId!.isNotEmpty) {
        if (e.categoryId != activeCategoryId) return false;
      }

      // 2. فلترة الجهة المتحملة
      if (activeTargetFilter == 'doctor') {
        if (currentDoctorId != null && currentDoctorId!.isNotEmpty) {
          return e.doctorId == currentDoctorId;
        }
        return e.isDoctorExpense;
      } else if (activeTargetFilter == 'clinic') {
        return e.isClinicExpense;
      }

      return true;
    }).toList();

    return expenses;
  }

  /// إجمالي المبالغ للمصروفات المعروضة
  double get totalAmount =>
      filteredExpenses.fold(0.0, (sum, e) => sum + e.amount);

  /// نص الإجمالي المنسق
  String get totalLabel {
    if (totalAmount >= 1000) {
      return '${(totalAmount / 1000).toStringAsFixed(1)} ألف';
    }
    return totalAmount.toStringAsFixed(0);
  }

  ExpensesLoaded copyWith({
    List<ExpensesEntity>? allExpenses,
    List<ExpenseCategoryEntity>? categories,
    String? activeCategoryId,
    String? activeTargetFilter,
    String? currentDoctorId,
    bool clearActiveCategory = false,
  }) {
    return ExpensesLoaded(
      allExpenses: allExpenses ?? this.allExpenses,
      categories: categories ?? this.categories,
      activeCategoryId: clearActiveCategory
          ? null
          : (activeCategoryId ?? this.activeCategoryId),
      activeTargetFilter: activeTargetFilter ?? this.activeTargetFilter,
      currentDoctorId: currentDoctorId ?? this.currentDoctorId,
    );
  }

  @override
  List<Object?> get props =>
      [allExpenses, categories, activeCategoryId, activeTargetFilter, currentDoctorId];
}

class ExpensesError extends ExpensesState {
  final String message;

  const ExpensesError(this.message);

  @override
  List<Object?> get props => [message];
}

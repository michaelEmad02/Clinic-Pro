// ────────────────────────────────────────────────────────
// حالات شاشة المصروفات — نموذج ExpenseItem وفلاتر التصنيف
// ────────────────────────────────────────────────────────

import 'package:equatable/equatable.dart';

class ExpenseItem extends Equatable {
  final String id;
  final String clinicId;
  final String title;
  final double amount;
  final String categoryId;
  final String categoryLabel;
  final String date;
  final String notes;
  final String createdBy;

  const ExpenseItem({
    required this.id,
    this.clinicId = 'c-1',
    required this.title,
    required this.amount,
    required this.categoryId,
    required this.categoryLabel,
    required this.date,
    required this.notes,
    required this.createdBy,
  });

  String get formattedDate {
    final dateTime = DateTime.tryParse(date);
    if (dateTime == null) return date;
    final months = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year}';
  }

  ExpenseItem copyWith({
    String? title,
    double? amount,
    String? categoryId,
    String? categoryLabel,
    String? notes,
  }) {
    return ExpenseItem(
      id: id,
      clinicId: clinicId,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      categoryLabel: categoryLabel ?? this.categoryLabel,
      date: date,
      notes: notes ?? this.notes,
      createdBy: createdBy,
    );
  }

  @override
  List<Object?> get props => [id, clinicId, title, amount, categoryId];
}

abstract class ExpensesState extends Equatable {
  const ExpensesState();
  @override
  List<Object?> get props => [];
}

class ExpensesInitial extends ExpensesState {}

class ExpensesLoading extends ExpensesState {}

class ExpensesLoaded extends ExpensesState {
  final List<ExpenseItem> allExpenses;
  final String? activeCategoryId;

  const ExpensesLoaded({
    required this.allExpenses,
    this.activeCategoryId,
  });

  List<ExpenseItem> get filteredExpenses {
    if (activeCategoryId == null) return allExpenses;
    return allExpenses
        .where((e) => e.categoryId == activeCategoryId)
        .toList();
  }

  double get totalAmount =>
      filteredExpenses.fold(0.0, (sum, e) => sum + e.amount);

  String get totalLabel {
    if (totalAmount >= 1000) {
      return '${(totalAmount / 1000).toStringAsFixed(1)} ألف';
    }
    return totalAmount.toStringAsFixed(0);
  }

  ExpensesLoaded copyWith({
    List<ExpenseItem>? allExpenses,
    String? activeCategoryId,
  }) {
    return ExpensesLoaded(
      allExpenses: allExpenses ?? this.allExpenses,
      activeCategoryId: activeCategoryId ?? this.activeCategoryId,
    );
  }

  @override
  List<Object?> get props => [allExpenses, activeCategoryId];
}

class ExpensesError extends ExpensesState {
  final String message;
  const ExpensesError(this.message);
  @override
  List<Object?> get props => [message];
}

// ────────────────────────────────────────────────────────
// ExpenseCategoryEntity — كيان فئة/تصنيف المصروف بـ Domain Layer
// يمثل التصنيف الديناميكي للمصروف من جدول expense_categories
// ────────────────────────────────────────────────────────

import 'package:equatable/equatable.dart';

class ExpenseCategoryEntity extends Equatable {
  final String id;
  final String name;

  const ExpenseCategoryEntity({
    required this.id,
    required this.name,
  });

  @override
  List<Object?> get props => [id, name];
}

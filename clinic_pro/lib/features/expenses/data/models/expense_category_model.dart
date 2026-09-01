// ────────────────────────────────────────────────────────
// ExpenseCategoryModel — نموذج بيانات فئة المصروف
// يحول البيانات الخام من جدول expense_categories إلى ExpenseCategoryEntity
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/features/expenses/domain/entities/expense_category_entity.dart';

class ExpenseCategoryModel extends ExpenseCategoryEntity {
  const ExpenseCategoryModel({
    required super.id,
    required super.name,
  });

  factory ExpenseCategoryModel.fromJson(Map<String, dynamic> json) {
    return ExpenseCategoryModel(
      id: json['id'] as String? ?? '',
      name: (json['name'] ?? json['label'] ?? '') as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

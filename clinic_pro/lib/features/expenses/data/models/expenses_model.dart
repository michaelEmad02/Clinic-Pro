// ────────────────────────────────────────────────────────
// ExpenseModel — نموذج بيانات المصروف بـ Data Layer
// يحول البيانات الخام من جدول expenses إلى ExpensesEntity
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/features/expenses/domain/entities/expenses_entity.dart';

class ExpenseModel extends ExpensesEntity {
  const ExpenseModel({
    required super.id,
    required super.clinicId,
    required super.categoryId,
    required super.categoryName,
    required super.title,
    required super.amount,
    super.notes,
    super.doctorId,
    required super.createdBy,
    super.createdByName,
    required super.createdAt,
  });

  factory ExpenseModel.fromJson(
    Map<String, dynamic> json, {
    String? categoryName,
    String? createdByName,
  }) {
    final createdAtRaw = json['created_at'];
    DateTime parsedCreatedAt;
    if (createdAtRaw is String) {
      parsedCreatedAt = DateTime.tryParse(createdAtRaw) ?? DateTime.now();
    } else if (createdAtRaw is DateTime) {
      parsedCreatedAt = createdAtRaw;
    } else {
      parsedCreatedAt = DateTime.now();
    }

    // استخراج اسم التصنيف إن وجد في الـ join أو تم تمريره
    String resolvedCategoryName = categoryName ?? '';
    if (resolvedCategoryName.isEmpty && json['expense_categories'] != null) {
      final catObj = json['expense_categories'];
      if (catObj is Map) {
        resolvedCategoryName = (catObj['name'] ?? catObj['label'] ?? '') as String;
      }
    }

    // استخراج اسم منشئ المصروف إن وجد في العلاقة مع users
    String? resolvedCreatedByName = createdByName;
    if (resolvedCreatedByName == null || resolvedCreatedByName.isEmpty) {
      final userObj = json['users'] ?? json['created_by_user'];
      if (userObj is Map) {
        resolvedCreatedByName = (userObj['name'] ?? userObj['full_name'] ?? '') as String?;
      }
    }

    return ExpenseModel(
      id: json['id'] as String? ?? '',
      clinicId: json['clinic_id'] as String? ?? '',
      categoryId: json['category_id'] as String? ?? '',
      categoryName: resolvedCategoryName,
      title: (json['title'] ?? json['notes'] ?? 'مصروف بدون عنوان') as String,
      amount: ((json['amount'] ?? 0) as num).toDouble(),
      notes: json['notes'] as String?,
      doctorId: json['doctor_id'] as String?,
      createdBy: json['created_by'] as String? ?? '',
      createdByName: resolvedCreatedByName,
      createdAt: parsedCreatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'clinic_id': clinicId,
      'category_id': categoryId,
      'title': title,
      'amount': amount,
      'notes': notes,
      'doctor_id': doctorId,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

// ────────────────────────────────────────────────────────
// هذا الملف مسؤول عن إدارة عمليات المصروفات
// يستخدم ICloudService كطبقة تواصل مع قاعدة البيانات
// ────────────────────────────────────────────────────────

import 'package:injectable/injectable.dart';
import 'package:clinic_pro/core/services/i_cloud_service.dart';
import 'expenses_state.dart';

@injectable
class ExpensesRepository {
  final ICloudService _cloud;

  ExpensesRepository(this._cloud);

  Future<List<ExpenseCategory>> loadCategories() async {
    final data = await _cloud.select(table: 'expense_categories');
    return data.map((raw) => ExpenseCategory(
      id: raw['id'] as String,
      name: (raw['label'] ?? raw['name']) as String,
    )).toList();
  }

  Future<List<ExpenseItem>> loadExpenses() async {
    final data = await _cloud.select(table: 'expenses');
    final categories = await loadCategories();
    final catMap = {for (var c in categories) c.id: c.name};

    return data.map((exp) => ExpenseItem(
      id: exp['id'] as String,
      clinicId: exp['clinic_id'] as String? ?? '',
      title: exp['title'] as String,
      amount: (exp['amount'] as num).toDouble(),
      categoryId: exp['category_id'] as String,
      categoryLabel: catMap[exp['category_id'] as String] ?? 'أخرى',
      date: exp['date'] as String,
      notes: (exp['notes'] as String?) ?? '',
      createdBy: exp['created_by'] as String,
    )).toList();
  }

  Future<ExpenseItem> addExpense({
    required String title,
    required double amount,
    required String categoryId,
    required String categoryLabel,
    String notes = '',
  }) async {
    final data = await _cloud.insert(table: 'expenses', data: {
      'title': title,
      'amount': amount,
      'category_id': categoryId,
      'notes': notes,
      'date': DateTime.now().toIso8601String().substring(0, 10),
      'created_by': 'u-owner-1',
    });
    return ExpenseItem(
      id: data['id'] as String,
      clinicId: data['clinic_id'] as String? ?? '',
      title: data['title'] as String,
      amount: (data['amount'] as num).toDouble(),
      categoryId: data['category_id'] as String,
      categoryLabel: categoryLabel,
      date: data['date'] as String,
      notes: (data['notes'] as String?) ?? '',
      createdBy: data['created_by'] as String,
    );
  }

  Future<ExpenseItem> updateExpense({
    required String expenseId,
    required String title,
    required double amount,
    required String categoryId,
    required String categoryLabel,
    String notes = '',
  }) async {
    final data = await _cloud.update(
      table: 'expenses',
      data: {
        'title': title,
        'amount': amount,
        'category_id': categoryId,
        'notes': notes,
      },
      matchColumn: 'id',
      matchValue: expenseId,
    );
    final updated = data.first;
    return ExpenseItem(
      id: updated['id'] as String,
      clinicId: updated['clinic_id'] as String? ?? '',
      title: updated['title'] as String,
      amount: (updated['amount'] as num).toDouble(),
      categoryId: updated['category_id'] as String,
      categoryLabel: categoryLabel,
      date: updated['date'] as String,
      notes: (updated['notes'] as String?) ?? '',
      createdBy: updated['created_by'] as String,
    );
  }

  Future<void> deleteExpense(String expenseId) async {
    await _cloud.delete(
      table: 'expenses',
      matchColumn: 'id',
      matchValue: expenseId,
    );
  }
}

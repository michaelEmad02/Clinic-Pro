// ────────────────────────────────────────────────────────
// هذا الملف مسؤول عن إدارة عمليات المصروفات
// يستخدم ICloudService كطبقة تواصل مع قاعدة البيانات
// ────────────────────────────────────────────────────────

import 'package:injectable/injectable.dart';
import 'package:clinic_pro/core/services/i_cloud_service.dart';
import 'package:clinic_pro/core/services/i_auth_services.dart';
import 'package:clinic_pro/core/constants/app_constants.dart';
import 'package:clinic_pro/core/di/injection_container.dart';
import 'expenses_state.dart';

@injectable
class ExpensesRepository {
  final ICloudService _cloud;
  late final IAuthServices _auth;

  ExpensesRepository(this._cloud) {
    _auth = sl<IAuthServices>();
  }

  Future<List<ExpenseCategory>> loadCategories() async {
    final data = await _cloud.select(table: 'expense_categories');
    return data.map((raw) => ExpenseCategory(
      id: raw['id'] as String,
      name: (raw['label'] ?? raw['name']) as String,
    )).toList();
  }

  Future<List<ExpenseItem>> loadExpenses() async {
    final clinicId = AppConstants.activeClinicId;
    final data = await _cloud.select(
      table: 'expenses',
      eq: clinicId.isNotEmpty ? {'clinic_id': clinicId} : null,
    );
    final categories = await loadCategories();
    final catMap = {for (var c in categories) c.id: c.name};

    return data.map((exp) => ExpenseItem(
      id: exp['id'] as String,
      clinicId: exp['clinic_id'] as String? ?? '',
      title: (exp['title'] ?? exp['notes'] ?? 'مصروف بدون عنوان') as String,
      amount: (exp['amount'] as num).toDouble(),
      categoryId: exp['category_id'] as String,
      categoryLabel: catMap[exp['category_id'] as String] ?? 'أخرى',
      date: (exp['date'] ?? exp['created_at'] ?? DateTime.now().toIso8601String()) as String,
      notes: (exp['title'] != null ? exp['notes'] as String? : '') ?? '',
      createdBy: exp['created_by'] as String? ?? '',
    )).toList();
  }

  Future<ExpenseItem> addExpense({
    required String title,
    required double amount,
    required String categoryId,
    required String categoryLabel,
    String notes = '',
  }) async {
    final userId = await _auth.getCurrentUserId() ?? 'u-owner-1';
    final clinicId = AppConstants.activeClinicId.isNotEmpty
        ? AppConstants.activeClinicId
        : 'c-1';

    final data = await _cloud.insert(table: 'expenses', data: {
      'title': title, // متوافق مع البيانات الوهمية
      'notes': notes.isNotEmpty ? '$title - $notes' : title, // متوافق مع Supabase
      'amount': amount,
      'category_id': categoryId,
      'date': DateTime.now().toIso8601String().substring(0, 10), // متوافق مع البيانات الوهمية
      'clinic_id': clinicId,
      'created_by': userId,
    });

    return ExpenseItem(
      id: data['id'] as String,
      clinicId: data['clinic_id'] as String? ?? '',
      title: (data['title'] ?? data['notes'] ?? title) as String,
      amount: (data['amount'] as num).toDouble(),
      categoryId: data['category_id'] as String,
      categoryLabel: categoryLabel,
      date: (data['date'] ?? data['created_at'] ?? DateTime.now().toIso8601String().substring(0, 10)) as String,
      notes: (data['title'] != null ? data['notes'] as String? : '') ?? '',
      createdBy: data['created_by'] as String? ?? '',
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
        'notes': notes.isNotEmpty ? '$title - $notes' : title,
        'amount': amount,
        'category_id': categoryId,
      },
      matchColumn: 'id',
      matchValue: expenseId,
    );
    final updated = data.first;
    return ExpenseItem(
      id: updated['id'] as String,
      clinicId: updated['clinic_id'] as String? ?? '',
      title: (updated['title'] ?? updated['notes'] ?? title) as String,
      amount: (updated['amount'] as num).toDouble(),
      categoryId: updated['category_id'] as String,
      categoryLabel: categoryLabel,
      date: (updated['date'] ?? updated['created_at'] ?? DateTime.now().toIso8601String().substring(0, 10)) as String,
      notes: (updated['title'] != null ? updated['notes'] as String? : '') ?? '',
      createdBy: updated['created_by'] as String? ?? '',
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

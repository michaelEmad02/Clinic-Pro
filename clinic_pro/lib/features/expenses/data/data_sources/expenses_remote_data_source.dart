// ────────────────────────────────────────────────────────
// ExpensesRemoteDataSource — مصدر البيانات البعيد للمصروفات
// يتواصل مع Supabase لجلب وحفظ وتعديل وحذف المصروفات وفئاتها
// يقوم بربط أسماء التصنيفات من جهة Flutter (Flutter-side relation resolution)
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/constants/supabase_constants.dart';
import 'package:clinic_pro/core/services/i_cloud_service.dart';
import 'package:clinic_pro/features/expenses/data/models/expense_category_model.dart';
import 'package:clinic_pro/features/expenses/data/models/expenses_model.dart';
import 'package:injectable/injectable.dart';

abstract class IExpensesRemoteDataSource {
  Future<List<ExpenseCategoryModel>> fetchCategories();
  Future<List<ExpenseModel>> fetchExpenses({
    required String clinicId,
    String? doctorId,
    bool onlyClinicExpenses = false,
  });
  Future<ExpenseModel> addExpense(ExpenseModel expense);
  Future<ExpenseModel> updateExpense(ExpenseModel expense);
  Future<void> deleteExpense(String expenseId);
}

@LazySingleton(as: IExpensesRemoteDataSource)
class ExpensesRemoteDataSourceImpl implements IExpensesRemoteDataSource {
  final ICloudService _cloudService;

  ExpensesRemoteDataSourceImpl(this._cloudService);

  @override
  Future<List<ExpenseCategoryModel>> fetchCategories() async {
    // جلب جميع تصنيفات المصروفات
    final data = await _cloudService.select(
      table: SupabaseTables.expenseCategories,
    );

    return data
        .map((json) => ExpenseCategoryModel.fromJson(json))
        .toList();
  }

  @override
  Future<List<ExpenseModel>> fetchExpenses({
    required String clinicId,
    String? doctorId,
    bool onlyClinicExpenses = false,
  }) async {
    // 1. بناء شروط الاستعلام بحسب الدور (عيادة أم طبيب)
    final Map<String, dynamic> queryFilters = {};
    if (clinicId.isNotEmpty) {
      queryFilters['clinic_id'] = clinicId;
    }
    if (doctorId != null && doctorId.isNotEmpty) {
      queryFilters['doctor_id'] = doctorId;
    }

    // 2. جلب المصروفات مع الـ JOIN المباشر لجدولي expense_categories و users في استعلام واحد
    final rawExpenses = await _cloudService.select(
      table: SupabaseTables.expenses,
      columns: '*, expense_categories(id, name), users!created_by(id, name)',
      eq: queryFilters.isNotEmpty ? queryFilters : null,
    );

    // 3. فلترة مصاريف العيادة العامة (حيث doctor_id == null) إن طُلب ذلك للمالك
    var filteredList = rawExpenses;
    if (onlyClinicExpenses) {
      filteredList = rawExpenses.where((item) {
        final docId = item['doctor_id'];
        return docId == null || docId.toString().isEmpty;
      }).toList();
    }

    // 4. تحويل النتائج وترتيبها تنازلياً حسب تاريخ الإنشاء
    final expenses = filteredList
        .map((item) => ExpenseModel.fromJson(item))
        .toList();

    expenses.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return expenses;
  }

  @override
  Future<ExpenseModel> addExpense(ExpenseModel expense) async {
    final payload = expense.toJson();
    payload.remove('id'); // إنشاء المعرف تلقائياً في السيرفر

    final inserted = await _cloudService.insert(
      table: SupabaseTables.expenses,
      data: payload,
    );

    return ExpenseModel.fromJson(
      inserted,
      categoryName: expense.categoryName,
    );
  }

  @override
  Future<ExpenseModel> updateExpense(ExpenseModel expense) async {
    final payload = {
      'title': expense.title,
      'amount': expense.amount,
      'category_id': expense.categoryId,
      'notes': expense.notes,
      'doctor_id': expense.doctorId,
    };

    final updated = await _cloudService.update(
      table: SupabaseTables.expenses,
      data: payload,
      matchColumn: 'id',
      matchValue: expense.id,
    );

    final updatedMap = updated.isNotEmpty ? updated.first : payload;
    return ExpenseModel.fromJson(
      {
        ...updatedMap,
        'id': expense.id,
        'clinic_id': expense.clinicId,
        'doctor_id': expense.doctorId,
        'created_by': expense.createdBy,
        'created_at': expense.createdAt.toIso8601String(),
      },
      categoryName: expense.categoryName,
    );
  }

  @override
  Future<void> deleteExpense(String expenseId) async {
    await _cloudService.delete(
      table: SupabaseTables.expenses,
      matchColumn: 'id',
      matchValue: expenseId,
    );
  }
}

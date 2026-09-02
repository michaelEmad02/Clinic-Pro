// ────────────────────────────────────────────────────────
// IExpensesRepository — واجهة مستودع المصروفات بـ Domain Layer
// تحدد العقود والعمليات المتاحة لإدارة المصروفات وفئاتها
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/error/failures.dart';
import 'package:clinic_pro/features/expenses/domain/entities/expense_category_entity.dart';
import 'package:clinic_pro/features/expenses/domain/entities/expenses_entity.dart';
import 'package:dartz/dartz.dart';

abstract class IExpensesRepository {
  /// جلب قائمة المصروفات
  /// - إذا تم تمرير [doctorId]: يجلب مصروفات هذا الطبيب فقط.
  /// - إذا كانت [onlyClinicExpenses] = true: يجلب مصروفات العيادة العامة فقط (doctor_id == null).
  Future<Either<Failure, List<ExpensesEntity>>> getExpenses({
    required String clinicId,
    String? ownerId,
    String? doctorId,
    bool onlyClinicExpenses = false,
  });

  /// جلب قائمة تصنيفات المصروفات من جدول expense_categories
  Future<Either<Failure, List<ExpenseCategoryEntity>>> getCategories();

  /// إضافة مصروف جديد
  Future<Either<Failure, ExpensesEntity>> addExpense(ExpensesEntity expense);

  /// تعديل مصروف موجود
  Future<Either<Failure, ExpensesEntity>> updateExpense(ExpensesEntity expense);

  /// حذف مصروف بواسطة المعرف
  Future<Either<Failure, Unit>> deleteExpense(String expenseId);
}

// ────────────────────────────────────────────────────────
// ITextParser — واجهة تحليل النصوص واستخراج بيانات المصروف
// تُمكن من استبدال خوارزمية التحليل (Regex أو AI مستقبلاً)
// دون الحاجة لتعديل بقية طبقات التطبيق (Dependency Inversion)
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/features/expenses/domain/entities/expense_category_entity.dart';
import 'package:clinic_pro/features/expenses/domain/entities/parsed_expense_entity.dart';

abstract class ITextParser {
  /// تحليل النص واستخراج بيانات المصروف ومطابقة الفئة مع الفئات المتاحة
  Future<ParsedExpenseEntity?> parseExpense({
    required String text,
    required List<ExpenseCategoryEntity> categories,
  });
}

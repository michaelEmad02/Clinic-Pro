// ────────────────────────────────────────────────────────
// ParsedExpenseEntity — كيان البيانات المستخرجة من النص الصوتي
// يمثل نتيجة تحليل الجملة المنطوقة (المبلغ، التصنيف، العنوان، الملاحظات)
// ────────────────────────────────────────────────────────

import 'package:equatable/equatable.dart';

class ParsedExpenseEntity extends Equatable {
  /// المبلغ المستخرج من النص (مثل 150.0)
  final double amount;

  /// معرف التصنيف إن تم التعرف عليه ومطابقته مع قائمة الفئات
  final String? categoryId;

  /// اسم التصنيف إن وجد
  final String? categoryName;

  /// عنوان المصروف (مثل "فاتورة كهرباء" أو "أدوات تعقيم")
  final String title;

  /// أي تفاصيل إضافية أو ملاحظات تم استنتاجها
  final String? notes;

  const ParsedExpenseEntity({
    required this.amount,
    this.categoryId,
    this.categoryName,
    required this.title,
    this.notes,
  });

  @override
  List<Object?> get props => [amount, categoryId, categoryName, title, notes];
}

// ────────────────────────────────────────────────────────
// RegexExpenseParser — محول نصوص المصروفات
// يعتمد على خدمة IVoiceExtractionService الموحدة بالـ Core
// لتحليل النصوص وتحويلها إلى كيان ParsedExpenseEntity
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/services/i_voice_extraction_service.dart';
import 'package:clinic_pro/features/expenses/domain/entities/expense_category_entity.dart';
import 'package:clinic_pro/features/expenses/domain/entities/parsed_expense_entity.dart';
import 'package:clinic_pro/features/expenses/domain/repositories/i_text_parser.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: ITextParser)
class RegexExpenseParser implements ITextParser {
  final IVoiceExtractionService _extractionService;

  RegexExpenseParser(this._extractionService);

  @override
  Future<ParsedExpenseEntity?> parseExpense({
    required String text,
    required List<ExpenseCategoryEntity> categories,
  }) async {
    final data = await _extractionService.extractData(
      text: text,
      target: ExtractionTarget.expense,
      extraContext: {'categories': categories},
    );

    if (data.isEmpty) return null;

    return ParsedExpenseEntity(
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      categoryId: data['categoryId'] as String?,
      categoryName: data['categoryName'] as String?,
      title: (data['title'] as String?) ?? text,
      notes: data['notes'] as String?,
    );
  }
}

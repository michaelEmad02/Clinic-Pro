// ────────────────────────────────────────────────────────
// ParseExpenseFromTextUseCase — حالة استخدام تحليل نص المصروف واستخراج بياناته
// تفصل بين منطق الأعمال وطريقة التحليل (Regex أو AI) عبر ITextParser
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/error/failures.dart';
import 'package:clinic_pro/features/expenses/domain/entities/expense_category_entity.dart';
import 'package:clinic_pro/features/expenses/domain/entities/parsed_expense_entity.dart';
import 'package:clinic_pro/features/expenses/domain/repositories/i_text_parser.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class ParseExpenseFromTextUseCase {
  final ITextParser _textParser;

  ParseExpenseFromTextUseCase(this._textParser);

  /// تنفيذ تحليل النص واستخراج المصروف
  /// يرجع [ParsedExpenseEntity] في حالة النجاح أو [Failure] عند الفشل
  Future<Either<Failure, ParsedExpenseEntity>> call({
    required String text,
    required List<ExpenseCategoryEntity> categories,
  }) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty) {
      return const Left(ParsingFailure());
    }

    try {
      final parsed = await _textParser.parseExpense(
        text: cleanText,
        categories: categories,
      );

      if (parsed == null) {
        return const Left(ParsingFailure());
      }

      return Right(parsed);
    } catch (e) {
      return Left(ParsingFailure(e.toString()));
    }
  }
}

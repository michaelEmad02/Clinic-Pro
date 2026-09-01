// ────────────────────────────────────────────────────────
// FetchCategoriesUseCase — حالة استخدام جلب تصنيفات المصروفات
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/error/failures.dart';
import 'package:clinic_pro/features/expenses/domain/entities/expense_category_entity.dart';
import 'package:clinic_pro/features/expenses/domain/repositories/expenses_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class FetchCategoriesUseCase {
  final IExpensesRepository _repository;

  FetchCategoriesUseCase(this._repository);

  Future<Either<Failure, List<ExpenseCategoryEntity>>> call() {
    return _repository.getCategories();
  }
}

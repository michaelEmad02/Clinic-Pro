// ────────────────────────────────────────────────────────
// DeleteExpensesUseCase — حالة استخدام حذف مصروف
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/error/failures.dart';
import 'package:clinic_pro/features/expenses/domain/repositories/expenses_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class DeleteExpensesUseCase {
  final IExpensesRepository _repository;

  DeleteExpensesUseCase(this._repository);

  Future<Either<Failure, Unit>> call(String expenseId) {
    return _repository.deleteExpense(expenseId);
  }
}
// ────────────────────────────────────────────────────────
// AddExpensesUseCase — حالة استخدام إضافة مصروف جديد
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/error/failures.dart';
import 'package:clinic_pro/features/expenses/domain/entities/expenses_entity.dart';
import 'package:clinic_pro/features/expenses/domain/repositories/expenses_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class AddExpensesUseCase {
  final IExpensesRepository _repository;

  AddExpensesUseCase(this._repository);

  Future<Either<Failure, ExpensesEntity>> call(ExpensesEntity expense) {
    return _repository.addExpense(expense);
  }
}

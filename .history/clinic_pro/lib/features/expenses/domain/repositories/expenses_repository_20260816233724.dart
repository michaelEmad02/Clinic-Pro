import 'package:clinic_pro/core/error/failures.dart';
import 'package:clinic_pro/features/expenses/domain/entities/expenses_entity.dart';
import 'package:dartz/dartz.dart';

abstract class ExpensesRepository {
  Future<Either<Failure, String>> addExpense(ExpensesEntity expenses);
  Future<Either<Failure, void>> updateExpense(ExpensesEntity expenses);
  Future<Either<Failure, void>> deleteExpense(String id);
  Future<Either<Failure, void>> loadExpenses(String id);
  Future<Either<Failure, void>> loadCategories();

}

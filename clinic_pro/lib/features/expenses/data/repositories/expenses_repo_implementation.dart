
import 'package:clinic_pro/core/error/failures.dart';
import 'package:clinic_pro/features/expenses/domain/entities/expenses_entity.dart';
import 'package:clinic_pro/features/expenses/domain/repositories/expenses_repository.dart';
import 'package:dartz/dartz.dart';

import 'package:injectable/injectable.dart';

@LazySingleton(as: ExpensesRepository)
class ExpensesRepoImplementation extends ExpensesRepository {
  @override
  Future<Either<Failure, String>> addExpense(ExpensesEntity expenses) {
    // TODO: implement addExpense
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> deleteExpense(String id) {
    // TODO: implement deleteExpense
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> loadExpenses(String id) {
    // TODO: implement loadExpenses
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> updateExpense(ExpensesEntity expenses) {
    // TODO: implement updateExpense
    throw UnimplementedError();
  }
  
  @override
  Future<Either<Failure, void>> loadCategories() {
    // TODO: implement loadCategories
    throw UnimplementedError();
  }
 }

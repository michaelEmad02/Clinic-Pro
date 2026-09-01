// ────────────────────────────────────────────────────────
// ExpensesRepoImplementation — تطبيق مستودع المصروفات بـ Data Layer
// يربط بين الـ Domain UseCases ومصدر البيانات IExpensesRemoteDataSource
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/error/failures.dart';
import 'package:clinic_pro/core/error/query_failure.dart';
import 'package:clinic_pro/features/expenses/data/data_sources/expenses_remote_data_source.dart';
import 'package:clinic_pro/features/expenses/data/models/expenses_model.dart';
import 'package:clinic_pro/features/expenses/domain/entities/expense_category_entity.dart';
import 'package:clinic_pro/features/expenses/domain/entities/expenses_entity.dart';
import 'package:clinic_pro/features/expenses/domain/repositories/expenses_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: IExpensesRepository)
class ExpensesRepoImplementation implements IExpensesRepository {
  final IExpensesRemoteDataSource _remoteDataSource;

  ExpensesRepoImplementation(this._remoteDataSource);

  @override
  Future<Either<Failure, List<ExpenseCategoryEntity>>> getCategories() async {
    try {
      final categories = await _remoteDataSource.fetchCategories();
      return Right(categories);
    } catch (e) {
      return Left(QueryFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, List<ExpensesEntity>>> getExpenses({
    required String clinicId,
    String? doctorId,
    bool onlyClinicExpenses = false,
  }) async {
    try {
      final expenses = await _remoteDataSource.fetchExpenses(
        clinicId: clinicId,
        doctorId: doctorId,
        onlyClinicExpenses: onlyClinicExpenses,
      );
      return Right(expenses);
    } catch (e) {
      return Left(QueryFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, ExpensesEntity>> addExpense(ExpensesEntity expense) async {
    try {
      final model = ExpenseModel(
        id: expense.id,
        clinicId: expense.clinicId,
        categoryId: expense.categoryId,
        categoryName: expense.categoryName,
        title: expense.title,
        amount: expense.amount,
        notes: expense.notes,
        doctorId: expense.doctorId,
        createdBy: expense.createdBy,
        createdAt: expense.createdAt,
      );
      final created = await _remoteDataSource.addExpense(model);
      return Right(created);
    } catch (e) {
      return Left(QueryFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, ExpensesEntity>> updateExpense(ExpensesEntity expense) async {
    try {
      final model = ExpenseModel(
        id: expense.id,
        clinicId: expense.clinicId,
        categoryId: expense.categoryId,
        categoryName: expense.categoryName,
        title: expense.title,
        amount: expense.amount,
        notes: expense.notes,
        doctorId: expense.doctorId,
        createdBy: expense.createdBy,
        createdAt: expense.createdAt,
      );
      final updated = await _remoteDataSource.updateExpense(model);
      return Right(updated);
    } catch (e) {
      return Left(QueryFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteExpense(String expenseId) async {
    try {
      await _remoteDataSource.deleteExpense(expenseId);
      return const Right(unit);
    } catch (e) {
      return Left(QueryFailure.fromException(e));
    }
  }
}

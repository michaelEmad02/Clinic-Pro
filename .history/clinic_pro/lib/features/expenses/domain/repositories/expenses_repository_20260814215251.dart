import 'package:clinic_pro/core/error/failures.dart';
import 'package:clinic_pro/features/expenses/domain/entities/expenses_entity.dart';
import 'package:dartz/dartz.dart';

abstract class ExpensesRepository {
  Future<Either<Failure, String>> addExpenses(ExpensesEntity expenses);
  Future<Either<Failure, void>> editClinic(ExpensesEntity expenses);
  Future<Either<Failure, void>> deleteClinic(String id);
 
}

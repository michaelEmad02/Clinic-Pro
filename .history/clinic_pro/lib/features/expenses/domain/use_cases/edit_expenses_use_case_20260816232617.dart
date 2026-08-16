import 'package:clinic_pro/core/error/failures.dart';
import 'package:clinic_pro/features/expenses/domain/repositories/expenses_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../entities/expenses_entity.dart';

@injectable
class EditExpensesUseCase {
  final ExpensesRepository expensesRepository;
  EditExpensesUseCase({required this.expensesRepository});
  Future<Either<Failure, void>> call(ExpensesEntity expenses) {
    return expensesRepository.updateExpense(expenses);
  }
}

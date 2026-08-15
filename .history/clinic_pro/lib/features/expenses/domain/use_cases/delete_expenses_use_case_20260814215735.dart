import 'package:clinic_pro/core/error/failures.dart';
import 'package:clinic_pro/features/clinics/domain/repositories/clinics_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@injectable
class DeleteExpensesUseCase {
  final ExpensesRepository expensesRepository;

  DeleteExpensesUseCase({required this.expensesRepository});

  Future<Either<Failure, void>> call(String id) {
    return expensesRepository.deleteClinic(id);
  }
}



@injectable
class AddExpensesUseCase {
  final ExpensesRepository expensesRepository;

  AddExpensesUseCase({required this.expensesRepository});
  Future<Either<Failure, String>> call(ExpensesEntity expenses) {
    return expensesRepository.addExpense(expenses);
  }
}
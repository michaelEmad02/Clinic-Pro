import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../presentation/manager/expenses_repository.dart';
import '../../presentation/manager/expenses_state.dart';
import '../entities/expenses_entity.dart';

@injectable
class AddExpensesUseCase {
  final ExpensesRepository expensesRepository;

  AddExpensesUseCase({required this.expensesRepository});
  Future<ExpenseItem> call(ExpensesEntity expenses) async {
    return await expensesRepository.addExpense(expenses);
  }
}

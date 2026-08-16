import 'package:clinic_pro/features/expenses/domain/repositories/expenses_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class DeleteExpensesUseCase {
  final ExpensesRepository expensesRepository;

  DeleteExpensesUseCase({required this.expensesRepository});

  Future<void> call(String id) {
    return expensesRepository.deleteExpense(id);
  }
}
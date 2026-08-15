import 'package:clinic_pro/features/clinics/domain/entities/clinic_entity.dart';
import 'package:clinic_pro/features/expenses/presentation/manager/expenses_state.dart';
import 'package:injectable/injectable.dart';

import '../../presentation/manager/expenses_repository.dart';

@injectable
class EditExpensesUseCase {
  final ExpensesRepository expensesRepository;
  EditExpensesUseCase({required this.expensesRepository});
  Future<ExpenseItem> call(EcpenseEntity clinic) {
    return expensesRepository.updateExpense(clinic);
  }
}

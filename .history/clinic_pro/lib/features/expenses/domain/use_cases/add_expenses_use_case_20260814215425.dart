import 'package:clinic_pro/core/error/failures.dart';
import 'package:clinic_pro/features/expenses/domain/entities/expenses_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../presentation/manager/expenses_repository.dart';

@injectable
class AddExpensesUseCase {
  final ExpensesRepository expensesRepository;

  AddExpensesUseCase({required this.expensesRepository});
  Future<Either<Failure, String>> call(ExpensesEntity expenses) {
    return expensesRepository.addExpense(expenses, title: '', amount: null, categoryId: '', categoryLabel: '');
  }
}

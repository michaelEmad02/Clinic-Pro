import 'package:clinic_pro/core/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../presentation/manager/expenses_repository.dart';

@injectable
class DeleteExpensesUseCase {
  final ExpensesRepository expensesRepository;

  DeleteExpensesUseCase({required this.expensesRepository});

  Future<void> call(String id) {
    return expensesRepository.deleteExpense(id);
  }
}
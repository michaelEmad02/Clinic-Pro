import 'package:clinic_pro/core/error/failures.dart';
import 'package:clinic_pro/features/clinics/domain/entities/clinic_entity.dart';
import 'package:clinic_pro/features/expenses/presentation/manager/expenses_state.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../presentation/manager/expenses_repository.dart';

@injectable
class FetchEcpensesUseCase {
  final ExpensesRepository expensesRepository;

  FetchEcpensesUseCase({required this.expensesRepository});

  Future<List<ExpenseItem>> call(String id) {
    return expensesRepository.loadExpenses(id);
  }
}

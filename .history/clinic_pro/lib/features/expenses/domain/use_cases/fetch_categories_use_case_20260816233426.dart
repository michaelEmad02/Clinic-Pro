import 'package:clinic_pro/core/error/failures.dart';
import 'package:clinic_pro/features/expenses/domain/repositories/expenses_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@injectable
class FetchCateUseCase {
  final ExpensesRepository expensesRepository;

  FetchExpensesUseCase({required this.expensesRepository});

  Future<Either<Failure, void>> call(String clinicId) {
    return expensesRepository.loadExpenses(clinicId);
  }
}

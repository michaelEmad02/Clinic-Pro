import 'package:clinic_pro/core/error/failures.dart';
import 'package:clinic_pro/features/clinics/domain/repositories/clinics_repository.dart';
import 'package:clinic_pro/features/expenses/domain/entities/expenses_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@injectable
class AddExpensesUseCase {
  final ExpensesRepository expensesRepository;

  AddExpensesUseCase({required this.expensesRepository});
  Future<Either<Failure, String>> call(ExpensesEntity clinic) {
    return expensesRepository.addexpenses(clinic);
  }
}

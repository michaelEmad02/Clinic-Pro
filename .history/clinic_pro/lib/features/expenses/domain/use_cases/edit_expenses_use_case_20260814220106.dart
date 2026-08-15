import 'package:clinic_pro/core/error/failures.dart';
import 'package:clinic_pro/features/clinics/domain/entities/clinic_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../presentation/manager/expenses_repository.dart';

@injectable
class EditExpensesUseCase {
  final ExpensesRepository expensesRepository;

  EditExpensesUseCase({required this.expensesRepository});
  Future<Either<Failure, void>> call(ClinicEntity clinic) {
    return expensesRepository.updateExpense(clinic);
  }
}

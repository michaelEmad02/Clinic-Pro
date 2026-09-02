// ────────────────────────────────────────────────────────
// FetchExpensesUseCase — حالة استخدام جلب المصروفات
// تدعم جلب مصاريف العيادة العامة أو مصاريف طبيب محدد
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/error/failures.dart';
import 'package:clinic_pro/features/expenses/domain/entities/expenses_entity.dart';
import 'package:clinic_pro/features/expenses/domain/repositories/expenses_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class FetchExpensesUseCase {
  final IExpensesRepository _repository;

  FetchExpensesUseCase(this._repository);

  Future<Either<Failure, List<ExpensesEntity>>> call({
    required String clinicId,
    String? ownerId,
    String? doctorId,
    bool onlyClinicExpenses = false,
  }) {
    return _repository.getExpenses(
      clinicId: clinicId,
      ownerId: ownerId,
      doctorId: doctorId,
      onlyClinicExpenses: onlyClinicExpenses,
    );
  }
}

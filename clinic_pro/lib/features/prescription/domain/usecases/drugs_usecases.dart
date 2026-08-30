// ────────────────────────────────────────────────────────
// حالات استخدام إدارة الأدوية (Drugs UseCases)
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/strings/failure_strings.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/drug_entity.dart';
import '../repositories/i_prescription_repository.dart';

@injectable
class GetDrugsUseCase {
  final IPrescriptionRepository _repository;
  GetDrugsUseCase(this._repository);

  Future<Either<Failure, List<DrugEntity>>> call() {
    return _repository.getDrugs();
  }
}

@injectable
class AddDrugUseCase {
  final IPrescriptionRepository _repository;
  AddDrugUseCase(this._repository);

  Future<Either<Failure, DrugEntity>> call(DrugEntity drug) {
    if (drug.tradeName == null || drug.tradeName!.trim().isEmpty) {
      return Future.value(const Left(DrugTradeNameRequiredFailure()));
    }
    return _repository.addDrug(drug);
  }
}

@injectable
class UpdateDrugUseCase {
  final IPrescriptionRepository _repository;
  UpdateDrugUseCase(this._repository);

  Future<Either<Failure, void>> call(DrugEntity drug) {
    if (drug.tradeName == null || drug.tradeName!.trim().isEmpty) {
      return Future.value(const Left(DrugTradeNameRequiredFailure()));
    }
    return _repository.updateDrug(drug);
  }
}

@injectable
class DeleteDrugUseCase {
  final IPrescriptionRepository _repository;
  DeleteDrugUseCase(this._repository);

  Future<Either<Failure, void>> call(String id) {
    return _repository.deleteDrug(id);
  }
}

class DrugTradeNameRequiredFailure extends Failure {
  const DrugTradeNameRequiredFailure([super.customMessage]);

  @override
  String get defaultMessage => FailureStrings.drugTradeNameRequired;
}

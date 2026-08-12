import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/i_prescription_repository.dart';

@injectable
class IncrementTemplateUsageUseCase {
  final IPrescriptionRepository _repository;
  IncrementTemplateUsageUseCase(this._repository);

  Future<Either<Failure, void>> call(String templateId) {
    return _repository.incrementTemplateUsage(templateId);
  }
}

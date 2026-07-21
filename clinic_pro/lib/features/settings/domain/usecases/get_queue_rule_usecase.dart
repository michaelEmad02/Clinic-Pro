// ────────────────────────────────────────────────────────
// UseCase: جلب قاعدة الانتظار للطبيب
// ────────────────────────────────────────────────────────

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/queue_rule_entity.dart';
import '../repositories/i_settings_repository.dart';

@injectable
class GetQueueRuleUseCase {
  final ISettingsRepository _repository;
  GetQueueRuleUseCase(this._repository);

  Future<Either<Failure, QueueRuleEntity?>> call({
    required String doctorId,
    required String clinicId,
  }) {
    return _repository.getQueueRule(
      doctorId: doctorId,
      clinicId: clinicId,
    );
  }
}

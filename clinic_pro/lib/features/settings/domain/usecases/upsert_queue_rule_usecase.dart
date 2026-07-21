// ────────────────────────────────────────────────────────
// UseCase: حفظ أو تعديل قاعدة الانتظار للطبيب
// ────────────────────────────────────────────────────────

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/i_settings_repository.dart';

@injectable
class UpsertQueueRuleUseCase {
  final ISettingsRepository _repository;
  UpsertQueueRuleUseCase(this._repository);

  Future<Either<Failure, Unit>> call({
    required String doctorId,
    required String clinicId,
    required String queueSystem,
    required List<String> slots,
    required int cycleLength,
    int? avgVisitMinutes,
  }) {
    return _repository.upsertQueueRule(
      doctorId: doctorId,
      clinicId: clinicId,
      queueSystem: queueSystem,
      slots: slots,
      cycleLength: cycleLength,
      avgVisitMinutes: avgVisitMinutes,
    );
  }
}

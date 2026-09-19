// ────────────────────────────────────────────────────────
// SaveAiSettingsUseCase — حالة استخدام حفظ إعدادات الذكاء الاصطناعي للمالك
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/error/failures.dart';
import 'package:clinic_pro/features/settings/domain/entities/ai_settings_entity.dart';
import 'package:clinic_pro/features/settings/domain/repositories/i_owner_settings_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class SaveAiSettingsUseCase {
  final IOwnerSettingsRepository _repository;

  SaveAiSettingsUseCase(this._repository);

  Future<Either<Failure, Unit>> call({
    required String ownerId,
    required AiSettingsEntity settings,
  }) {
    return _repository.saveAiSettings(ownerId, settings);
  }
}

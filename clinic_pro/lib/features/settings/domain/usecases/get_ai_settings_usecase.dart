// ────────────────────────────────────────────────────────
// GetAiSettingsUseCase — حالة استخدام جلب إعدادات الذكاء الاصطناعي للمالك
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/error/failures.dart';
import 'package:clinic_pro/features/settings/domain/entities/ai_settings_entity.dart';
import 'package:clinic_pro/features/settings/domain/repositories/i_owner_settings_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class GetAiSettingsUseCase {
  final IOwnerSettingsRepository _repository;

  GetAiSettingsUseCase(this._repository);

  Future<Either<Failure, AiSettingsEntity>> call(
      String ownerId, bool refreshCache) {
    return _repository.getAiSettings(ownerId, refreshCache);
  }
}

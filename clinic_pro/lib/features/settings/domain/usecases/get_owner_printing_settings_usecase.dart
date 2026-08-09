// ────────────────────────────────────────────────────────
// GetOwnerPrintingSettingsUseCase — حالة استخدام جلب إعدادات الطباعة للمالك
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/error/failures.dart';
import 'package:clinic_pro/features/settings/domain/entities/printing_settings_entity.dart';
import 'package:clinic_pro/features/settings/domain/repositories/i_owner_settings_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class GetOwnerPrintingSettingsUseCase {
  final IOwnerSettingsRepository _repository;

  GetOwnerPrintingSettingsUseCase(this._repository);

  Future<Either<Failure, PrintingSettingsEntity>> call(
      String ownerId, bool refreshCache) {
    return _repository.getPrintingSettings(ownerId, refreshCache);
  }
}

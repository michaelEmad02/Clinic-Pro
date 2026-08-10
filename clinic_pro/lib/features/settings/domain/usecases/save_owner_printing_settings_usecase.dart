// ────────────────────────────────────────────────────────
// SaveOwnerPrintingSettingsUseCase — حالة استخدام حفظ وتحديث إعدادات الطباعة للمالك
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/error/failures.dart';
import 'package:clinic_pro/features/settings/domain/entities/printing_settings_entity.dart';
import 'package:clinic_pro/features/settings/domain/repositories/i_owner_settings_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class SaveOwnerPrintingSettingsUseCase {
  final IOwnerSettingsRepository _repository;

  SaveOwnerPrintingSettingsUseCase(this._repository);

  Future<Either<Failure, Unit>> call({
    required String ownerId,
    required PrintingSettingsEntity settings,
  }) {
    return _repository.savePrintingSettings(ownerId, settings);
  }
}

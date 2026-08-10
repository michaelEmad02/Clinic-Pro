// ────────────────────────────────────────────────────────
// IOwnerSettingsRepository — مستودع إدارة إعدادات المالك
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/error/failures.dart';
import 'package:clinic_pro/features/settings/domain/entities/printing_settings_entity.dart';
import 'package:dartz/dartz.dart';

abstract class IOwnerSettingsRepository {
  Future<Either<Failure, PrintingSettingsEntity>> getPrintingSettings(
      String ownerId , bool refreshCache);
  Future<Either<Failure, Unit>> savePrintingSettings(
      String ownerId, PrintingSettingsEntity settings);
}

// ────────────────────────────────────────────────────────
// OwnerSettingsRepositoryImpl — تنفيذ مستودع إعدادات المالك
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/error/failures.dart';
import 'package:clinic_pro/core/error/query_failure.dart';
import 'package:clinic_pro/features/settings/data/data_sources/owner_settings_remote_data_source.dart';
import 'package:clinic_pro/features/settings/data/models/printing_settings_model.dart';
import 'package:clinic_pro/features/settings/domain/entities/printing_settings_entity.dart';
import 'package:clinic_pro/features/settings/domain/repositories/i_owner_settings_repository.dart';
import 'package:dartz/dartz.dart';

import 'package:injectable/injectable.dart';

@LazySingleton(as: IOwnerSettingsRepository)
class OwnerSettingsRepositoryImpl implements IOwnerSettingsRepository {
  final IOwnerSettingsRemoteDataSource _remoteDataSource;

  // ─── In-Memory Cache ───
  PrintingSettingsEntity? _cachedSettings;
  String? _cachedOwnerId;

  OwnerSettingsRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, PrintingSettingsEntity>> getPrintingSettings(
      String ownerId, bool refreshCache) async {
    // 1. إرجاع النتيجة من الذاكرة (Cache) مباشرة إذا كانت متوفرة لنفس المالك
    if (_cachedSettings != null && _cachedOwnerId == ownerId && !refreshCache) {
      return Right(_cachedSettings!);
    }

    // 2. إذا لم تكن مخزنة، جلبها من السحابة وتخزينها بالذاكرة
    try {
      final settings = await _remoteDataSource.getPrintingSettings(ownerId);
      _cachedSettings = settings;
      _cachedOwnerId = ownerId;
      return Right(settings);
    } catch (e) {
      return Left(QueryFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> savePrintingSettings(
      String ownerId, PrintingSettingsEntity settings) async {
    try {
      final model = PrintingSettingsModel.fromEntity(settings);
      await _remoteDataSource.savePrintingSettings(ownerId, model);

      // تحديث الـ Cache المباشر بالقيم الجديدة المعتمدة
      _cachedSettings = settings;
      _cachedOwnerId = ownerId;

      return const Right(unit);
    } catch (e) {
      return Left(QueryFailure.fromException(e));
    }
  }
}

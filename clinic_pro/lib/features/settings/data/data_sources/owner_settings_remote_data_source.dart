// ────────────────────────────────────────────────────────
// OwnerSettingsRemoteDataSource — مصدر البيانات لإعدادات المالك بـ Supabase
// (يقع بداخل data_sources المعتمد للمشروع)
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/constants/supabase_constants.dart';
import 'package:clinic_pro/core/services/i_cloud_service.dart';
import 'package:clinic_pro/features/settings/data/models/ai_settings_model.dart';
import 'package:clinic_pro/features/settings/data/models/printing_settings_model.dart';
import 'package:injectable/injectable.dart';

abstract class IOwnerSettingsRemoteDataSource {
  Future<PrintingSettingsModel> getPrintingSettings(String ownerId);
  Future<void> savePrintingSettings(
      String ownerId, PrintingSettingsModel settings);
  Future<AiSettingsModel> getAiSettings(String ownerId);
  Future<void> saveAiSettings(
      String ownerId, AiSettingsModel settings);
}

@LazySingleton(as: IOwnerSettingsRemoteDataSource)
class OwnerSettingsRemoteDataSourceImpl
    implements IOwnerSettingsRemoteDataSource {
  final ICloudService _cloudService;

  OwnerSettingsRemoteDataSourceImpl(this._cloudService);

  @override
  Future<PrintingSettingsModel> getPrintingSettings(String ownerId) async {
    final response = await _cloudService.select(
      table: SupabaseTables.ownerSettings,
      eq: {'owner_id': ownerId},
    );

    if (response.isNotEmpty && response.first['printing_settings'] != null) {
      final jsonMap = Map<String, dynamic>.from(
          response.first['printing_settings'] as Map);
      return PrintingSettingsModel.fromJson(jsonMap);
    }

    return const PrintingSettingsModel();
  }

  @override
  Future<void> savePrintingSettings(
      String ownerId, PrintingSettingsModel settings) async {
    final existing = await _cloudService.select(
      table: SupabaseTables.ownerSettings,
      eq: {'owner_id': ownerId},
    );

    final payload = {
      'owner_id': ownerId,
      'printing_settings': settings.toJson(),
    };

    if (existing.isNotEmpty) {
      await _cloudService.update(
        table: SupabaseTables.ownerSettings,
        data: payload,
        matchColumn: 'owner_id',
        matchValue: ownerId,
      );
    } else {
      await _cloudService.insert(
        table: SupabaseTables.ownerSettings,
        data: payload,
      );
    }
  }

  @override
  Future<AiSettingsModel> getAiSettings(String ownerId) async {
    final response = await _cloudService.select(
      table: SupabaseTables.ownerSettings,
      eq: {'owner_id': ownerId},
    );

    if (response.isNotEmpty && response.first['ai_settings'] != null) {
      final jsonMap =
          Map<String, dynamic>.from(response.first['ai_settings'] as Map);
      return AiSettingsModel.fromJson(jsonMap);
    }

    return const AiSettingsModel();
  }

  @override
  Future<void> saveAiSettings(
      String ownerId, AiSettingsModel settings) async {
    final existing = await _cloudService.select(
      table: SupabaseTables.ownerSettings,
      eq: {'owner_id': ownerId},
    );

    final payload = {
      'owner_id': ownerId,
      'ai_settings': settings.toJson(),
    };

    if (existing.isNotEmpty) {
      final existingAi = existing.first['ai_settings'];
      if (existingAi is Map && existingAi['api_key_encrypted'] != null) {
        (payload['ai_settings'] as Map<String, dynamic>)['api_key_encrypted'] =
            existingAi['api_key_encrypted'];
      }
      await _cloudService.update(
        table: SupabaseTables.ownerSettings,
        data: payload,
        matchColumn: 'owner_id',
        matchValue: ownerId,
      );
    } else {
      await _cloudService.insert(
        table: SupabaseTables.ownerSettings,
        data: payload,
      );
    }
  }
}

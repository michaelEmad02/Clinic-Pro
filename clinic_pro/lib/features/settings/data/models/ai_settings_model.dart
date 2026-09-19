// ────────────────────────────────────────────────────────
// AiSettingsModel — نموذج بيانات إعدادات الذكاء الاصطناعي مع تحويل JSON
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/features/settings/domain/entities/ai_settings_entity.dart';

class AiSettingsModel extends AiSettingsEntity {
  const AiSettingsModel({
    super.extractionMode = 'regex',
    super.provider,
    super.hasApiKey = false,
    super.model,
    super.customBaseUrl,
  });

  factory AiSettingsModel.fromJson(Map<String, dynamic> json) {
    final encryptedKey = json['api_key_encrypted'];
    return AiSettingsModel(
      extractionMode: json['extraction_mode'] as String? ?? 'regex',
      provider: json['provider'] as String?,
      hasApiKey: encryptedKey != null && encryptedKey.toString().isNotEmpty,
      model: json['model'] as String?,
      customBaseUrl: json['custom_base_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'extraction_mode': extractionMode,
      'provider': provider,
      'model': model,
      'custom_base_url': customBaseUrl,
      // ملاحظة: لا نحفظ api_key_encrypted هنا لأن المفتاح يُشفر ويُحفظ عبر Edge Function
    };
  }

  factory AiSettingsModel.fromEntity(AiSettingsEntity entity) {
    return AiSettingsModel(
      extractionMode: entity.extractionMode,
      provider: entity.provider,
      hasApiKey: entity.hasApiKey,
      model: entity.model,
      customBaseUrl: entity.customBaseUrl,
    );
  }
}

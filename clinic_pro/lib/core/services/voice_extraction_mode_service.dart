// ────────────────────────────────────────────────────────
// VoiceExtractionModeService — وسيط توجيه الاستخراج (RegEx / AI)
// يفحص إعدادات المالك المعتمدة في Supabase ويوجه الطلب إما للـ AI أو للـ RegEx
// مع خاصية الرجوع التلقائي (Fallback) للـ RegEx في حال حدوث خطأ بالشبكة أو الـ AI
// ────────────────────────────────────────────────────────

import 'dart:developer' as developer;
import 'package:clinic_pro/core/services/ai/ai_voice_extraction_service_impl.dart';
import 'package:clinic_pro/core/services/i_voice_extraction_service.dart';
import 'package:clinic_pro/core/services/regex_voice_extraction_service_impl.dart';
import 'package:clinic_pro/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:clinic_pro/features/settings/domain/repositories/i_owner_settings_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: IVoiceExtractionService)
class VoiceExtractionModeService implements IVoiceExtractionService {
  final RegexVoiceExtractionServiceImpl _regexService;
  final AiVoiceExtractionServiceImpl _aiService;
  final IOwnerSettingsRepository _ownerSettingsRepository;
  final IAuthRepository _authRepository;

  VoiceExtractionModeService(
    this._regexService,
    this._aiService,
    this._ownerSettingsRepository,
    this._authRepository,
  );

  @override
  Future<Map<String, dynamic>> extractData({
    required String text,
    required ExtractionTarget target,
    Map<String, dynamic>? extraContext,
  }) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty) return {};

    try {
      // 1. تحديد معرف المالك
      String ownerId = extraContext?['ownerId'] as String? ?? '';
      if (ownerId.isEmpty) {
        final userResult = await _authRepository.getCurrentUser();
        final user = userResult.fold((_) => null, (u) => u);
        if (user != null) {
          ownerId = (user.ownerId != null && user.ownerId!.isNotEmpty)
              ? user.ownerId!
              : user.id;
        }
      }

      // 2. فحص إعدادات الـ AI إن وجد معرف المالك
      if (ownerId.isNotEmpty) {
        final settingsResult =
            await _ownerSettingsRepository.getAiSettings(ownerId, false);

        final aiSettings = settingsResult.fold((_) => null, (s) => s);

        if (aiSettings != null && aiSettings.isConfigured) {
          developer.log(
            '🤖 Voice Extraction using AI (${aiSettings.provider} - ${aiSettings.model})',
            name: 'VoiceExtractionModeService',
          );
          try {
            final aiResult = await _aiService.extractData(
              text: cleanText,
              target: target,
              extraContext: {
                ...?extraContext,
                'ownerId': ownerId,
              },
            );

            if (aiResult.isNotEmpty) {
              return aiResult;
            }
          } catch (aiError) {
            developer.log(
              '⚠️ AI extraction failed, falling back to RegEx: $aiError',
              name: 'VoiceExtractionModeService',
              error: aiError,
            );
          }
        }
      }
    } catch (e) {
      developer.log(
        '⚠️ Error checking AI settings, falling back to RegEx: $e',
        name: 'VoiceExtractionModeService',
        error: e,
      );
    }

    // 3. الوضع الافتراضي أو البديل: RegEx محلي
    developer.log(
      '⚡ Voice Extraction using RegEx',
      name: 'VoiceExtractionModeService',
    );
    return _regexService.extractData(
      text: cleanText,
      target: target,
      extraContext: extraContext,
    );
  }
}

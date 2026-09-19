// ────────────────────────────────────────────────────────
// AiSettingsEntity — كيان إعدادات الذكاء الاصطناعي للمالك
// ────────────────────────────────────────────────────────

import 'package:equatable/equatable.dart';

class AiSettingsEntity extends Equatable {
  /// وضع التحليل: 'regex' (محلي بدون AI) أو 'ai' (ذكاء اصطناعي)
  final String extractionMode;

  /// المزود المختار: 'openai', 'claude', 'gemini', 'deepseek', 'groq', 'qwen', 'gimi', 'custom'
  final String? provider;

  /// هل تم حفظ مفتاح API في السيرفر (بدون كشف قيمة المفتاح للكلاينت)
  final bool hasApiKey;

  /// اسم الموديل المختار: مثل 'gpt-4o-mini', 'gemini-2.0-flash', إلخ
  final String? model;

  /// رابط الـ Base URL المخصص (فقط إذا كان المزود custom)
  final String? customBaseUrl;

  const AiSettingsEntity({
    this.extractionMode = 'regex',
    this.provider,
    this.hasApiKey = false,
    this.model,
    this.customBaseUrl,
  });

  bool get isAiMode => extractionMode == 'ai';
  bool get isConfigured => isAiMode && hasApiKey && (provider != null);

  AiSettingsEntity copyWith({
    String? extractionMode,
    String? provider,
    bool? hasApiKey,
    String? model,
    String? customBaseUrl,
  }) {
    return AiSettingsEntity(
      extractionMode: extractionMode ?? this.extractionMode,
      provider: provider ?? this.provider,
      hasApiKey: hasApiKey ?? this.hasApiKey,
      model: model ?? this.model,
      customBaseUrl: customBaseUrl ?? this.customBaseUrl,
    );
  }

  @override
  List<Object?> get props => [
        extractionMode,
        provider,
        hasApiKey,
        model,
        customBaseUrl,
      ];
}

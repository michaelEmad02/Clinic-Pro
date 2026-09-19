// ────────────────────────────────────────────────────────
// AiEdgeFunctionService — وسيط الاتصال بـ Supabase Edge Function (ai-proxy)
// ينفذ عمليات حفظ الإعدادات، اختبار الاتصال، جلب الموديلات، واستخراج البيانات
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/services/ai/ai_error_handler.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@lazySingleton
class AiEdgeFunctionService {
  final SupabaseClient _supabase;

  AiEdgeFunctionService(this._supabase);

  static const String _functionName = 'ai-proxy';

  /// تنفيذ استدعاء آمن للـ Edge Function مع معالجة استثناءات Supabase وتنقية الأخطاء
  Future<dynamic> _invokeSafe(String action, Map<String, dynamic> payload) async {
    try {
      final response = await _supabase.functions.invoke(
        _functionName,
        body: {'action': action, ...payload},
      );

      if (response.status >= 400) {
        final error = response.data is Map ? response.data['error'] : null;
        throw Exception(AiErrorHandler.sanitize(error ?? 'فشل تنفيذ العملية ($action)'));
      }
      return response.data;
    } on FunctionException catch (e) {
      if (e.status == 404) {
        throw Exception(AiErrorHandler.sanitize('ai-proxy 404'));
      }
      final errorDetail = e.details is Map ? e.details['error'] : (e.details ?? e.reasonPhrase);
      throw Exception(AiErrorHandler.sanitize(errorDetail));
    } catch (e) {
      throw Exception(AiErrorHandler.sanitize(e));
    }
  }

  /// حفظ إعدادات الذكاء الاصطناعي وتشفير الـ API Key في السيرفر
  Future<void> saveSettings({
    required String ownerId,
    required String provider,
    String? apiKey,
    required String model,
    required String extractionMode,
    String? customBaseUrl,
  }) async {
    await _invokeSafe('save_settings', {
      'ownerId': ownerId,
      'provider': provider,
      if (apiKey != null && apiKey.trim().isNotEmpty) 'apiKey': apiKey.trim(),
      'model': model,
      'extractionMode': extractionMode,
      'customBaseUrl': customBaseUrl,
    });
  }

  /// اختبار صلاحية مفتاح API والاتصال بمزود الذكاء الاصطناعي
  Future<bool> testConnection({
    required String provider,
    String? apiKey,
    required String model,
    String? customBaseUrl,
    String? ownerId,
  }) async {
    final data = await _invokeSafe('test_connection', {
      'provider': provider,
      if (apiKey != null && apiKey.trim().isNotEmpty) 'apiKey': apiKey.trim(),
      'model': model,
      'customBaseUrl': customBaseUrl,
      if (ownerId != null && ownerId.isNotEmpty) 'ownerId': ownerId,
    });

    if (data is Map && data['success'] == true) {
      return true;
    }
    return false;
  }

  /// جلب قائمة الموديلات المتاحة من مزود الذكاء الاصطناعي
  Future<List<String>> fetchModels({
    required String provider,
    String? apiKey,
    String? customBaseUrl,
    String? ownerId,
  }) async {
    final data = await _invokeSafe('fetch_models', {
      'provider': provider,
      if (apiKey != null && apiKey.trim().isNotEmpty) 'apiKey': apiKey.trim(),
      'customBaseUrl': customBaseUrl,
      if (ownerId != null && ownerId.isNotEmpty) 'ownerId': ownerId,
    });

    if (data is Map && data['models'] is List) {
      return (data['models'] as List).map((e) => e.toString()).toList();
    }
    return [];
  }

  /// استخراج بيانات الكيان من النص المنطوق عبر AI
  Future<Map<String, dynamic>> extract({
    required String ownerId,
    required String systemPrompt,
    required String userText,
  }) async {
    final data = await _invokeSafe('extract', {
      'ownerId': ownerId,
      'systemPrompt': systemPrompt,
      'userText': userText,
    });

    if (data is Map && data['data'] is Map) {
      return Map<String, dynamic>.from(data['data'] as Map);
    }
    return {};
  }
}

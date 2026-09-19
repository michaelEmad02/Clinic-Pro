// ────────────────────────────────────────────────────────
// اختبارات وحدة لـ AiErrorHandler للتأكد من تنقية كافة الأخطاء التقنية
// وتحويلها إلى رسائل عربية واضحة للمستخدم
// ────────────────────────────────────────────────────────

import 'dart:io';
import 'package:clinic_pro/core/error/failures.dart';
import 'package:clinic_pro/core/services/ai/ai_error_handler.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AiErrorHandler Sanitization Tests', () {
    test('sanitizes 401 / invalid API key from OpenAI and Claude', () {
      const rawOpenAi =
          'openai API error (401): {"error": {"message": "Incorrect API key provided: sk-xxx", "type": "invalid_request_error", "code": "invalid_api_key"}}';
      final msgOpenAi = AiErrorHandler.sanitize(rawOpenAi);
      expect(msgOpenAi, contains('مفتاح الـ API غير صالح'));
      expect(msgOpenAi, isNot(contains('sk-xxx')));
      expect(msgOpenAi, isNot(contains('invalid_request_error')));

      const rawClaude =
          'Claude API error (401): {"type": "error", "error": {"type": "authentication_error", "message": "invalid x-api-key"}}';
      final msgClaude = AiErrorHandler.sanitize(rawClaude);
      expect(msgClaude, contains('مفتاح الـ API غير صالح'));
      expect(msgClaude, isNot(contains('authentication_error')));
    });

    test('sanitizes quota / billing errors', () {
      const rawQuota =
          'openai API error (429): {"error": {"message": "You exceeded your current quota, please check your plan and billing details.", "type": "insufficient_quota", "code": "insufficient_quota"}}';
      final msg = AiErrorHandler.sanitize(rawQuota);
      expect(msg, contains('رصيد الحساب غير كافٍ'));
      expect(msg, isNot(contains('insufficient_quota')));
    });

    test('sanitizes model not found errors', () {
      const rawModel =
          'openai API error (404): {"error": {"message": "The model `gpt-5-turbo` does not exist or you do not have access to it.", "code": "model_not_found"}}';
      final msg = AiErrorHandler.sanitize(rawModel);
      expect(msg, contains('الموديل المحدد غير متوفر'));
      expect(msg, isNot(contains('gpt-5-turbo')));
    });

    test('sanitizes rate limit 429 errors', () {
      const rawRate =
          'groq API error (429): {"error": {"message": "Rate limit reached for requests per minute (RPM)", "type": "rate_limit_exceeded"}}';
      final msg = AiErrorHandler.sanitize(rawRate);
      expect(msg, contains('تم تجاوز الحد الأقصى'));
      expect(msg, isNot(contains('requests per minute')));
    });

    test('sanitizes network / socket errors', () {
      const socketException = SocketException('Failed host lookup: api.openai.com');
      final msg = AiErrorHandler.sanitize(socketException);
      expect(msg, contains('تعذر الاتصال'));
      expect(msg, contains('الإنترنت'));
    });

    test('sanitizes server / 500 / 503 overloaded errors', () {
      const raw503 = 'deepseek API error (503): {"error": {"message": "Server is overloaded, please try again later."}}';
      final msg = AiErrorHandler.sanitize(raw503);
      expect(msg, contains('مزود الذكاء الاصطناعي يواجه ضغطاً'));
    });

    test('sanitizes edge function 404', () {
      const raw404 = 'ai-proxy 404 FunctionException(status: 404, details: null, reasonPhrase: Not Found)';
      final msg = AiErrorHandler.sanitize(raw404);
      expect(msg, anyOf(contains('ai-proxy'), contains('غير متوفر'), contains('تعذر')));
    });

    test('sanitizes missing API key', () {
      const rawMissing = 'يرجى إدخال مفتاح الـ API أولاً';
      final msg = AiErrorHandler.sanitize(rawMissing);
      expect(msg, contains('يرجى إدخال مفتاح الـ API أولاً'));
    });

    test('toFailure returns AiFailure with sanitized message', () {
      const rawError = 'openai API error (401): {"error": {"message": "Incorrect API key provided: sk-test"}}';
      final failure = AiErrorHandler.toFailure(rawError);
      expect(failure, isA<Failure>());
      expect(failure, isA<AiFailure>());
      expect(failure.message, contains('مفتاح الـ API غير صالح'));
    });

    test('is idempotent and prevents double-sanitization degradation to default', () {
      const rawError = 'openai (401): Incorrect API key provided';
      final firstPass = AiErrorHandler.sanitize(rawError);
      expect(firstPass, contains('مفتاح الـ API غير صالح'));

      // محاكاة رمي استثناء بالنص المعالج ثم معالجته مرة ثانية في الـ Cubit
      final secondPass = AiErrorHandler.sanitize(Exception(firstPass));
      expect(secondPass, contains('مفتاح الـ API غير صالح'));
      expect(secondPass, isNot(contains('تعذر إكمال العملية مع مزود الذكاء الاصطناعي')));

      // تكرار ثالث
      final thirdPass = AiErrorHandler.sanitize(secondPass);
      expect(thirdPass, contains('مفتاح الـ API غير صالح'));
    });

    test('sanitizes 403 / forbidden / permission denied', () {
      const raw403 = 'Gemini (403): User not authorized / Forbidden';
      final msg = AiErrorHandler.sanitize(raw403);
      expect(msg, contains('مفتاح الـ API غير صالح'));
    });

    test('sanitizes Gemini RESOURCE_EXHAUSTED', () {
      const rawExhausted = 'Gemini error (429): RESOURCE_EXHAUSTED quota exceeded';
      final msg = AiErrorHandler.sanitize(rawExhausted);
      expect(msg, contains('رصيد الحساب غير كافٍ'));
    });

    test('sanitizes region / location not supported', () {
      const rawRegion = 'User location is not supported for the API use';
      final msg = AiErrorHandler.sanitize(rawRegion);
      expect(msg, contains('منطقتك الجغرافية'));
    });
  });
}

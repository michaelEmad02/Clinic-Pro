// ────────────────────────────────────────────────────────
// هذا الملف مسؤول عن تنقية ومعالجة أخطاء مزودي الذكاء الاصطناعي
// يقوم بتحويل رموز الخطأ ونصوص JSON التقنية إلى رسائل عربية واضحة وموجهة للمستخدم
// يدعم Idempotency لمنع تآكل الرسائل عند المعالجة المزدوجة
// ────────────────────────────────────────────────────────

import 'dart:async';
import 'dart:io';

import 'package:clinic_pro/core/error/failures.dart';

class AiErrorHandler {
  /// تحويل أي استثناء أو نص خطأ قادم من مزودات AI أو السيرفر إلى رسالة عربية سهلة الفهم
  static String sanitize(dynamic error) {
    if (error == null) {
      return 'حدث خطأ غير متوقع، يرجى المحاولة مرة أخرى.';
    }

    String cleanText = error.toString().trim();
    if (cleanText.startsWith('Exception:')) {
      cleanText = cleanText.substring('Exception:'.length).trim();
    }

    // 1. منع المعالجة المزدوجة (Idempotency): إذا كانت الرسالة معالجة بالفعل، نعيدها فوراً
    const knownSanitizedMessages = [
      'مفتاح الـ API غير صالح أو غير مصرح به، يرجى التأكد من نسخه بشكل صحيح من حسابك.',
      'رصيد الحساب غير كافٍ أو انتهت باقة الاستخدام لدى المزود، يرجى شحن الرصيد في حسابك.',
      'الموديل المحدد غير متوفر في هذا الحساب أو تم إيقافه، يرجى اختيار موديل آخر مدعوم.',
      'خدمة الموديل غير مدعومة في منطقتك الجغرافية حالياً لدى المزود.',
      'تم تجاوز الحد الأقصى للطلبات المسموحة حالياً، يرجى الانتظار دقيقة والمحاولة مجدداً.',
      'مزود الذكاء الاصطناعي يواجه ضغطاً أو توقفاً مؤقتاً في الخدمة، يرجى المحاولة بعد قليل.',
      'تعذر الاتصال بالخادم، يرجى التحقق من اتصال الإنترنت والمحاولة ثانية.',
      'استغرق مزود الذكاء الاصطناعي وقتاً أطول من المتوقع للرد، يرجى المحاولة مجدداً.',
      'خدمة الذكاء الاصطناعي (ai-proxy) غير منشورة في Supabase، يرجى تفعيل الدالة من لوحة التحكم.',
      'يرجى إدخال مفتاح الـ API أولاً وحفظ الإعدادات للمتابعة.',
      'استجاب مزود الذكاء الاصطناعي بتنسيق غير متوقع، يرجى إعادة المحاولة.',
      'تعذر إكمال العملية مع مزود الذكاء الاصطناعي، يرجى التحقق من صحة الإعدادات والمحاولة لاحقاً.',
    ];

    for (final known in knownSanitizedMessages) {
      if (cleanText.contains(known)) {
        return known;
      }
    }

    // إذا كان النص رسالة عربية مفهومة من السيرفر ولا تحتوي على كود تقني أو JSON
    final hasArabic = RegExp(r'[\u0600-\u06FF]').hasMatch(cleanText);
    final hasTechnicalTokens = cleanText.contains('{') ||
        cleanText.contains('}') ||
        cleanText.contains('api error') ||
        cleanText.contains('status:') ||
        cleanText.contains('functionexception');

    if (hasArabic && !hasTechnicalTokens && cleanText.length > 5) {
      return cleanText;
    }

    final raw = cleanText.toLowerCase();

    // 2. أخطاء انقطاع الاتصال والإنترنت والـ Timeout
    if (error is SocketException ||
        raw.contains('socketexception') ||
        raw.contains('failed host lookup') ||
        raw.contains('network') ||
        raw.contains('connection refused') ||
        raw.contains('connection reset') ||
        raw.contains('connection closed') ||
        raw.contains('handshake failed') ||
        raw.contains('clientexception')) {
      return 'تعذر الاتصال بالخادم، يرجى التحقق من اتصال الإنترنت والمحاولة ثانية.';
    }

    if (error is TimeoutException ||
        raw.contains('timeoutexception') ||
        raw.contains('timed out') ||
        raw.contains('timeout') ||
        raw.contains('deadline exceeded')) {
      return 'استغرق مزود الذكاء الاصطناعي وقتاً أطول من المتوقع للرد، يرجى المحاولة مجدداً.';
    }

    // 3. عدم وجود دالة الـ Edge Function في Supabase
    if ((raw.contains('ai-proxy') || raw.contains('function')) &&
        (raw.contains('404') || raw.contains('not found') || raw.contains('relay error'))) {
      return 'خدمة الذكاء الاصطناعي (ai-proxy) غير منشورة في Supabase، يرجى تفعيل الدالة من لوحة التحكم.';
    }

    // 4. عدم إدخال مفتاح الـ API
    if (raw.contains('يرجى إدخال مفتاح') ||
        raw.contains('api key is required') ||
        raw.contains('api_key_encrypted') ||
        raw.contains('missing api key') ||
        raw.contains('api key missing') ||
        raw.contains('لم يتم ضبط مفتاح')) {
      return 'يرجى إدخال مفتاح الـ API أولاً وحفظ الإعدادات للمتابعة.';
    }

    // 5. مفتاح API غير صالح أو منتهي الصلاحية أو غير مصرح به (Authentication / 401 / 403)
    if (raw.contains('401') ||
        raw.contains('403') ||
        raw.contains('invalid_api_key') ||
        raw.contains('incorrect api key') ||
        raw.contains('authentication_error') ||
        raw.contains('unauthorized') ||
        raw.contains('invalid x-api-key') ||
        raw.contains('permission denied') ||
        raw.contains('permission_denied') ||
        raw.contains('access denied') ||
        raw.contains('forbidden') ||
        raw.contains('invalid api key') ||
        raw.contains('api key not valid') ||
        raw.contains('api_key_invalid') ||
        raw.contains('unauthenticated') ||
        raw.contains('bad_api_key')) {
      return 'مفتاح الـ API غير صالح أو غير مصرح به، يرجى التأكد من نسخه بشكل صحيح من حسابك.';
    }

    // 6. رصيد الحساب غير كافٍ أو انتهت الباقة (Quota / Billing / 402)
    if (raw.contains('insufficient_quota') ||
        raw.contains('quota exceeded') ||
        raw.contains('exceeded your current quota') ||
        raw.contains('billing') ||
        raw.contains('credit balance') ||
        raw.contains('credit_balance') ||
        raw.contains('payment required') ||
        raw.contains('resource_exhausted') ||
        raw.contains('resource has been exhausted') ||
        raw.contains('out of credits') ||
        raw.contains('usage limit') ||
        raw.contains('402')) {
      return 'رصيد الحساب غير كافٍ أو انتهت باقة الاستخدام لدى المزود، يرجى شحن الرصيد في حسابك.';
    }

    // 7. الموديل غير موجود أو لا يملك الحساب صلاحية الوصول إليه (Model Not Found / 404)
    if (raw.contains('model_not_found') ||
        raw.contains('does not exist') ||
        raw.contains('model is not supported') ||
        raw.contains('invalid model') ||
        raw.contains('unknown model') ||
        raw.contains('model_permission') ||
        (raw.contains('model') && (raw.contains('not found') || raw.contains('404')))) {
      return 'الموديل المحدد غير متوفر في هذا الحساب أو تم إيقافه، يرجى اختيار موديل آخر مدعوم.';
    }

    // 8. المنطقة الجغرافية غير مدعومة للموديل
    if ((raw.contains('location') && raw.contains('not supported')) ||
        (raw.contains('region') && raw.contains('not supported')) ||
        raw.contains('country not supported')) {
      return 'خدمة الموديل غير مدعومة في منطقتك الجغرافية حالياً لدى المزود.';
    }

    // 9. تجاوز الحد الأقصى للطلبات المسموحة (Rate Limit / 429)
    if (raw.contains('429') ||
        raw.contains('rate_limit') ||
        raw.contains('rate limit') ||
        raw.contains('too many requests') ||
        raw.contains('requests per minute') ||
        raw.contains('tokens per minute')) {
      return 'تم تجاوز الحد الأقصى للطلبات المسموحة حالياً، يرجى الانتظار دقيقة والمحاولة مجدداً.';
    }

    // 10. ضغط أو عطل مؤقت لدى مزود الذكاء الاصطناعي (Server Errors / 500 / 502 / 503 / 504)
    if (raw.contains('500') ||
        raw.contains('502') ||
        raw.contains('503') ||
        raw.contains('504') ||
        raw.contains('overloaded') ||
        raw.contains('internal server error') ||
        raw.contains('service unavailable') ||
        raw.contains('bad gateway') ||
        raw.contains('server error')) {
      return 'مزود الذكاء الاصطناعي يواجه ضغطاً أو توقفاً مؤقتاً في الخدمة، يرجى المحاولة بعد قليل.';
    }

    // 11. خطأ في تنسيق استجابة الـ JSON
    if (raw.contains('invalid json') || raw.contains('formatexception')) {
      return 'استجاب مزود الذكاء الاصطناعي بتنسيق غير متوقع، يرجى إعادة المحاولة.';
    }

    // رسالة افتراضية واضحة في حال كان نص الخطأ غير معروف تماماً
    return 'تعذر إكمال العملية مع مزود الذكاء الاصطناعي، يرجى التحقق من صحة الإعدادات والمحاولة لاحقاً.';
  }

  /// تحويل أي استثناء خام إلى كائن AiFailure بنمط Clean Architecture
  /// ليتوافق مع الـ Repositories والـ UseCases بنمط Either<Failure, T>
  static AiFailure toFailure(dynamic error) {
    return AiFailure(sanitize(error));
  }
}

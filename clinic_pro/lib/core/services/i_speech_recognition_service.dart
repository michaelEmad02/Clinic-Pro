// ────────────────────────────────────────────────────────
// ISpeechRecognitionService — واجهة خدمة التعرف على الصوت
// تحدد العمليات الأساسية لتحويل الكلام إلى نص (Speech-to-Text)
// ────────────────────────────────────────────────────────

abstract class ISpeechRecognitionService {
  /// تهيئة الخدمة والتحقق من صلاحية الميكروفون وتوافر المحرك
  Future<bool> initialize();

  /// بدء الاستماع لصوت المستخدم
  /// - [onResult]: دالة رد نداء تُستدعى مع كل نص يتم التعرف عليه (جزئي أو نهائي)
  /// - [localeId]: كود اللغة (مثل 'ar_SA' أو 'ar_EG')
  Future<void> startListening({
    required Function(String recognizedWords, bool isFinal) onResult,
    String? localeId,
  });

  /// إيقاف الاستماع مع الاحتفاظ بآخر نتيجة
  Future<void> stopListening();

  /// إلغاء الاستماع وتجاهل النتيجة الجارية
  Future<void> cancelListening();

  /// هل الخدمة تستمع حالياً؟
  bool get isListening;

  /// هل المحرك جاهز ومتاح على هذا الجهاز؟
  bool get isAvailable;
}

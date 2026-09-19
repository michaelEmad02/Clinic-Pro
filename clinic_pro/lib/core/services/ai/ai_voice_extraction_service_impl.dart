// ────────────────────────────────────────────────────────
// AiVoiceExtractionServiceImpl — تنفيذ خدمة الاستخراج بالذكاء الاصطناعي
// يبني System Prompts دقيقة وموجهة لكل شاشة ويستدعي الـ Edge Function
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/services/ai/ai_edge_function_service.dart';
import 'package:clinic_pro/core/services/i_voice_extraction_service.dart';
import 'package:clinic_pro/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class AiVoiceExtractionServiceImpl implements IVoiceExtractionService {
  final AiEdgeFunctionService _edgeFunctionService;
  final IAuthRepository _authRepository;

  AiVoiceExtractionServiceImpl(
    this._edgeFunctionService,
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

    // استخراج ownerId من extraContext أو من بيانات المستخدم الحالي
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

    if (ownerId.isEmpty) {
      throw Exception('تعذر تحديد معرف المالك لاستخراج البيانات');
    }

    final systemPrompt = _buildSystemPrompt(target, extraContext);

    return await _edgeFunctionService.extract(
      ownerId: ownerId,
      systemPrompt: systemPrompt,
      userText: cleanText,
    );
  }

  String _buildSystemPrompt(
    ExtractionTarget target,
    Map<String, dynamic>? extraContext,
  ) {
    final now = DateTime.now();
    final todayStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    switch (target) {
      case ExtractionTarget.expense:
        final categories = extraContext?['categories'];
        final catListStr = categories is List
            ? categories
                .map((c) => c is String ? c : (c.name?.toString() ?? ''))
                .where((s) => s.isNotEmpty)
                .join(', ')
            : '';

        return '''
You are an expert clinic assistant extracting Expense data from Arabic or English speech into JSON.
Return ONLY a valid JSON object with:
- "amount": (number) The total expense amount. E.g. 250
- "category": (string or null) The best matching category. Available categories: [$catListStr].
- "description": (string or null) Description of what was purchased or spent on.

If a field is not mentioned, set it to null.
Output format:
{"amount": 250, "category": "مستلزمات طبية", "description": "شراء قفازات وشاش"}
''';

      case ExtractionTarget.patient:
        return '''
You are an expert clinic assistant extracting Patient details from Arabic or English speech into JSON.
Return ONLY a valid JSON object with:
- "name": (string or null) Patient's full name.
- "phone": (string or null) Phone number (clean digits only).
- "age": (number or null) Age in years.
- "gender": ("male" or "female" or null)
- "bloodType": (string or null) E.g. "A+", "O+", "B-".
- "allergies": (string or null) Any drug/food allergies mentioned.
- "medicalHistory": (string or null) Chronic diseases or medical history (e.g. سكري، ضغط).

If a field is not mentioned, set it to null.
Output format:
{"name": "محمد أحمد", "phone": "01012345678", "age": 35, "gender": "male", "bloodType": "A+", "allergies": "بنسلين", "medicalHistory": "ضغط"}
''';

      case ExtractionTarget.invoice:
        return '''
You are an expert clinic assistant extracting Invoice / Billing data from Arabic or English speech into JSON.
Return ONLY a valid JSON object with:
- "amount": (number) Total invoice amount or consultation fee.
- "discount": (number or null) Discount amount if mentioned, else 0.
- "paymentMethod": ("cash" or "card" or "insurance" or "bank_transfer" or null)
- "patientName": (string or null) Name of the patient if mentioned.
- "notes": (string or null) Any notes mentioned.

Output format:
{"amount": 500, "discount": 50, "paymentMethod": "cash", "patientName": "أحمد علي", "notes": "كشف مستعجل"}
''';

      case ExtractionTarget.appointment:
        return '''
You are an expert clinic assistant extracting Appointment booking details from Arabic or English speech into JSON.
Today's date is $todayStr.
Return ONLY a valid JSON object with:
- "patientName": (string or null) Patient name.
- "date": (string "YYYY-MM-DD" or null) Calculated appointment date relative to today (e.g. غداً, بكرة, بعد يومين, الأحد القادم).
- "time": (string "HH:mm" 24h format or null) E.g. "17:30" for 5:30 PM, "10:00" for 10 AM.
- "type": ("consultation" or "follow_up" or null) كشف -> "consultation", إعادة/استشارة -> "follow_up".
- "isUrgent": (boolean or null) true if described as urgent/emergency.

Output format:
{"patientName": "سارة محمود", "date": "$todayStr", "time": "18:00", "type": "consultation", "isUrgent": false}
''';

      case ExtractionTarget.prescription:
        final drugList = extraContext?['drugs'];
        final drugNames = drugList is List
            ? drugList.map((d) => d.toString()).take(100).join(', ')
            : '';

        final templatesList = extraContext?['templates'];
        final templateNames = templatesList is List
            ? templatesList.map((t) => t.toString()).take(30).join(', ')
            : '';

        return '''
You are an expert clinic medical assistant extracting Medical Prescription details from Arabic or English doctor speech into JSON.
Available known drug names for reference: [$drugNames].
Available known prescription templates: [$templateNames].

Return ONLY a valid JSON object with:
- "diagnosis": (string or null) Medical diagnosis or complaint (e.g. "التهاب حلق حاد", "Acute pharyngitis").
- "drugs": Array of drug objects, each having:
  - "name": (string) Drug trade or scientific name.
  - "frequency": (string or null) Frequency / dosage pattern (e.g. "3 مرات يومياً", "قرص كل 8 ساعات", "مرتين يومياً بعد الأكل").
  - "duration": (string or null) Duration of treatment (e.g. "لمدة 5 أيام", "أسبوع").
  - "timing": (string or null) Specific timing (e.g. "قبل الأكل", "بعد الأكل", "عند اللزوم").
  - "isPrn": (boolean) true if "عند اللزوم" / PRN.
- "nextVisitDays": (number or null) Follow-up visit in how many days (e.g. "استشارة بعد أسبوع" -> 7, "بعد 10 أيام" -> 10).
- "notes": (string or null) Medical advice, diet instructions, or special notes.
- "template": (string or null) Matching template name if doctor stated applying a template.

Output format:
{
  "diagnosis": "نزلة معوية حادة",
  "drugs": [
    {
      "name": "Antinal",
      "frequency": "قرص كل 8 ساعات",
      "duration": "5 أيام",
      "timing": "بعد الأكل",
      "isPrn": false
    }
  ],
  "nextVisitDays": 7,
  "notes": "شرب سوائل بكثرة والابتعاد عن الأطعمة الدسمة",
  "template": null
}
''';
    }
  }
}

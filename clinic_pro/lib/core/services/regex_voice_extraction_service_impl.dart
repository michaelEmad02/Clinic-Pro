// ────────────────────────────────────────────────────────
// RegexVoiceExtractionServiceImpl — تنفيذ خدمة الاستخراج الموحدة عبر Regex
// يعتمد على القواعد النمطية و ArabicTextHelper لاستخراج بيانات كل شاشة
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/services/i_voice_extraction_service.dart';
import 'package:clinic_pro/core/utils/arabic_text_helper.dart';
import 'package:clinic_pro/features/expenses/domain/entities/expense_category_entity.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class RegexVoiceExtractionServiceImpl implements IVoiceExtractionService {
  // كلمات العملات
  static const List<String> _currencyWords = [
    'جنيه', 'جنية', 'ريال', 'دولار', 'درهم', 'دينار', 'ليرة', 'هللة', 'قرش',
    'egp', 'sar', 'usd', 'aed',
  ];

  // كلمات الحشو والروابط للمصروفات
  static const List<String> _expenseFillerWords = [
    'اشتريت', 'دفعنا', 'دفعت', 'صرفت', 'صرفنا', 'مصاريف', 'مصروف',
    'سجل', 'اكتب', 'اضف', 'أضف', 'تكلفة', 'تكلفته', 'قيمة', 'قيمته', 'قيمتها',
    'بمبلغ', 'بقيمة', 'قدره', 'قدرها', 'سعره', 'سعر', 'حوالي', 'تقريبا', 'تقريباً',
    'حق', 'شراء', 'فاتورة',
  ];

  @override
  Future<Map<String, dynamic>> extractData({
    required String text,
    required ExtractionTarget target,
    Map<String, dynamic>? extraContext,
  }) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty) return {};

    switch (target) {
      case ExtractionTarget.expense:
        final categories = (extraContext?['categories'] as List<ExpenseCategoryEntity>?) ?? [];
        return _extractExpense(cleanText, categories);

      case ExtractionTarget.patient:
        return _extractPatient(cleanText);

      case ExtractionTarget.invoice:
        return _extractInvoice(cleanText);

      case ExtractionTarget.appointment:
        return _extractAppointment(cleanText);

      case ExtractionTarget.prescription:
        final rawDrugs = extraContext?['drugs'];
        final rawTemplates = extraContext?['templates'];
        return _extractPrescription(cleanText, rawDrugs: rawDrugs, rawTemplates: rawTemplates);
    }
  }

  // ─────────────────────────────────────────
  // 1. استخراج بيانات المصروفات (Expenses)
  // ─────────────────────────────────────────
  Map<String, dynamic> _extractExpense(
    String rawText,
    List<ExpenseCategoryEntity> categories,
  ) {
    final normalizedNumerals = ArabicTextHelper.normalizeNumerals(rawText);
    final amount = ArabicTextHelper.extractFirstNumber(normalizedNumerals) ?? 0.0;
    final matchedCategory = _matchExpenseCategory(normalizedNumerals, categories);
    final title = _extractExpenseTitle(normalizedNumerals, amount, matchedCategory?.name);

    return {
      'amount': amount,
      'categoryId': matchedCategory?.id,
      'categoryName': matchedCategory?.name,
      'title': title.isNotEmpty ? title : (matchedCategory?.name ?? rawText),
      'notes': null,
    };
  }

  ExpenseCategoryEntity? _matchExpenseCategory(
    String text,
    List<ExpenseCategoryEntity> categories,
  ) {
    if (categories.isEmpty) return null;
    final normalizedText = ArabicTextHelper.normalizeLetters(text);

    for (final cat in categories) {
      final normCatName = ArabicTextHelper.normalizeLetters(cat.name);
      if (normCatName.isEmpty) continue;
      if (normalizedText.contains(normCatName)) return cat;

      final tokens = normCatName.split(RegExp(r'\s+')).where((t) => t.length > 2);
      for (final token in tokens) {
        if (normalizedText.contains(token)) return cat;
      }
    }

    final keywordMap = {
      'كهرباء': ['كهرباء', 'نور'],
      'مياه': ['مياه', 'ميه', 'ماء'],
      'صيانة': ['صيانة', 'تصليح', 'مكيف', 'سباكة'],
      'مستلزمات': ['مستلزمات', 'قطن', 'شاش', 'قفازات', 'سرنجات', 'أدوات'],
      'إيجار': ['إيجار', 'ايجار'],
      'نظافة': ['نظافة', 'منظفات', 'مطهر', 'تعقيم'],
      'رواتب': ['راتب', 'رواتب', 'سلفة', 'مكافأة'],
      'أدوية': ['دواء', 'ادوية', 'علاج'],
    };

    for (final entry in keywordMap.entries) {
      for (final kw in entry.value) {
        if (normalizedText.contains(kw)) {
          final found = categories.where(
            (c) => ArabicTextHelper.normalizeLetters(c.name).contains(entry.key),
          );
          if (found.isNotEmpty) return found.first;
        }
      }
    }
    return null;
  }

  String _extractExpenseTitle(String text, double amount, String? categoryName) {
    final explicitRegex = RegExp(r'(?:بعنوان|باسم|بيان|تحت مسمى)\s+([^\d]+)', caseSensitive: false);
    final explicitMatch = explicitRegex.firstMatch(text);
    if (explicitMatch != null) {
      final explicitTitle = explicitMatch.group(1)?.trim() ?? '';
      if (explicitTitle.isNotEmpty) return ArabicTextHelper.cleanPunctuation(explicitTitle);
    }

    var cleaned = text;
    if (amount > 0) {
      cleaned = cleaned.replaceAll(amount.toString(), '');
      if (amount % 1 == 0) cleaned = cleaned.replaceAll(amount.toInt().toString(), '');
    }
    cleaned = cleaned.replaceAll(RegExp(r'\d+(\.\d+)?'), '');

    for (final currency in _currencyWords) {
      cleaned = cleaned.replaceAll(RegExp('\\b$currency\\b', caseSensitive: false), '');
      cleaned = cleaned.replaceAll(currency, '');
    }

    cleaned = ArabicTextHelper.stripTokensFromEdges(cleaned, _expenseFillerWords);
    cleaned = ArabicTextHelper.cleanPunctuation(cleaned);

    if (cleaned.isEmpty && categoryName != null && categoryName.isNotEmpty) {
      return categoryName;
    }
    return cleaned;
  }

  // ─────────────────────────────────────────
  // 2. استخراج بيانات المريض (Patients)
  // ─────────────────────────────────────────
  Map<String, dynamic> _extractPatient(String text) {
    final rawNumerals = ArabicTextHelper.normalizeNumerals(text);
    var nameWorkingText = rawNumerals;

    // 1. استخراج فصيلة الدم وإزالتها بالكامل من النص
    String? bloodType;
    final bloodResult = ArabicTextHelper.extractBloodType(rawNumerals);
    if (bloodResult != null) {
      bloodType = bloodResult.bloodType;
      nameWorkingText = nameWorkingText.replaceAll(bloodResult.matchedText, ' ');
    }

    // 2. استخراج رقم الهاتف وإزالته بالكامل من النص
    String? phone;
    final phoneResult = ArabicTextHelper.extractPhoneWithContext(nameWorkingText);
    if (phoneResult != null) {
      phone = phoneResult.phone;
      nameWorkingText = nameWorkingText.replaceAll(phoneResult.matchedText, ' ');
    }

    // 3. استخراج العمر وتاريخ الميلاد وإزالة جملة العمر بالكامل من النص
    int? age;
    final ageRegex = RegExp(
      r'(?:عمر[ه|ها]?|سن[ه|ها]?|عنده|عندها)\s*(\d{1,3})(?:\s*(?:سن[ةه]|عام[اً]?))?|(\d{1,3})\s*(?:سن[ةه]|عام[اً]?)\b',
    );
    final ageMatch = ageRegex.firstMatch(nameWorkingText);
    if (ageMatch != null) {
      final ageStr = ageMatch.group(1) ?? ageMatch.group(2);
      age = int.tryParse(ageStr ?? '');
      // إزالة جملة العمر بالكامل من النص
      nameWorkingText = nameWorkingText.replaceAll(ageMatch.group(0)!, ' ');
    }
    final birthDate = age != null && age > 0 ? DateTime(DateTime.now().year - age, 1, 1) : null;

    // 4. استخراج الجنس
    final gender = ArabicTextHelper.extractGender(text) ?? 'male';

    // 5. استخراج الحساسية وإزالتها بالكامل من النص
    String? allergies;
    final allergyRegex = RegExp(
      r'(?:حساسي[ةه]|عنده حساسي[ةه] من|يعاني من حساسي[ةه])\s+([^\d,.\n]+?)(?=\s+(?:و\s*)?(?:ساكن|يسكن|يقيم|عنوان|تليفون|هاتف|جوال|موبايل|رقم|عمر|سن|فصيل|دم|يعاني|مرض|سكر|ضغط)|$)',
      caseSensitive: false,
    );
    final allergyMatch = allergyRegex.firstMatch(nameWorkingText);
    if (allergyMatch != null) {
      final rawAllergy = allergyMatch.group(1)?.trim() ?? '';
      final stopTokens = ['و', 'من', 'عنده', 'تليفون', 'يسكن', 'ساكن', 'عمر', 'سن', 'فصيلة', 'فصيله', 'دمه', 'دمها'];
      allergies = rawAllergy.split(' ').where((w) => !stopTokens.contains(w)).take(3).join(' ');
      if (allergies.isNotEmpty) {
        nameWorkingText = nameWorkingText.replaceAll(allergyMatch.group(0)!, ' ');
      }
    }

    // 6. استخراج الأمراض المزمنة وإزالتها بالكامل
    final chronicMatches = <String>[];
    final normText = ArabicTextHelper.normalizeLetters(text);
    if (normText.contains('سكر')) chronicMatches.add('سكري');
    if (normText.contains('ضغط')) chronicMatches.add('ضغط دم');
    if (normText.contains('قلب')) chronicMatches.add('أمراض قلب');
    if (normText.contains('ربو')) chronicMatches.add('ربو');

    final chronicRegex = RegExp(r'(?:يعاني من|عنده|مصاب بـ?)\s*(?:مرض\s*)?(?:سكر|ضغط|قلب|ربو)(?:\s*(?:و\s*)?(?:سكر|ضغط|قلب|ربو))*');
    nameWorkingText = nameWorkingText.replaceAll(chronicRegex, ' ');

    // 7. استخراج العنوان وإزالته بالكامل
    String? address;
    final addressRegex = RegExp(
      r'(?:عنوان[ه|ها]?|يسكن في|ساكن في|يقيم في)\s+([^\d,.\n]+?)(?=\s+(?:و\s*)?(?:تليفون|هاتف|جوال|موبايل|رقم|عمر|سن|فصيل|دم|حساسي|يعاني|مرض|سكر|ضغط)|$)',
      caseSensitive: false,
    );
    final addressMatch = addressRegex.firstMatch(nameWorkingText);
    if (addressMatch != null) {
      address = ArabicTextHelper.cleanPunctuation(addressMatch.group(1)?.trim() ?? '');
      nameWorkingText = nameWorkingText.replaceAll(addressMatch.group(0)!, ' ');
    }

    // 8. استخراج اسم المريض
    String? name;

    // أ) الطريقة الأولى: استخراج مباشر عبر الكلمات الدالة على الاسم من النص الأصلي
    final explicitNameRegex = RegExp(
      r'(?:مريض(?:ة)?\s+(?:جديد(?:ة)?\s+)?اسمه(?:ا)?|اسم(?:ه|ها)?(?:\s+المريض(?:ة)?)?|المريض(?:ة)?\s+اسمه(?:ا)?|سجل\s+مريض(?:ة)?\s+(?:اسمه(?:ا)?)?|اضف\s+مريض(?:ة)?\s+(?:اسمه(?:ا)?)?)\s+([^\d,.:;\n]+?)(?=\s+(?:عمر|سن|تليفون|هاتف|جوال|موبايل|رقم|فصيل|دم|حساسي|يعاني|مرض|سكر|ضغط|قلب|ربو|ساكن|يسكن|عنوان|ذكر|انث|ست|سيد|مدام|ولد|بنت)|$)',
      caseSensitive: false,
    );
    final explicitMatch = explicitNameRegex.firstMatch(rawNumerals);
    if (explicitMatch != null) {
      final candidate = explicitMatch.group(1)?.trim();
      if (candidate != null && candidate.isNotEmpty) {
        final cleanedCandidate = ArabicTextHelper.cleanPunctuation(candidate);
        final tokens = cleanedCandidate.split(RegExp(r'\s+')).where((w) => w.length > 1).toList();
        if (tokens.isNotEmpty) {
          name = tokens.take(4).join(' ').trim();
        }
      }
    }

    // ب) الطريقة الثانية (الاحتياطية): بعد إزالة كافة الكيانات والكلمات الزائدة من nameWorkingText
    if (name == null || name.isEmpty) {
      final fillerPatientWords = [
        'مريض جديد اسمه', 'مريض جديد اسمها', 'مريض جديد', 'مريض اسمه', 'المريض', 'مريض',
        'سجل مريض', 'اضف مريض', 'اسمها', 'اسمه', 'اسم', 'الاسم',
        'تليفونه', 'تليفونها', 'تليفون', 'جواله', 'جوالها', 'جوال', 'موبايل', 'رقم',
        'عمره', 'عمرها', 'عنده', 'عندها', 'عمر', 'سن', 'سنه', 'سنة', 'عام', 'عاما',
        'ذكر', 'انثى', 'انثي', 'رجل', 'ست', 'سيدة', 'سيده', 'بنت', 'ولد', 'مدام', 'استاذ',
        'يعاني من', 'حساسية', 'حساسيه', 'امراض مزمنة', 'مرض مزمن', 'سكر', 'ضغط', 'قلب', 'ربو',
        'ساكن في', 'يسكن في', 'عنوانه', 'عنوان',
        'فصيلة دمه', 'فصيلة دمها', 'فصيلة الدم', 'فصيلة', 'فصيله', 'دمه', 'دمها', 'دم',
      ];

      for (final filler in fillerPatientWords) {
        nameWorkingText = nameWorkingText.replaceAll(RegExp('\\b$filler\\b', caseSensitive: false), ' ');
        nameWorkingText = nameWorkingText.replaceAll(filler, ' ');
      }

      // حذف أي أرقام أو حروف لغات أجنبية متبقية من فصائل الدم
      nameWorkingText = nameWorkingText.replaceAll(RegExp(r'[\d\+\-]+'), ' ');
      nameWorkingText = nameWorkingText.replaceAll(RegExp(r'\b(?:plus|minus|positive|negative)\b', caseSensitive: false), ' ');
      nameWorkingText = ArabicTextHelper.cleanPunctuation(nameWorkingText);

      final nameTokens = nameWorkingText
          .split(RegExp(r'\s+'))
          .where((w) => w.trim().length > 1 && !fillerPatientWords.contains(w.trim()))
          .toList();

      name = nameTokens.isNotEmpty ? nameTokens.take(4).join(' ').trim() : null;
    }

    return {
      'name': name,
      'phone': phone,
      'age': age,
      'gender': gender,
      'bloodType': bloodType,
      'birthDate': birthDate,
      'allergies': allergies,
      'chronicConditions': chronicMatches.isNotEmpty ? chronicMatches.join('، ') : null,
      'address': address,
    };
  }

  // ─────────────────────────────────────────
  // 3. استخراج بيانات الفاتورة (Invoices)
  // ─────────────────────────────────────────
  Map<String, dynamic> _extractInvoice(String text) {
    final rawNumerals = ArabicTextHelper.convertSpokenNumberWordsToDigits(
      ArabicTextHelper.normalizeNumerals(text),
    );
    var workingText = rawNumerals;
    final normLower = ArabicTextHelper.normalizeLetters(text);

    // 0. فحص ما إذا كانت الفاتورة معلقة أو غير مدفوعة (آجلة)
    bool isDeferred = false;
    if (normLower.contains('غير مدفوع') ||
        normLower.contains('معلق') ||
        normLower.contains('اجل') ||
        normLower.contains('آجل') ||
        normLower.contains('لم يدفع') ||
        normLower.contains('ما دفع') ||
        normLower.contains('بدون دفع') ||
        normLower.contains('دفع صفر') ||
        normLower.contains('باقي بالكامل')) {
      isDeferred = true;
    }

    // 1. استخراج طريقة الدفع
    String paymentMethod = 'cash';
    if (normLower.contains('فيزا') ||
        normLower.contains('شبكه') ||
        normLower.contains('شبكة') ||
        normLower.contains('بطاقه') ||
        normLower.contains('بطاقة') ||
        normLower.contains('مدي') ||
        normLower.contains('مدى') ||
        normLower.contains('كارت') ||
        normLower.contains('card')) {
      paymentMethod = 'card';
    } else if (normLower.contains('تحويل') ||
        normLower.contains('بنك') ||
        normLower.contains('انستاباي') ||
        normLower.contains('فودافون كاش') ||
        normLower.contains('transfer') ||
        normLower.contains('bank')) {
      paymentMethod = 'bank';
    } else if (normLower.contains('كاش') ||
        normLower.contains('نقد') ||
        normLower.contains('نقدي') ||
        normLower.contains('cash')) {
      paymentMethod = 'cash';
    }

    // 2. استخراج نوع الموعد المستنتج (كشف / استشارة / متابعة / جلسة)
    String? appointmentTypeHint;
    if (normLower.contains('استشاره')) appointmentTypeHint = 'استشارة';
    if (normLower.contains('كشف')) appointmentTypeHint = 'كشف';
    if (normLower.contains('متابعه')) appointmentTypeHint = 'متابعة';
    if (normLower.contains('جلسه')) appointmentTypeHint = 'جلسة';

    // 3. استخراج الخصم إن وجد
    double? discount;
    final discountRegex = RegExp(r'(?:خصم|تخفيض)\s*(\d+(?:\.\d+)?)');
    final discountMatch = discountRegex.firstMatch(workingText);
    if (discountMatch != null) {
      discount = double.tryParse(discountMatch.group(1) ?? '');
      workingText = workingText.replaceAll(discountMatch.group(0)!, ' ');
    }

    // 4. استخراج المبلغ المدفوع جزئياً إن وجد (مثل: "دفع 200" أو "مدفوع 150" أو "سدد 100")
    double? paidAmount;
    if (isDeferred) {
      paidAmount = 0.0;
    } else {
      final paidRegex = RegExp(r'(?:دفع(?:نا)?|مدفوع(?: منه)?|سدد(?:نا)?|مسدد)\s*(\d+(?:\.\d+)?)');
      final paidMatch = paidRegex.firstMatch(workingText);
      if (paidMatch != null) {
        paidAmount = double.tryParse(paidMatch.group(1) ?? '');
        workingText = workingText.replaceAll(paidMatch.group(0)!, ' ');
      }
    }

    // 5. استخراج رقم هاتف المريض إن وجد (بما في ذلك الأرقام المنطوقة مثل زيرو عشرة)
    String? patientPhone;
    final phoneResult = ArabicTextHelper.extractPhoneWithContext(workingText);
    if (phoneResult != null) {
      patientPhone = phoneResult.phone;
      workingText = workingText.replaceAll(phoneResult.matchedText, ' ');
    }

    // 6. استخراج المبلغ الإجمالي
    double? totalAmount;
    final explicitAmountRegex = RegExp(
      r'(?:[ب|ل]?مبلغ|[ب|ل]?قيم[ةه]|سعر[ه|ها]?|تكلف[ةه]|فاتور[ةه](?:\s+بـ?)?|كشف(?:\s+بـ?)?|استشار[ةه](?:\s+بـ?)?)\s*[:=\-]?\s*(\d+(?:\.\d+)?)(?:\s*(?:جنيه|ريال|دولار|درهم|دينار))?',
      caseSensitive: false,
    );
    final explicitMatch = explicitAmountRegex.firstMatch(workingText);
    if (explicitMatch != null) {
      totalAmount = double.tryParse(explicitMatch.group(1) ?? '');
      workingText = workingText.replaceAll(explicitMatch.group(0)!, ' ');
    } else {
      totalAmount = ArabicTextHelper.extractFirstNumber(workingText);
      if (totalAmount != null) {
        workingText = workingText.replaceAll(totalAmount.toString(), ' ');
        if (totalAmount % 1 == 0) {
          workingText = workingText.replaceAll(totalAmount.toInt().toString(), ' ');
        }
      }
    }

    // إذا كان هناك خصم وكان المبلغ الإجمالي مذكوراً قبل الخصم:
    if (totalAmount != null && discount != null && discount > 0) {
      if (totalAmount > discount) {
        totalAmount = totalAmount - discount;
      }
    }

    // إذا لم يحدد مبلغ مدفوع جزئي، ولم تكن الفاتورة معلقة: فالافتراضي دفع المبلغ كاملاً
    if (paidAmount == null && totalAmount != null && totalAmount > 0) {
      paidAmount = totalAmount;
    }

    // 7. استخراج اسم المريض
    String? patientName;
    final invoiceStopWords = [
      'اعمل', 'سجل', 'اضف', 'أنشئ', 'انشئ', 'فاتورة', 'فاتوره', 'كشف', 'استشارة', 'استشاره', 'متابعة', 'متابعه', 'جلسة', 'جلسه',
      'بمبلغ', 'مبلغ', 'بقيمة', 'بقيمه', 'قيمة', 'قيمه', 'دفع', 'مدفوع', 'خصم', 'تخفيض', 'كاش', 'نقد', 'نقدي',
      'فيزا', 'شبكة', 'شبكه', 'بطاقة', 'بطاقه', 'تحويل', 'بنك', 'معلق', 'غير مدفوع',
      'جنيه', 'ريال', 'دولار', 'درهم', 'دينار',
      'تليفون', 'هاتف', 'جوال', 'موبايل', 'رقم', 'برقم', 'لرقم', 'صاحب', 'صاحبة', 'صاحبه', 'لصاحب', 'لصاحبة', 'لصاحبه',
      'للمريض', 'للمريضة', 'للمريضه', 'لمريض', 'لمريضة', 'لمريضه', 'المريض', 'المريضة', 'المريضه', 'مريض', 'مريضة', 'مريضه', 'باسم', 'لحساب',
    ];
    final normalizedStopWords = invoiceStopWords.map(ArabicTextHelper.normalizeLetters).toSet();

    // أ) عبر كلمات التسمية الصريحة للمريض
    final explicitPatientRegex = RegExp(
      r'(?:ل?لمريض(?:[ةه])?|ل?مريض(?:[ةه])?\s+اسمه(?:ا)?|ل?مريض(?:[ةه])?|باسم(?:\s+المريض(?:[ةه])?)?|لحساب|حق|المريض(?:[ةه])?)\s+([^\d,.:;\n]+?)(?=\s+(?:[ب|ل]?مبلغ|[ب|ل]?قيم[ةه]|سعر[ه|ها]?|تكلف[ةه]|كشف|استشار[ةه]|متابع[ةه]|جلس[ةه]|دفع|مدفوع|خصم|تخفيض|كاش|فيزا|شبك[ةه]|بطاق[ةه]|تحويل|نقد|نقدي|غير\s+مدفوع|معلق|تليفون|هاتف|جوال|موبايل|رقم|صاحب(?:[ةه])?|جنيه|ريال|دولار|درهم|دينار)|$)',
      caseSensitive: false,
    );
    final patientMatch = explicitPatientRegex.firstMatch(workingText);
    if (patientMatch != null) {
      final cand = patientMatch.group(1)?.trim();
      if (cand != null && cand.isNotEmpty) {
        final clean = ArabicTextHelper.cleanPunctuation(cand);
        final tokens = clean
            .split(RegExp(r'\s+'))
            .where((w) =>
                w.length > 1 &&
                !normalizedStopWords.contains(ArabicTextHelper.normalizeLetters(w.trim())))
            .toList();
        if (tokens.isNotEmpty) {
          patientName = tokens.take(4).join(' ').trim();
        }
      }
    }

    // ب) إن لم يتم العثور على بادئة صريحة، نفحص ما تبقى قبل كلمات الفاتورة
    if (patientName == null || patientName.isEmpty) {
      var nameCandidate = workingText;
      for (final stop in invoiceStopWords) {
        nameCandidate = nameCandidate.replaceAll(RegExp('\\b$stop\\b', caseSensitive: false), ' ');
        nameCandidate = nameCandidate.replaceAll(stop, ' ');
      }
      nameCandidate = nameCandidate.replaceAll(RegExp(r'\d+'), ' ');
      nameCandidate = ArabicTextHelper.cleanPunctuation(nameCandidate);

      final tokens = nameCandidate
          .split(RegExp(r'\s+'))
          .where((w) =>
              w.trim().length > 1 &&
              !normalizedStopWords.contains(ArabicTextHelper.normalizeLetters(w.trim())))
          .toList();
      if (tokens.isNotEmpty) {
        patientName = tokens.take(4).join(' ').trim();
      }
    }

    return {
      'patientName': patientName,
      'patientPhone': patientPhone,
      'totalAmount': totalAmount,
      'paidAmount': paidAmount,
      'discount': discount,
      'paymentMethod': paymentMethod,
      'isDeferred': isDeferred,
      'appointmentTypeHint': appointmentTypeHint,
    };
  }

  // ─────────────────────────────────────────
  // 4. استخراج بيانات الموعد (Appointments)
  // ─────────────────────────────────────────
  Map<String, dynamic> _extractAppointment(String rawText) {
    // 1. تحويل الأرقام المشرقية والكلمات المنطوقة للأرقام
    final normalizedNumerals = ArabicTextHelper.normalizeNumerals(rawText);
    final workingWithDigits = ArabicTextHelper.convertSpokenNumberWordsToDigits(normalizedNumerals);

    // 2. استخراج الملاحظات (Notes) وفصلها عن باقي النص
    String? notes;
    String workingText = workingWithDigits;
    final notesMatch = RegExp(
      r'(?:يشتكي من|يعاني من|عنده|ملاحظة|ملاحظات|notes?:?)\s+(.+)$',
      caseSensitive: false,
    ).firstMatch(workingText);

    if (notesMatch != null) {
      notes = notesMatch.group(1)?.trim();
      workingText = workingText.substring(0, notesMatch.start).trim();
    }

    // 3. استخراج نوع الزيارة (Visit Type)
    // "كشف مستعجل" يختار نوع الزيارة كشف مستعجل دون تفعيل مفتاح حالة طوارئ
    String? type;
    String? visitTypeHint;
    final normWorking = ArabicTextHelper.normalizeLetters(workingText);
    if (normWorking.contains('كشف مستعجل') || normWorking.contains('فحص مستعجل')) {
      type = 'urgent_examination';
      visitTypeHint = 'كشف مستعجل';
    } else if (normWorking.contains('استشاره') || normWorking.contains('consultation')) {
      type = 'consultation';
      visitTypeHint = 'استشارة';
    } else if (normWorking.contains('طوارئ') || normWorking.contains('emergency')) {
      type = 'emergency';
      visitTypeHint = 'طوارئ';
    } else if (normWorking.contains('متابعه') || normWorking.contains('اعاده') || normWorking.contains('follow')) {
      type = 'follow_up';
      visitTypeHint = 'متابعة';
    } else if (normWorking.contains('جلسه') || normWorking.contains('session')) {
      type = 'session';
      visitTypeHint = 'جلسة';
    } else if (normWorking.contains('كشف') || normWorking.contains('فحص') || normWorking.contains('checkup') || normWorking.contains('examination')) {
      type = 'examination';
      visitTypeHint = 'كشف';
    }

    // 4. فحص حالة الطوارئ (Urgent)
    // لا يتفعل بمجرد "كشف مستعجل"، ولكن يتفعل عند قول "حالة طارئة" أو "طوارئ" أو "حالة حرجة"
    bool isUrgent = false;
    final hasEmergencyKeywords = normWorking.contains('حاله طارئه') ||
        normWorking.contains('حالة طارئة') ||
        normWorking.contains('طوارئ') ||
        normWorking.contains('طارئ') ||
        normWorking.contains('طارئه') ||
        normWorking.contains('حاله حرجه') ||
        normWorking.contains('حالة حرجة') ||
        normWorking.contains('emergency') ||
        (!normWorking.contains('كشف مستعجل') && (normWorking.contains('مستعجل') || normWorking.contains('urgent')));

    if (hasEmergencyKeywords) {
      isUrgent = true;
    }

    // 5. استخراج رقم الهاتف (Phone)
    String? patientPhone;
    final phoneResult = ArabicTextHelper.extractPhoneWithContext(workingText);
    if (phoneResult != null) {
      patientPhone = phoneResult.phone;
      if (phoneResult.matchedText.isNotEmpty) {
        workingText = workingText.replaceFirst(phoneResult.matchedText, ' ');
      } else if (phoneResult.phone.isNotEmpty) {
        workingText = workingText.replaceFirst(phoneResult.phone, ' ');
      }
    }

    // 6. استخراج التاريخ (Date)
    final date = _parseAppointmentDate(workingText);

    // 7. استخراج الوقت (Time)
    int? timeHour;
    int? timeMinute;
    String? timeString;
    final timeParsed = _parseAppointmentTime(workingText);
    if (timeParsed != null) {
      timeHour = timeParsed['hour'];
      timeMinute = timeParsed['minute'];
      timeString = '${timeHour!.toString().padLeft(2, '0')}:${timeMinute!.toString().padLeft(2, '0')}';
    }

    // 8. استخراج اسم المريض (Patient Name)
    final patientName = _parseAppointmentPatientName(workingText);

    return {
      'patientName': patientName,
      'patientPhone': patientPhone,
      'date': date,
      'timeHour': timeHour,
      'timeMinute': timeMinute,
      'timeString': timeString,
      'isUrgent': isUrgent,
      'type': type,
      'visitTypeHint': visitTypeHint,
      'notes': notes,
      'rawHint': rawText,
    };
  }

  DateTime? _parseAppointmentDate(String text) {
    final now = DateTime.now();
    final norm = ArabicTextHelper.normalizeLetters(text);

    // 1. التواريخ النسبية (اليوم، بكرة، بعد بكرة)
    if (norm.contains('بعد بكره') || norm.contains('بعد غد') || norm.contains('day after tomorrow')) {
      return DateTime(now.year, now.month, now.day + 2);
    }
    if (norm.contains('بكره') || norm.contains('غدا') || norm.contains('باكر') || norm.contains('tomorrow')) {
      return DateTime(now.year, now.month, now.day + 1);
    }
    if (norm.contains('اليوم') || norm.contains('النهارده') || norm.contains('today')) {
      return DateTime(now.year, now.month, now.day);
    }

    // 2. أيام الأسبوع (السبت، الأحد...)
    final weekdayMap = <int, List<String>>{
      DateTime.saturday: ['السبت', 'سبت', 'saturday', 'sat'],
      DateTime.sunday: ['الاحد', 'حد', 'sunday', 'sun'],
      DateTime.monday: ['الاثنين', 'تنين', 'اتنين', 'monday', 'mon'],
      DateTime.tuesday: ['الثلاثاء', 'التلات', 'الثلاثا', 'تلات', 'tuesday', 'tue'],
      DateTime.wednesday: ['الاربعاء', 'الاربعا', 'الاربع', 'اربع', 'wednesday', 'wed'],
      DateTime.thursday: ['الخميس', 'خميس', 'thursday', 'thu'],
      DateTime.friday: ['الجمعه', 'جمعه', 'friday', 'fri'],
    };

    for (final entry in weekdayMap.entries) {
      final targetWeekday = entry.key;
      for (final keyword in entry.value) {
        final pattern = RegExp('(?:^|\\s)(?:يوم\\s+)?$keyword(?:\\s|\$)', caseSensitive: false);
        if (pattern.hasMatch(norm) || norm.contains('يوم $keyword')) {
          int diff = targetWeekday - now.weekday;
          if (diff < 0) diff += 7;
          if (diff == 0 && (norm.contains('القادم') || norm.contains('الجاي') || norm.contains('next'))) {
            diff = 7;
          }
          return DateTime(now.year, now.month, now.day + diff);
        }
      }
    }

    // 3. تواريخ صريحة (ISO: YYYY-MM-DD)
    final isoMatch = RegExp(r'(\d{4})[/-](\d{1,2})[/-](\d{1,2})').firstMatch(text);
    if (isoMatch != null) {
      final y = int.tryParse(isoMatch.group(1)!);
      final m = int.tryParse(isoMatch.group(2)!);
      final d = int.tryParse(isoMatch.group(3)!);
      if (y != null && m != null && d != null) {
        return DateTime(y, m, d);
      }
    }

    // 4. تواريخ صريحة (DD/MM أو DD/MM/YYYY)
    final dmyMatch = RegExp(r'(?:بتاريخ|تاريخ|يوم)?\s*(\d{1,2})[/-](\d{1,2})(?:[/-](\d{2,4}))?').firstMatch(text);
    if (dmyMatch != null) {
      final d = int.tryParse(dmyMatch.group(1)!);
      final m = int.tryParse(dmyMatch.group(2)!);
      var y = dmyMatch.group(3) != null ? int.tryParse(dmyMatch.group(3)!) : now.year;
      if (y != null && y < 100) y += 2000;
      if (d != null && m != null && y != null) {
        return DateTime(y, m, d);
      }
    }

    // 5. يوم محدد من الشهر: "يوم 25" أو "بتاريخ 15"
    final dayOnlyMatch = RegExp(r'(?:بتاريخ|تاريخ|يوم)\s*(\d{1,2})\b').firstMatch(text);
    if (dayOnlyMatch != null) {
      final d = int.tryParse(dayOnlyMatch.group(1)!);
      if (d != null && d >= 1 && d <= 31) {
        var m = now.month;
        var y = now.year;
        if (d < now.day) {
          m += 1;
          if (m > 12) {
            m = 1;
            y += 1;
          }
        }
        return DateTime(y, m, d);
      }
    }

    return null;
  }

  Map<String, int>? _parseAppointmentTime(String text) {
    final norm = ArabicTextHelper.normalizeLetters(text);

    int? hour;
    int minute = 0;

    // أ) التنسيق الرقمي المباشر HH:mm
    final colonMatch = RegExp(r'(?:الساعة|الساعه|ساعة|ساعه|at)?\s*(\d{1,2}):(\d{2})').firstMatch(text);
    if (colonMatch != null) {
      hour = int.tryParse(colonMatch.group(1)!);
      minute = int.tryParse(colonMatch.group(2)!) ?? 0;
    }

    // ب) نطق الساعة بالكلمات مع أجزائها: "الساعة 5 ونص"، "الساعة 6 إلا ربع"
    if (hour == null) {
      final hourMatch = RegExp(r'(?:الساعة|الساعه|ساعة|ساعه|at)\s*(\d{1,2})').firstMatch(text);
      if (hourMatch != null) {
        hour = int.tryParse(hourMatch.group(1)!);
        final matchStart = hourMatch.start;
        final afterHour = norm.length > matchStart ? norm.substring(matchStart) : norm;

        if (afterHour.contains('الا ربع')) {
          hour = (hour ?? 1) - 1;
          minute = 45;
        } else if (afterHour.contains('الا تلت') || afterHour.contains('الا ثلث')) {
          hour = (hour ?? 1) - 1;
          minute = 40;
        } else if (afterHour.contains('ونص') || afterHour.contains('ونصف')) {
          minute = 30;
        } else if (afterHour.contains('وربع')) {
          minute = 15;
        } else if (afterHour.contains('وتلت') || afterHour.contains('وثلث')) {
          minute = 20;
        } else if (afterHour.contains('وعشره') || afterHour.contains('وعشرة')) {
          minute = 10;
        } else if (afterHour.contains('وخمسه') || afterHour.contains('وخمسة')) {
          minute = 5;
        }
      }
    }

    if (hour == null) return null;

    final isPM = norm.contains('مساء') ||
        norm.contains('المساء') ||
        norm.contains('العصر') ||
        norm.contains('المغرب') ||
        norm.contains('العشا') ||
        norm.contains('بالليل') ||
        norm.contains('ليل') ||
        norm.contains('الظهر') ||
        norm.contains('pm');

    final isAM = norm.contains('صباحا') ||
        norm.contains('الصبح') ||
        norm.contains('صبح') ||
        norm.contains('am');

    if (isPM) {
      if (hour < 12) hour += 12;
    } else if (isAM) {
      if (hour == 12) hour = 0;
    } else {
      // الساعات من 1 إلى 7 تعتبر في العيادات أوقات مسائية تلقائياً
      if (hour >= 1 && hour <= 7) {
        hour += 12;
      }
    }

    if (hour < 0) hour += 24;
    hour = hour % 24;

    return {'hour': hour, 'minute': minute};
  }

  String? _parseAppointmentPatientName(String text) {
    // قائمة كلمات التوقف التي تنهي قراءة الاسم أو يتم تجاهلها
    final stopWords = {
      // الكلمات الإجرائية والبادئات
      'مريض', 'مريضة', 'لمريض', 'للمريض', 'لمريضة', 'للمريضة',
      'موعد', 'حجز', 'احجز', 'سجل', 'تسجيل', 'اسم', 'اسمه', 'اسمها',
      'لرقم', 'رقم', 'صاحب', 'صاحبة',
      // كلمات الوقت والتاريخ
      'اليوم', 'النهاردة', 'النهارده', 'بكرة', 'بكره', 'غدا', 'غداً', 'باكر',
      'بعد', 'السبت', 'الأحد', 'الاحد', 'الاثنين', 'الإثنين', 'الثلاثاء', 'التلات',
      'الأربعاء', 'الاربعاء', 'الاربع', 'الخميس', 'الجمعة', 'الجمعه', 'يوم', 'تاريخ', 'بتاريخ',
      'الساعة', 'الساعه', 'ساعة', 'ساعه', 'صباحا', 'صباحاً', 'الصبح', 'صبح',
      'مساء', 'مساءً', 'المساء', 'العصر', 'المغرب', 'العشا', 'العشاء', 'بالليل', 'ليل', 'الظهر',
      'ونص', 'ونصف', 'وربع', 'وثلث', 'وتلت', 'إلا', 'الا', 'دقائق', 'دقيقة',
      // أنواع الزيارات وحالة الطوارئ
      'كشف', 'استشارة', 'استشاره', 'متابعة', 'متابعه', 'جلسة', 'جلسه', 'فحص', 'عادي',
      'مستعجل', 'مستعجله', 'طارئ', 'طارئه', 'طوارئ', 'حالة', 'حاله', 'حرجة', 'حرجه',
      // روابط وحروف جر
      'في', 'من', 'مع', 'عند', 'بمبلغ', 'بقيمة', 'دفع', 'سعر', 'تلفون', 'هاتف', 'موبايل',
      'عنده', 'يشتكي', 'يعاني', 'ملاحظة', 'ملاحظات',
      // إنجليزي
      'today', 'tomorrow', 'at', 'pm', 'am', 'urgent', 'emergency', 'doctor', 'clinic', 'notes',
      'for', 'patient', 'appointment', 'booking', 'checkup', 'consultation', 'session', 'book',
    };

    final normStopWords = stopWords.map(ArabicTextHelper.normalizeLetters).toSet();

    final patterns = [
      RegExp(r'(?:للمريض|للمريضة|لمريض|لمريضة|المريض|المريضة|مريض|مريضة|patient\s+name|patient|book\s+for|appointment\s+for)\s+(?:اسمه|اسمها)?\s*([^\d,;!؟\n]+)', caseSensitive: false),
      RegExp(r'(?:احجز|حجز|موعد)\s+(?:لـ|ل)\s+([^\d,;!؟\n]+)', caseSensitive: false),
      RegExp(r'(?:احجز|حجز|موعد)\s+([^\d,;!؟\n]+)', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        final rawCandidate = match.group(1) ?? '';
        final rawTokens = rawCandidate.split(RegExp(r'\s+'));
        final candidateTokens = <String>[];

        for (final token in rawTokens) {
          final cleanToken = token.replaceAll(RegExp(r'[,.\-_:;!؟?]'), '').trim();
          if (cleanToken.isEmpty) continue;
          final normToken = ArabicTextHelper.normalizeLetters(cleanToken);
          if (normStopWords.contains(normToken)) {
            // إذا جمعنا كلمات بالفعل نتوقف، أما إذا كانت كلمة التوقف بادئة نتجاهلها
            if (candidateTokens.isNotEmpty) break;
            continue;
          }
          candidateTokens.add(cleanToken);
        }

        if (candidateTokens.isNotEmpty) {
          final name = candidateTokens.take(4).join(' ').trim();
          if (name.isNotEmpty && !normStopWords.contains(ArabicTextHelper.normalizeLetters(name))) {
            return name;
          }
        }
      }
    }

    return null;
  }

  // ─────────────────────────────────────────
  // 5. استخراج بيانات الروشتة الطبية (Prescriptions)
  // ─────────────────────────────────────────
  Map<String, dynamic> _extractPrescription(
    String rawText, {
    dynamic rawDrugs,
    dynamic rawTemplates,
  }) {
    final normalizedNumerals = ArabicTextHelper.normalizeNumerals(rawText);
    final workingWithDigits = ArabicTextHelper.convertSpokenNumberWordsToDigits(normalizedNumerals);

    // 1. استخراج الملاحظات والتعليمات (Notes)
    String? notes;
    String workingText = workingWithDigits;
    final notesMatch = RegExp(
      r'(?:ملاحظات|ملاحظة|تعليمات|نصائح|notes?:?)\s+(.+)$',
      caseSensitive: false,
    ).firstMatch(workingText);

    if (notesMatch != null) {
      notes = notesMatch.group(1)?.trim();
      workingText = workingText.substring(0, notesMatch.start).trim();
    }

    // 2. استخراج موعد الزيارة القادمة / الاستشارة (Next Visit Days)
    int? nextVisitDays;
    bool clearNextVisitDays = false;
    final visitMatch = _parseNextVisitDays(workingText);
    if (visitMatch != null) {
      nextVisitDays = visitMatch['days'] as int?;
      clearNextVisitDays = visitMatch['clear'] == true;
      final matchedText = visitMatch['matchedText'] as String?;
      if (matchedText != null && matchedText.isNotEmpty) {
        workingText = workingText.replaceFirst(matchedText, ' ');
      }
    }

    // 3. استخراج القالب (Template) إن وجد
    String? appliedTemplateId;
    String? appliedTemplateName;
    final templateMatch = _parseTemplate(workingText, rawTemplates);
    if (templateMatch != null) {
      appliedTemplateId = templateMatch['id'] as String?;
      appliedTemplateName = templateMatch['name'] as String?;
      final matchedText = templateMatch['matchedText'] as String?;
      if (matchedText != null && matchedText.isNotEmpty) {
        workingText = workingText.replaceFirst(matchedText, ' ');
      }
    }

    // 4. استخراج التشخيص (Diagnosis)
    String? diagnosis;
    final diagnosisMatch = _parseDiagnosis(workingText);
    if (diagnosisMatch != null) {
      diagnosis = diagnosisMatch['diagnosis'] as String?;
      final matchedText = diagnosisMatch['matchedText'] as String?;
      if (matchedText != null && matchedText.isNotEmpty) {
        workingText = workingText.replaceFirst(matchedText, ' ');
      }
    }

    // 5. استخراج الأدوية والجرعات (Drugs & Dosages) مع دعم اللغتين (عربي وإنجليزي)
    final extractedDrugs = _parsePrescriptionDrugs(workingText, rawDrugs);

    return {
      'diagnosis': diagnosis,
      'appliedTemplateId': appliedTemplateId,
      'appliedTemplateName': appliedTemplateName,
      'nextVisitDays': nextVisitDays,
      'clearNextVisitDays': clearNextVisitDays,
      'notes': notes,
      'drugs': extractedDrugs,
      'rawHint': rawText,
    };
  }

  Map<String, dynamic>? _parseNextVisitDays(String text) {
    final norm = ArabicTextHelper.normalizeLetters(text);

    // إلغاء الاستشارة
    if (norm.contains('بدون استشاره') ||
        norm.contains('بدون متابعه') ||
        norm.contains('لا داعي للاستشاره') ||
        norm.contains('لا داعي للمتابعه') ||
        norm.contains('no follow up')) {
      return {'days': null, 'clear': true, 'matchedText': null};
    }

    // أسبوعين / 14 يوماً
    final matchTwoWeeks = RegExp(
      r'(?:الاستشارة|الاستشاره|المتابعة|المتابعه|إعادة|اعاده|كشف|زيارة|زياره|follow\s*up|next\s*visit)?\s*(?:بعد)?\s*(?:اسبوعين|أسبوعين|14\s*يوما?|two\s*weeks)',
      caseSensitive: false,
    ).firstMatch(text);
    if (matchTwoWeeks != null && (norm.contains('اسبوعين') || norm.contains('14') || norm.contains('two weeks'))) {
      return {'days': 14, 'clear': false, 'matchedText': matchTwoWeeks.group(0)};
    }

    // 3 أسابيع / 21 يوماً
    final matchThreeWeeks = RegExp(
      r'(?:الاستشارة|الاستشاره|المتابعة|المتابعه|إعادة|اعاده|كشف|زيارة|زياره|follow\s*up|next\s*visit)?\s*(?:بعد)?\s*(?:3\s*اسابيع|تلات\s*اسابيع|ثلاثة\s*اسابيع|21\s*يوما?|three\s*weeks)',
      caseSensitive: false,
    ).firstMatch(text);
    if (matchThreeWeeks != null && (norm.contains('21') || norm.contains('3 اسابيع') || norm.contains('three weeks'))) {
      return {'days': 21, 'clear': false, 'matchedText': matchThreeWeeks.group(0)};
    }

    // شهر / 30 يوماً
    final matchMonth = RegExp(
      r'(?:الاستشارة|الاستشاره|المتابعة|المتابعه|إعادة|اعاده|كشف|زيارة|زياره|follow\s*up|next\s*visit)?\s*(?:بعد)?\s*(?:شهر|30\s*يوما?|a\s*month|one\s*month|30\s*days)',
      caseSensitive: false,
    ).firstMatch(text);
    if (matchMonth != null && (norm.contains('شهر') || norm.contains('30') || norm.contains('month'))) {
      return {'days': 30, 'clear': false, 'matchedText': matchMonth.group(0)};
    }

    // أسبوع / 7 أيام
    final matchWeek = RegExp(
      r'(?:الاستشارة|الاستشاره|المتابعة|المتابعه|إعادة|اعاده|كشف|زيارة|زياره|follow\s*up|next\s*visit)?\s*(?:بعد)?\s*(?:اسبوع|أسبوع|7\s*ايام?|a\s*week|one\s*week|7\s*days)',
      caseSensitive: false,
    ).firstMatch(text);
    if (matchWeek != null && (norm.contains('اسبوع') || norm.contains('7') || norm.contains('week'))) {
      return {'days': 7, 'clear': false, 'matchedText': matchWeek.group(0)};
    }

    // 3 أيام
    final matchThreeDays = RegExp(
      r'(?:الاستشارة|الاستشاره|المتابعة|المتابعه|إعادة|اعاده|كشف|زيارة|زياره|follow\s*up|next\s*visit)?\s*(?:بعد)?\s*(?:3\s*ايام|تلات\s*ايام|ثلاثة\s*ايام|3\s*days)',
      caseSensitive: false,
    ).firstMatch(text);
    if (matchThreeDays != null && (norm.contains('3 ايام') || norm.contains('تلات ايام') || norm.contains('ثلاثه ايام') || norm.contains('3 days'))) {
      return {'days': 3, 'clear': false, 'matchedText': matchThreeDays.group(0)};
    }

    // أي عدد أيام آخر صريح: "الاستشارة بعد 5 أيام"
    final matchCustom = RegExp(
      r'(?:الاستشارة|الاستشاره|المتابعة|المتابعه|إعادة|اعاده|زيارة|زياره|follow\s*up|next\s*visit)\s*(?:بعد)?\s*(\d{1,2})\s*(?:ايام|أيام|يوم|days?)',
      caseSensitive: false,
    ).firstMatch(text);
    if (matchCustom != null) {
      final d = int.tryParse(matchCustom.group(1)!);
      if (d != null && d > 0) {
        return {'days': d, 'clear': false, 'matchedText': matchCustom.group(0)};
      }
    }

    return null;
  }

  Map<String, dynamic>? _parseTemplate(String text, dynamic rawTemplates) {
    if (rawTemplates == null) return null;
    final List<dynamic> templatesList = rawTemplates is List ? rawTemplates : [];
    if (templatesList.isEmpty) return null;

    final normText = ArabicTextHelper.normalizeLetters(text);

    // التحقق من وجود كلمة دالة على القوالب في الحديث
    final hasTemplateKeyword = normText.contains('قالب') ||
        normText.contains('نموذج') ||
        normText.contains('روشته جاهزه') ||
        normText.contains('روشتة جاهزة') ||
        text.toLowerCase().contains('template');

    if (hasTemplateKeyword) {
      // 1. محاولة استخراج اسم القالب بعد كلمة قالب / template
      final regex = RegExp(
        r'(?:تطبيق\s+قالب|استخدم\s+قالب|استدعاء\s+قالب|قالب\s+روشتة|قالب\s+روشته|قالب|نموذج|apply\s+template|use\s+template|template)\s*[:\s]\s*([^\n,،]+)',
        caseSensitive: false,
      );
      final match = regex.firstMatch(text);
      if (match != null) {
        final query = match.group(1)?.trim() ?? '';
        final stopWords = {
          'التشخيص', 'تشخيص', 'ادوية', 'دواء', 'اكتب', 'الاستشارة', 'ملاحظات',
          'diagnosis', 'notes', 'drug', 'prescribe',
        }.map(ArabicTextHelper.normalizeLetters).toSet();

        final queryTokens = query.split(RegExp(r'\s+'));
        final cleanTokens = <String>[];
        for (final t in queryTokens) {
          final normT = ArabicTextHelper.normalizeLetters(t);
          if (stopWords.contains(normT)) break;
          cleanTokens.add(t);
        }
        final cleanQuery = cleanTokens.join(' ').trim();

        if (cleanQuery.isNotEmpty) {
          for (final t in templatesList) {
            final name = _getTemplateName(t);
            if (name.isEmpty) continue;
            // مطابقة عابرة للغات (عربي / إنجليزي)
            if (ArabicTextHelper.isSameOrMatchingName(name, cleanQuery) ||
                ArabicTextHelper.normalizeLetters(name).contains(ArabicTextHelper.normalizeLetters(cleanQuery)) ||
                ArabicTextHelper.normalizeLetters(cleanQuery).contains(ArabicTextHelper.normalizeLetters(name))) {
              return {
                'id': _getTemplateId(t),
                'name': name,
                'matchedText': match.group(0),
              };
            }
          }
        }
      }

      // 2. فحص أسماء القوالب المباشرة مع كلمة قالب
      for (final t in templatesList) {
        final name = _getTemplateName(t);
        if (name.isEmpty) continue;
        final normName = ArabicTextHelper.normalizeLetters(name);
        if (normText.contains('قالب $normName') ||
            text.toLowerCase().contains('template ${name.toLowerCase()}')) {
          return {
            'id': _getTemplateId(t),
            'name': name,
            'matchedText': 'قالب $name',
          };
        }

        // مطابقة صوتية مع الكلمات المجاورة لكلمة قالب
        final words = text.split(RegExp(r'\s+'));
        for (int i = 0; i < words.length; i++) {
          final wNorm = ArabicTextHelper.normalizeLetters(words[i]);
          if (wNorm == 'قالب' || words[i].toLowerCase() == 'template') {
            final candidate = words.skip(i + 1).take(3).join(' ');
            if (candidate.isNotEmpty && ArabicTextHelper.isSameOrMatchingName(name, candidate)) {
              return {
                'id': _getTemplateId(t),
                'name': name,
                'matchedText': '${words[i]} $candidate',
              };
            }
          }
        }
      }
    }

    return null;
  }

  Map<String, dynamic>? _parseDiagnosis(String text) {
    final regex = RegExp(
      r'(?:التشخيص|تشخيص|تشخيصه|تشخيص المريض|diagnosis:?)\s+([^\n,،]+)',
      caseSensitive: false,
    );
    final match = regex.firstMatch(text);
    if (match != null) {
      final rawCandidate = match.group(1)?.trim() ?? '';
      final tokens = rawCandidate.split(RegExp(r'\s+'));
      final candidateTokens = <String>[];

      final stopWords = {
        'اكتب', 'دواء', 'ادوية', 'علاج', 'روشتة', 'قالب',
        'الاستشارة', 'الاستشاره', 'المتابعة', 'المتابعه', 'إعادة', 'اعاده',
        'ملاحظات', 'ملاحظة', 'تعليمات', 'نصائح', 'قرص', 'حقنة', 'كبسول',
        'write', 'prescribe', 'drug', 'notes', 'follow',
      }.map(ArabicTextHelper.normalizeLetters).toSet();

      for (final token in tokens) {
        final norm = ArabicTextHelper.normalizeLetters(token.replaceAll(RegExp(r'[,.\-_:;!؟?]'), ''));
        if (norm.isEmpty) continue;
        if (stopWords.contains(norm)) break;
        candidateTokens.add(token);
      }

      if (candidateTokens.isNotEmpty) {
        final diag = candidateTokens.join(' ').trim();
        final rawStr = match.group(0)!;
        final lastToken = candidateTokens.last;
        final endOffsetInMatch = rawStr.indexOf(lastToken) + lastToken.length;
        final exactMatchedSegment = text.substring(match.start, match.start + endOffsetInMatch);

        return {
          'diagnosis': diag,
          'matchedText': exactMatchedSegment,
        };
      }
    }
    return null;
  }

  List<Map<String, dynamic>> _parsePrescriptionDrugs(String text, dynamic rawDrugs) {
    final List<dynamic> drugsDb = rawDrugs is List ? rawDrugs : [];
    final List<Map<String, dynamic>> matchedDrugs = [];

    final normalizedNumerals = ArabicTextHelper.normalizeNumerals(text);
    final textWithDigits = ArabicTextHelper.convertSpokenNumberWordsToDigits(normalizedNumerals);
    final normText = ArabicTextHelper.normalizeLetters(textWithDigits);

    final prescriptionStopWords = {
      'اكتب', 'دواء', 'ادوية', 'علاج', 'روشتة', 'قالب',
      'قرص', 'اقراص', 'أقراص', 'كبسول', 'كبسولات', 'حقنة', 'حقن', 'شراب', 'نقط',
      'مرة', 'مرتين', 'مرات', 'مراتين', 'يوم', 'يوما', 'يومي', 'يوميا', 'ايام', 'أيام',
      'اسبوع', 'أسبوع', 'اسبوعين', 'أسبوعين', 'اسابيع', 'أسابيع', 'شهر',
      'قبل', 'بعد', 'مع', 'اثناء', 'أثناء', 'وسط', 'خلال',
      'الاكل', 'الأكل', 'اكل', 'أكل', 'طعام', 'وجبة', 'وجبات', 'الافطار', 'الغداء', 'العشاء',
      'الاستشارة', 'الاستشاره', 'المتابعة', 'المتابعه', 'إعادة', 'اعاده', 'كشف',
      'ملاحظات', 'ملاحظة', 'تعليمات', 'نصائح', 'الراحة',
      'عند', 'اللزوم', 'الحاجة', 'فقط', 'لمدة', 'في', 'من', 'الي', 'إلى', 'كل', 'و',
      'سليم', 'تماما', 'بخير',
      // English
      'write', 'prescribe', 'give', 'take', 'drug', 'drugs', 'medication', 'medicine',
      'tablet', 'tablets', 'pill', 'pills', 'capsule', 'capsules', 'injection', 'syrup', 'drops',
      'once', 'twice', 'thrice', 'times', 'time', 'day', 'daily', 'days',
      'week', 'weeks', 'month', 'months',
      'before', 'after', 'with', 'during', 'meal', 'meals', 'food',
      'follow', 'up', 'visit', 'consultation', 'notes', 'note',
      'prn', 'needed', 'as', 'for', 'every', 'in', 'and', 'the', 'to',
    }.map(ArabicTextHelper.normalizeLetters).toSet();

    final List<_DrugMatchLocation> locations = [];

    if (drugsDb.isNotEmpty) {
      for (final drugItem in drugsDb) {
        final tradeName = _getDrugTradeName(drugItem);
        final genericName = _getDrugGenericName(drugItem);
        final drugId = _getDrugId(drugItem);
        final category = _getDrugCategory(drugItem);

        if (tradeName.isEmpty && genericName.isEmpty) continue;

        final tradeTokens = tradeName.split(RegExp(r'\s+')).where((t) => t.length > 2).toList();
        final primaryTrade = tradeTokens.isNotEmpty ? tradeTokens.first : tradeName;

        int matchIndex = -1;
        int matchLength = 0;

        // 1. فحص ظهور الاسم التجاري المباشر (مثل: أوجمنتين أو Augmentin)
        final normPrimary = ArabicTextHelper.normalizeLetters(primaryTrade);
        if (normPrimary.length >= 3 && normText.contains(normPrimary)) {
          matchIndex = normText.indexOf(normPrimary);
          matchLength = normPrimary.length;
        }

        // 2. فحص الاسم العلمي المباشر
        if (matchIndex == -1 && genericName.isNotEmpty) {
          final genericTokens = genericName.split(RegExp(r'\s+')).where((t) => t.length > 3).toList();
          for (final gt in genericTokens) {
            final normG = ArabicTextHelper.normalizeLetters(gt);
            if (normText.contains(normG)) {
              matchIndex = normText.indexOf(normG);
              matchLength = normG.length;
              break;
            }
          }
        }

        // 3. مطابقة صوتية عابرة للغات (Arabic <-> English Phonetic Matching) للكلمة المفردة أو المركبة
        if (matchIndex == -1) {
          final wordsInText = textWithDigits.split(RegExp(r'\s+'));
          for (int wi = 0; wi < wordsInText.length; wi++) {
            final rawW1 = wordsInText[wi].replaceAll(RegExp(r'[,.\-_:;!؟?]'), '').trim();
            final normW1 = ArabicTextHelper.normalizeLetters(rawW1);

            // تخطي الكلمات الشائعة وقواعد الروشتة
            if (prescriptionStopWords.contains(normW1)) continue;

            final rawW2 = (wi + 1 < wordsInText.length)
                ? '$rawW1 ${wordsInText[wi + 1].replaceAll(RegExp(r'[,.\-_:;!؟?]'), '').trim()}'
                : '';

            bool isMatch = false;
            String matchedSegment = '';

            if (rawW2.isNotEmpty &&
                (ArabicTextHelper.isSameOrMatchingName(tradeName, rawW2) ||
                 ArabicTextHelper.isSameOrMatchingName(primaryTrade, rawW2))) {
              isMatch = true;
              matchedSegment = '${wordsInText[wi]} ${wordsInText[wi + 1]}';
            } else if (rawW1.length >= 3 &&
                (ArabicTextHelper.isSameOrMatchingName(primaryTrade, rawW1) ||
                 (tradeName.length >= 3 && ArabicTextHelper.isSameOrMatchingName(tradeName, rawW1)) ||
                 (genericName.isNotEmpty && ArabicTextHelper.isSameOrMatchingName(genericName, rawW1)))) {
              isMatch = true;
              matchedSegment = wordsInText[wi];
            }

            if (isMatch) {
              final pos = textWithDigits.indexOf(matchedSegment);
              if (pos != -1) {
                matchIndex = pos;
                matchLength = matchedSegment.length;
                break;
              }
            }
          }
        }

        if (matchIndex != -1) {
          locations.add(_DrugMatchLocation(
            drugId: drugId,
            tradeName: tradeName,
            genericName: genericName,
            category: category,
            startIndex: matchIndex,
            length: matchLength,
          ));
        }
      }
    }

    final uniqueLocations = <_DrugMatchLocation>[];
    for (final loc in locations) {
      if (!uniqueLocations.any((u) => u.drugId == loc.drugId)) {
        uniqueLocations.add(loc);
      }
    }

    uniqueLocations.sort((a, b) => a.startIndex.compareTo(b.startIndex));

    for (int i = 0; i < uniqueLocations.length; i++) {
      final cur = uniqueLocations[i];
      final doseStartIndex = cur.startIndex + cur.length;
      final doseEndIndex = (i + 1 < uniqueLocations.length)
          ? uniqueLocations[i + 1].startIndex
          : textWithDigits.length;

      final doseContext = (doseStartIndex <= doseEndIndex && doseStartIndex < textWithDigits.length)
          ? textWithDigits.substring(doseStartIndex, doseEndIndex)
          : '';

      final parsedDose = _parseDoseContext(doseContext);

      matchedDrugs.add({
        'id': cur.drugId,
        'tradeName': cur.tradeName,
        'genericName': cur.genericName,
        'category': cur.category,
        'doseFrequency': parsedDose.frequency,
        'doseDuration': parsedDose.duration,
        'doseTiming': parsedDose.timing,
        'isPrn': parsedDose.isPrn,
      });
    }

    // في حال عدم وجود قاعدة أدوية، نقوم باستخراج اسم الدواء والجرعة كخطة احتياطية
    if (matchedDrugs.isEmpty) {
      final fallbackRegex = RegExp(
        r'(?:اكتب|دواء|علاج|خذ|ضع|write|rx:?)\s+([^\n,،]+)',
        caseSensitive: false,
      );
      final matches = fallbackRegex.allMatches(textWithDigits);
      for (final m in matches) {
        final rawCandidate = m.group(1)?.trim() ?? '';
        if (rawCandidate.isNotEmpty) {
          final tokens = rawCandidate.split(RegExp(r'\s+'));
          final drugNameTokens = <String>[];
          for (final t in tokens) {
            final norm = ArabicTextHelper.normalizeLetters(t);
            if (norm.contains('مرت') ||
                norm.contains('يومي') ||
                norm.contains('بعد') ||
                norm.contains('قبل') ||
                norm.contains('لمد') ||
                norm.contains('اسبوع') ||
                norm.contains('شهر') ||
                norm.contains('ايام') ||
                norm.contains('لزوم') ||
                norm.contains('daily') ||
                norm.contains('times') ||
                norm.contains('meal') ||
                norm.contains('days')) {
              break;
            }
            drugNameTokens.add(t);
          }
          if (drugNameTokens.isNotEmpty) {
            final candidateName = drugNameTokens.take(3).join(' ');
            final doseSub = rawCandidate.substring(rawCandidate.indexOf(candidateName) + candidateName.length);
            final parsedDose = _parseDoseContext(doseSub);
            matchedDrugs.add({
              'id': '',
              'tradeName': candidateName,
              'genericName': '',
              'category': '',
              'doseFrequency': parsedDose.frequency,
              'doseDuration': parsedDose.duration,
              'doseTiming': parsedDose.timing,
              'isPrn': parsedDose.isPrn,
            });
          }
        }
      }
    }

    return matchedDrugs;
  }

  _ParsedDose _parseDoseContext(String context) {
    final norm = ArabicTextHelper.normalizeLetters(context);

    // عند اللزوم (PRN)
    final isPrn = norm.contains('لزوم') ||
        norm.contains('حاجه') ||
        norm.contains('حاجة') ||
        norm.contains('الم') ||
        norm.contains('ألم') ||
        norm.contains('prn') ||
        norm.contains('needed');

    // التكرار (Frequency)
    int? frequency;
    if (isPrn) {
      frequency = null;
    } else if (norm.contains('مرة يوميا') ||
        norm.contains('مره يوميا') ||
        norm.contains('مرة في اليوم') ||
        norm.contains('مره في اليوم') ||
        norm.contains('مرة باليوم') ||
        norm.contains('مره باليوم') ||
        norm.contains('قرص يوميا') ||
        norm.contains('كل 24 ساعه') ||
        norm.contains('once daily') ||
        norm.contains('once a day')) {
      frequency = 1;
    } else if (norm.contains('مرتين يوميا') ||
        norm.contains('مرتين في اليوم') ||
        norm.contains('مرتين باليوم') ||
        norm.contains('مرتين') ||
        norm.contains('كل 12 ساعه') ||
        norm.contains('twice daily') ||
        norm.contains('twice a day')) {
      frequency = 2;
    } else if (norm.contains('3 مرات') ||
        norm.contains('تلات مرات') ||
        norm.contains('ثلاث مرات') ||
        norm.contains('ثلاثه مرات') ||
        norm.contains('كل 8 ساعات') ||
        norm.contains('thrice daily') ||
        norm.contains('three times')) {
      frequency = 3;
    } else if (norm.contains('4 مرات') ||
        norm.contains('اربع مرات') ||
        norm.contains('أربع مرات') ||
        norm.contains('كل 6 ساعات') ||
        norm.contains('four times')) {
      frequency = 4;
    } else {
      frequency = isPrn ? null : 2;
    }

    // التوقيت (Timing)
    String timing = 'after_meal';
    if (norm.contains('قبل الاكل') ||
        norm.contains('قبل الوجبات') ||
        norm.contains('قبل الفطار') ||
        norm.contains('على الريق') ||
        norm.contains('before meal') ||
        norm.contains('before meals')) {
      timing = 'before_meal';
    } else if (norm.contains('مع الاكل') ||
        norm.contains('وسط الاكل') ||
        norm.contains('اثناء الاكل') ||
        norm.contains('with meal') ||
        norm.contains('with meals')) {
      timing = 'throught_meal';
    } else if (norm.contains('في اي وقت') ||
        norm.contains('بدون طعام') ||
        norm.contains('any time')) {
      timing = 'any_time';
    } else if (norm.contains('بعد الاكل') ||
        norm.contains('بعد الوجبات') ||
        norm.contains('after meal') ||
        norm.contains('after meals')) {
      timing = 'after_meal';
    }

    // المدة (Duration)
    int? duration;
    if (isPrn) {
      duration = null;
    } else if (norm.contains('مستمر') ||
        norm.contains('علاج مستمر') ||
        norm.contains('على طول') ||
        norm.contains('continuous')) {
      duration = 0;
    } else if (norm.contains('3 ايام') ||
        norm.contains('تلات ايام') ||
        norm.contains('ثلاثة ايام') ||
        norm.contains('3 days')) {
      duration = 3;
    } else if (norm.contains('اسبوعين') ||
        norm.contains('أسبوعين') ||
        norm.contains('14 يوم') ||
        norm.contains('two weeks') ||
        norm.contains('14 days')) {
      duration = 14;
    } else if (norm.contains('شهر') ||
        norm.contains('30 يوم') ||
        norm.contains('one month') ||
        norm.contains('30 days')) {
      duration = 30;
    } else if (norm.contains('10 ايام') ||
        norm.contains('عشرة ايام') ||
        norm.contains('10 days')) {
      duration = 10;
    } else if (norm.contains('اسبوع') ||
        norm.contains('أسبوع') ||
        norm.contains('7 ايام') ||
        norm.contains('one week') ||
        norm.contains('7 days')) {
      duration = 7;
    } else {
      final customMatch = RegExp(r'(\d+)\s*(?:ايام|أيام|يوم|days?)').firstMatch(norm);
      if (customMatch != null) {
        duration = int.tryParse(customMatch.group(1)!);
      } else {
        duration = isPrn ? null : 7;
      }
    }

    return _ParsedDose(
      frequency: frequency,
      duration: duration,
      timing: timing,
      isPrn: isPrn,
    );
  }

  String _getDrugTradeName(dynamic d) {
    if (d is Map) return (d['trade_name'] ?? d['tradeName'] ?? d['name'] ?? '').toString();
    try { return (d.tradeName ?? '').toString(); } catch (_) { return ''; }
  }

  String _getDrugGenericName(dynamic d) {
    if (d is Map) return (d['generic_name'] ?? d['genericName'] ?? '').toString();
    try { return (d.genericName ?? '').toString(); } catch (_) { return ''; }
  }

  String _getDrugId(dynamic d) {
    if (d is Map) return (d['id'] ?? '').toString();
    try { return (d.id ?? '').toString(); } catch (_) { return ''; }
  }

  String _getDrugCategory(dynamic d) {
    if (d is Map) return (d['category'] ?? '').toString();
    try { return (d.category ?? '').toString(); } catch (_) { return ''; }
  }

  String _getTemplateName(dynamic t) {
    if (t is Map) return (t['name'] ?? '').toString();
    try { return (t.name ?? '').toString(); } catch (_) { return ''; }
  }

  String _getTemplateId(dynamic t) {
    if (t is Map) return (t['id'] ?? '').toString();
    try { return (t.id ?? '').toString(); } catch (_) { return ''; }
  }
}

class _DrugMatchLocation {
  final String drugId;
  final String tradeName;
  final String genericName;
  final String category;
  final int startIndex;
  final int length;

  _DrugMatchLocation({
    required this.drugId,
    required this.tradeName,
    required this.genericName,
    required this.category,
    required this.startIndex,
    required this.length,
  });
}

class _ParsedDose {
  final int? frequency;
  final int? duration;
  final String? timing;
  final bool isPrn;

  _ParsedDose({
    this.frequency,
    this.duration,
    this.timing,
    this.isPrn = false,
  });
}

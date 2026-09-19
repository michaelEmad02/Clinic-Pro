// ────────────────────────────────────────────────────────
// ArabicTextHelper — أداة مساعدة مشتركة لمعالجة وتنظيف النصوص العربية
// تُستخدم عبر مختلف خدمات التطبيق لمعالجة النصوص المستخرجة صوتياً
// ────────────────────────────────────────────────────────

class ArabicTextHelper {
  ArabicTextHelper._();

  /// تحويل الأرقام المشرقية/الهندية إلى أرقام عربية قياسية (Latin digits)
  static String normalizeNumerals(String input) {
    const arabicIndic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    const standard = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];

    var res = input;
    for (int i = 0; i < arabicIndic.length; i++) {
      res = res.replaceAll(arabicIndic[i], standard[i]);
    }
    return res;
  }

  /// تطبيع الحروف العربية (إزالة التشكيل وتوحيد الألف والياء والتاء المربوطة)
  static String normalizeLetters(String text) {
    var res = text.toLowerCase();
    // إزالة التشكيل والتنوين
    res = res.replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), '');
    // توحيد الألف بكافة أشكالها
    res = res.replaceAll(RegExp(r'[أإآٱ]'), 'ا');
    // توحيد التاء المربوطة والهاء
    res = res.replaceAll('ة', 'ه');
    // توحيد الألف المقصورة والياء
    res = res.replaceAll('ى', 'ي');
    return res.trim();
  }

  /// تنظيف علامات الترقيم والمسافات الزائدة
  static String cleanPunctuation(String input) {
    return input
        .replaceAll(RegExp(r'[,.\-_:;!؟?()\[\]{}"\\]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// فحص هل يحتوي النص على حروف عربية
  static bool hasArabicCharacters(String text) {
    return RegExp(r'[\u0600-\u06FF]').hasMatch(text);
  }

  /// تحويل كلمة من الاسم (سواء مكتوبة بالعربية أو الإنجليزية) إلى مفتاح صوتي موحد
  static String toPhoneticToken(String rawToken) {
    var token = rawToken.trim().toLowerCase();
    if (token.isEmpty) return '';

    // إذا كانت الكلمة بالعربية نقوم بنقلها صوتياً للحروف اللاتينية (Transliteration)
    if (hasArabicCharacters(token)) {
      token = normalizeLetters(token);

      const arabicToLatin = {
        'أ': 'a', 'إ': 'a', 'آ': 'a', 'ا': 'a', 'ء': 'a', 'ع': 'a',
        'ب': 'b', 'پ': 'b',
        'ت': 't', 'ط': 't', 'ة': '',
        'ث': 's',
        'ج': 'g',
        'ح': 'h', 'ه': 'h',
        'خ': 'h',
        'د': 'd', 'ض': 'd',
        'ذ': 'z', 'ز': 'z', 'ظ': 'z',
        'ر': 'r',
        'س': 's', 'ص': 's',
        'ش': 's',
        'ف': 'f',
        'ق': 'k', 'ك': 'k',
        'ل': 'l',
        'م': 'm',
        'ن': 'n',
        'و': 'w',
        'ي': 'y', 'ى': 'y',
      };

      final sb = StringBuffer();
      for (int i = 0; i < token.length; i++) {
        final c = token[i];
        if (arabicToLatin.containsKey(c)) {
          sb.write(arabicToLatin[c]);
        } else if (RegExp(r'[a-z0-9]').hasMatch(c)) {
          sb.write(c);
        }
      }
      token = sb.toString();
    }

    // تنظيف المجموعات الصوتية اللاتينية للتقريب بين النطق الإنجليزي والمعرّب
    token = token
        .replaceAll('ph', 'f')
        .replaceAll('kh', 'h')
        .replaceAll('gh', 'g')
        .replaceAll('sh', 's')
        .replaceAll('ch', 'k')
        .replaceAll('th', 't')
        .replaceAll('ck', 'k')
        .replaceAll('c', 'k')
        .replaceAll('q', 'k')
        .replaceAll('x', 'ks')
        .replaceAll('j', 'g')
        .replaceAll('p', 'b')
        .replaceAll('v', 'f');

    // إزالة تكرار الحروف المتجاورة (مثل: mm -> m, dd -> d, ee -> e, oo -> o)
    final sbSquashed = StringBuffer();
    String last = '';
    for (int i = 0; i < token.length; i++) {
      final c = token[i];
      if (c != last) {
        sbSquashed.write(c);
        last = c;
      }
    }
    token = sbSquashed.toString();

    // إزالة الحرف الصامت الأخير مثل h أو e في نهاية الأسماء (مثل: Sarah -> Sara, George -> Georg)
    token = token.replaceAll(RegExp(r'[he]$'), '');

    if (token.isEmpty) return '';
    var firstChar = token[0];
    if (RegExp(r'[aeiou]').hasMatch(firstChar)) {
      firstChar = 'a';
    }
    final rest = token.substring(1);

    // إزالة الحروف الصوتية وشبه الصوتية (w, y) من بقية الكلمة للحصول على الهيكل الصوتي المشترك
    final skeletonRest = rest.replaceAll(RegExp(r'[aeiouwy]'), '');

    return '$firstChar$skeletonRest';
  }

  /// مقارنة ومطابقة اسمين بدقة حتى لو كان أحدهما بالعربية والآخر بالإنجليزية
  static bool isSameOrMatchingName(String name1, String name2) {
    final clean1 = cleanPunctuation(name1).trim();
    final clean2 = cleanPunctuation(name2).trim();
    if (clean1.isEmpty || clean2.isEmpty) return false;

    // 1. تطابق مباشر أو بتطبيع الحروف الأساسي
    final norm1 = normalizeLetters(clean1);
    final norm2 = normalizeLetters(clean2);
    if (norm1 == norm2 || norm1.contains(norm2) || norm2.contains(norm1)) {
      return true;
    }

    // 2. مطابقة الرموز الصوتية للكلمات (Token-based phonetic matching)
    final tokens1 = clean1
        .split(RegExp(r'\s+'))
        .map(toPhoneticToken)
        .where((t) => t.isNotEmpty)
        .toList();
    final tokens2 = clean2
        .split(RegExp(r'\s+'))
        .map(toPhoneticToken)
        .where((t) => t.isNotEmpty)
        .toList();

    if (tokens1.isEmpty || tokens2.isEmpty) return false;

    final strKey1 = tokens1.join(' ');
    final strKey2 = tokens2.join(' ');
    if (strKey1 == strKey2 || strKey1.contains(strKey2) || strKey2.contains(strKey1)) {
      return true;
    }

    final shorter = tokens1.length <= tokens2.length ? tokens1 : tokens2;
    final longer = tokens1.length <= tokens2.length ? tokens2 : tokens1;

    int matchedCount = 0;
    for (final s in shorter) {
      if (longer.any((l) => l == s || (s.length >= 3 && (l.startsWith(s) || s.startsWith(l))))) {
        matchedCount++;
      }
    }

    return matchedCount >= shorter.length;
  }

  /// استخراج أول قيمة عددية (صحيحة أو عشرية) من النص
  static double? extractFirstNumber(String text) {
    final normalized = normalizeNumerals(text);
    final regex = RegExp(r'(\d+(?:\.\d+)?)');
    final match = regex.firstMatch(normalized);
    if (match != null) {
      return double.tryParse(match.group(1) ?? '');
    }
    return null;
  }

  /// تحويل الكلمات المنطوقة للأرقام (مثل: زيرو، واحد، اتنين، تلاتة...) إلى أرقام
  static String convertSpokenNumberWordsToDigits(String text) {
    var res = text;
    // الحالات المركبة الشائعة في نطق الهواتف
    res = res.replaceAll(RegExp(r'(?:زيرو|صفر)\s*(?:عشرة|عشره)'), ' 010 ');
    res = res.replaceAll(RegExp(r'(?:زيرو|صفر)\s*(?:مية|ميه|مائة)'), ' 0100 ');
    res = res.replaceAll(RegExp(r'(?:زيرو|صفر)\s*(?:خمسة|خمسه)'), ' 05 ');

    final wordToDigit = {
      'زيرو': '0',
      'صفر': '0',
      'واحد': '1',
      'اثنين': '2',
      'اتنين': '2',
      'ثلاثة': '3',
      'تلاتة': '3',
      'ثلاثه': '3',
      'تلاته': '3',
      'اربعة': '4',
      'أربعة': '4',
      'اربعه': '4',
      'أربعه': '4',
      'خمسة': '5',
      'خمسه': '5',
      'ستة': '6',
      'سته': '6',
      'سبعة': '7',
      'سبعه': '7',
      'ثمانية': '8',
      'ثمانيه': '8',
      'تمانية': '8',
      'تمانيه': '8',
      'تسعة': '9',
      'تسعه': '9',
    };

    final tokens = res.split(RegExp(r'\s+'));
    final converted = tokens.map((t) {
      final clean = t.replaceAll(RegExp(r'[,.\-_:;!؟?]'), '');
      final digit = wordToDigit[clean];
      return digit ?? t;
    });

    return converted.join(' ').trim();
  }

  /// استخراج رقم هاتف من النص (أرقام متتالية من 9 إلى 11 خانة)
  static String? extractPhoneNumber(String text) {
    final result = extractPhoneWithContext(text);
    return result?.phone;
  }

  /// استخراج رقم الهاتف مع السياق المصاحب لإزالته بدقة من النص
  static PhoneExtractionResult? extractPhoneWithContext(String text) {
    var working = normalizeNumerals(text);

    // 1. تحويل الكلمات المنطوقة للأرقام
    final spokenConverted = convertSpokenNumberWordsToDigits(working);

    // 2. البحث بنمط مسبوق بكلمة دالة: تليفونه / هاتفه / جواله / رقمه / رقم التليفون
    final prefixedRegex = RegExp(
      r'(?:(?:صاحب(?:ة)?\s+(?:ال)?)?(?:[ل|ب]?رقم\s+(?:تليفون[ه|ها]?|هاتف[ه|ها]?|جوال[ه|ها]?|موبايل[ه|ها]?)|[ل|ب]?تليفون[ه|ها]?|[ل|ب]?هاتف[ه|ها]?|[ل|ب]?جوال[ه|ها]?|[ل|ب]?موبايل[ه|ها]?|[ل|ب]?رقم[ه|ها]?))\s*[:=\-]?\s*(\+?[\d\s\-]{8,40})',
      caseSensitive: false,
    );

    // نجرب أولاً مع النص المحول من الكلمات المنطوقة
    var prefixMatch = prefixedRegex.firstMatch(spokenConverted);
    if (prefixMatch != null) {
      final rawDigits = prefixMatch.group(1)!.replaceAll(RegExp(r'[\s\-]+'), '');
      if (rawDigits.length >= 9 && rawDigits.length <= 15) {
        final origMatch = prefixedRegex.firstMatch(working);
        return PhoneExtractionResult(
          phone: rawDigits,
          matchedText: origMatch?.group(0) ?? prefixMatch.group(0)!,
        );
      }
    }

    // نجرب مع النص الرقمي المباشر
    prefixMatch = prefixedRegex.firstMatch(working);
    if (prefixMatch != null) {
      final rawDigits = prefixMatch.group(1)!.replaceAll(RegExp(r'[\s\-]+'), '');
      if (rawDigits.length >= 9 && rawDigits.length <= 15) {
        return PhoneExtractionResult(
          phone: rawDigits,
          matchedText: prefixMatch.group(0)!,
        );
      }
    }

    // 3. البحث عن أرقام هواتف مصرية أو سعودية أو عامة (بمسافات أو بدون)
    for (final textToSearch in [spokenConverted, working]) {
      // أ) أرقام مصرية (تبدأ بـ 010 أو 011 أو 012 أو 015 أو كود مصر +20)
      final egyptSpacedRegex = RegExp(
        r'(?:(?:\+20|0020|20)\s*)?(0\s*1\s*[0125](?:\s*\d){8})(?!\d)',
      );
      final egMatch = egyptSpacedRegex.firstMatch(textToSearch);
      if (egMatch != null) {
        final digits = egMatch.group(1)!.replaceAll(RegExp(r'\s+'), '');
        return PhoneExtractionResult(
          phone: digits,
          matchedText: egMatch.group(0)!,
        );
      }

      // ب) أرقام سعودية (تبدأ بـ 05 أو كود السعودية +966)
      final saudiSpacedRegex = RegExp(
        r'(?:(?:\+966|00966|966)\s*)?(0\s*5(?:\s*\d){8})(?!\d)',
      );
      final saMatch = saudiSpacedRegex.firstMatch(textToSearch);
      if (saMatch != null) {
        final digits = saMatch.group(1)!.replaceAll(RegExp(r'\s+'), '');
        return PhoneExtractionResult(
          phone: digits,
          matchedText: saMatch.group(0)!,
        );
      }

      // ج) رقم هاتف عام يبدأ بصفر ومكون من 10 أو 11 رقم
      final generalSpacedRegex = RegExp(
        r'(?:^|[^\d])(0\s*\d(?:\s*\d){8,10})(?!\d)',
      );
      final genMatch = generalSpacedRegex.firstMatch(textToSearch);
      if (genMatch != null) {
        final digits = genMatch.group(1)!.replaceAll(RegExp(r'\s+'), '');
        return PhoneExtractionResult(
          phone: digits,
          matchedText: genMatch.group(1)!,
        );
      }
    }

    return null;
  }

  /// استخراج فصيلة الدم والنص المطابق لها لإزالته من النص بدقة متناهية دون ابتلاع باقي الجمل
  static BloodTypeExtractionResult? extractBloodType(String text) {
    // 1. تنظيف الشرطات وتوحيدها
    final clean = text
        .replaceAll('–', '-')
        .replaceAll('—', '-')
        .replaceAll('−', '-')
        .replaceAll('ـ', '-');

    // بادئة اختيارية مسبوقة بكلمة فصيلة دمه / فصيلة الدم / فصيلته / زمرة الدم...
    const prefix = r'(?:(?:فصيل[ةه]\s+(?:دم[ه|ها]?|الدم)|فصيلت[ه|ها]|فصيل[ةه]|زمر[ةه]\s+(?:دم[ه|ها]?|الدم)|جروب\s+دم[ه|ها]?|نوع\s+دم[ه|ها]?)\s*[:=\-]?\s*)?';

    // علامات الإشارة (+ أو -) بكل الصيغ المنطوقة
    const posSign = r'(?:\+|plus|positive|موجب[ةه]?|بوزتيف|بوزيتيف|بوستيف|بلس)';
    const negSign = r'(?:\-|minus|negative|سالب[ةه]?|نيجاتيف|نيجاتف|ماينس|ماينص|ناقص)';

    // مجموعات الفصائل (يتم فحص AB أولاً قبل A و B)
    final groups = [
      (letter: 'AB', pattern: r'(?:ab|اي\s*بي|ايه\s*بي|أيه\s*بي|أي\s*بي)'),
      (letter: 'B', pattern: r'(?:b|بي)'),
      (letter: 'O', pattern: r'(?:o|او|أو|صفر)'),
      (letter: 'A', pattern: r'(?:a|ايه|اي|أيه|أي|أ|ا)'),
    ];

    for (final g in groups) {
      // 1. نمط موجب: الحرف ثم الموجب أو العكس
      final posRegex = RegExp(
        '$prefix(?:${g.pattern}\\s*$posSign|$posSign\\s*${g.pattern})',
        caseSensitive: false,
      );
      final posMatch = posRegex.firstMatch(clean);
      if (posMatch != null) {
        return BloodTypeExtractionResult(
          bloodType: '${g.letter}+',
          matchedText: posMatch.group(0)!,
        );
      }

      // 2. نمط سالب: الحرف ثم السالب أو العكس
      final negRegex = RegExp(
        '$prefix(?:${g.pattern}\\s*$negSign|$negSign\\s*${g.pattern})',
        caseSensitive: false,
      );
      final negMatch = negRegex.firstMatch(clean);
      if (negMatch != null) {
        return BloodTypeExtractionResult(
          bloodType: '${g.letter}-',
          matchedText: negMatch.group(0)!,
        );
      }
    }

    return null;
  }

  /// استخراج الجنس من النص إن وجد
  static String? extractGender(String text) {
    final normalized = normalizeLetters(text);
    // مؤشرات الإناث
    if (normalized.contains('مريضه') ||
        normalized.contains('اسمها') ||
        normalized.contains('عمرها') ||
        normalized.contains('تليفونها') ||
        normalized.contains('هاتفها') ||
        normalized.contains('دمها') ||
        normalized.contains('عندها') ||
        normalized.contains('انثي') ||
        normalized.contains('انثى') ||
        normalized.contains('سيده') ||
        normalized.contains('بنت') ||
        normalized.contains('مدام') ||
        normalized.contains('انسه')) {
      return 'female';
    }
    // مؤشرات الذكور
    if (normalized.contains('مريض') ||
        normalized.contains('اسمه') ||
        normalized.contains('عمره') ||
        normalized.contains('تليفونه') ||
        normalized.contains('هاتفه') ||
        normalized.contains('دمه') ||
        normalized.contains('عنده') ||
        normalized.contains('ذكر') ||
        normalized.contains('رجل') ||
        normalized.contains('ولد') ||
        normalized.contains('استاذ')) {
      return 'male';
    }
    return null;
  }

  /// إزالة كلمات معينة من بداية ونهاية النص
  static String stripTokensFromEdges(String text, List<String> tokens) {
    final words = text.split(RegExp(r'\s+')).where((w) => w.trim().isNotEmpty).toList();
    while (words.isNotEmpty && tokens.contains(words.first)) {
      words.removeAt(0);
    }
    while (words.isNotEmpty && tokens.contains(words.last)) {
      words.removeLast();
    }
    return words.join(' ').trim();
  }
}

/// نتيجة استخراج فصيلة الدم متضمنة النص المطابق لإزالته
class BloodTypeExtractionResult {
  final String bloodType;
  final String matchedText;

  const BloodTypeExtractionResult({
    required this.bloodType,
    required this.matchedText,
  });
}

/// نتيجة استخراج رقم الهاتف متضمنة النص المطابق لإزالته
class PhoneExtractionResult {
  final String phone;
  final String matchedText;

  const PhoneExtractionResult({
    required this.phone,
    required this.matchedText,
  });
}


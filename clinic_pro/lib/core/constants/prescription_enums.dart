// ────────────────────────────────────────────────────────
// ثوابت الوصفات الطبية — التكرار والمدة والتوقيت
// تُستخدم لتحويل القيم المخزنة في قاعدة البيانات إلى نصوص عربية والعكس
// مبنية بنفس نمط StaffRoles
// ────────────────────────────────────────────────────────

import '../strings/app_strings.dart';

/// تكرار الجرعة — يُحفظ في الـ DB كـ smallint (1-4)
enum DrugFrequency {
  once(1),
  twice(2),
  thrice(3),
  four(4),
  onDemand(0);

  final int dbValue;
  const DrugFrequency(this.dbValue);

  /// النص المعروض حسب اللغة في Chips
  String get label {
    switch (this) {
      case DrugFrequency.once:
        return AppStrings.frequencyOnce;
      case DrugFrequency.twice:
        return AppStrings.frequencyTwice;
      case DrugFrequency.thrice:
        return AppStrings.frequencyThrice;
      case DrugFrequency.four:
        return AppStrings.frequencyFour;
      case DrugFrequency.onDemand:
        return AppStrings.frequencyOnDemand;
    }
  }

  /// النص المختصر للعرض في Chips
  String get chipLabel {
    switch (this) {
      case DrugFrequency.once:
        return '1×';
      case DrugFrequency.twice:
        return '2×';
      case DrugFrequency.thrice:
        return '3×';
      case DrugFrequency.four:
        return '4×';
      case DrugFrequency.onDemand:
        return AppStrings.frequencyOnDemand;
    }
  }

  /// تحويل من قيمة الـ DB إلى enum
  static DrugFrequency? fromDbValue(int? value) {
    if (value == null) return null;
    return DrugFrequency.values.where((e) => e.dbValue == value).firstOrNull;
  }
}

/// مدة العلاج — يُحفظ في الـ DB كـ integer (عدد أيام)
enum DrugDuration {
  threeDays(3),
  sevenDays(7),
  tenDays(10),
  fourteenDays(14),
  thirtyDays(30),
  continuing(0);

  final int dbValue;
  const DrugDuration(this.dbValue);

  /// النص المعروض حسب اللغة في Chips
  String get label {
    switch (this) {
      case DrugDuration.threeDays:
        return AppStrings.durationThreeDays;
      case DrugDuration.sevenDays:
        return AppStrings.durationSevenDays;
      case DrugDuration.tenDays:
        return AppStrings.durationTenDays;
      case DrugDuration.fourteenDays:
        return AppStrings.durationFourteenDays;
      case DrugDuration.thirtyDays:
        return AppStrings.durationThirtyDays;
      case DrugDuration.continuing:
        return AppStrings.durationContinuing;
    }
  }

  /// النص المختصر للعرض في Chips
  String get chipLabel {
    switch (this) {
      case DrugDuration.threeDays:
        return '3d';
      case DrugDuration.sevenDays:
        return '7d';
      case DrugDuration.tenDays:
        return '10d';
      case DrugDuration.fourteenDays:
        return '14d';
      case DrugDuration.thirtyDays:
        return '30d';
      case DrugDuration.continuing:
        return AppStrings.durationContinuing;
    }
  }

  /// تحويل من قيمة الـ DB (عدد أيام) إلى enum
  static DrugDuration? fromDbValue(int? value) {
    if (value == null) return null;
    return DrugDuration.values.where((e) => e.dbValue == value).firstOrNull;
  }
}

/// توقيت تناول الدواء — يُحفظ في الـ DB كـ drug_timing enum
/// ⚠️ القيمة 'throught_meal' خطأ إملائي في الـ DB — يجب استخدامها كما هي
enum DrugTiming {
  beforeMeal('before_meal'),
  afterMeal('after_meal'),
  throughMeal('throught_meal'),
  anyTime('any_time'); // ⚠️ typo في الـ DB — يجب مطابقته تماماً

  final String dbValue;
  const DrugTiming(this.dbValue);

  /// النص المعروض حسب اللغة في Chips
  String get label {
    switch (this) {
      case DrugTiming.beforeMeal:
        return AppStrings.timingBeforeMeal;
      case DrugTiming.afterMeal:
        return AppStrings.timingAfterMeal;
      case DrugTiming.throughMeal:
        return AppStrings.timingWithMeal;
      case DrugTiming.anyTime:
        return AppStrings.timingAnyTime;
    }
  }

  /// تحويل من قيمة الـ DB إلى enum
  static DrugTiming? fromDbValue(String? value) {
    if (value == null) return null;
    return DrugTiming.values.where((e) => e.dbValue == value).firstOrNull;
  }
}

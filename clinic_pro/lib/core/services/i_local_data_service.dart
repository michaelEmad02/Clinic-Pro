// ────────────────────────────────────────────────────────
// واجهة خدمة التخزين المحلي (ILocalDataService Interface)
// تفصل بين منطق التطبيق (DataSources) ومكتبة SharedPreferences
// ────────────────────────────────────────────────────────

abstract class ILocalDataService {
  /// جلب نص مخزن مفتاحه [key]
  Future<String?> getString(String key);

  /// حفظ نص بـ [key] و [value]
  Future<void> setString(String key, String value);

  /// جلب رقم صحيح مخزن بـ [key]
  Future<int?> getInt(String key);

  /// حفظ رقم صحيح بـ [key] و [value]
  Future<void> setInt(String key, int value);

  /// جلب قيمة بولينية بـ [key]
  Future<bool?> getBool(String key);

  /// حفظ قيمة بولينية بـ [key] و [value]
  Future<void> setBool(String key, bool value);

  /// حذف القيمة المخزنة بـ [key]
  Future<void> remove(String key);

  /// مسح جميع البيانات المخزنة محلياً
  Future<void> clear();
}

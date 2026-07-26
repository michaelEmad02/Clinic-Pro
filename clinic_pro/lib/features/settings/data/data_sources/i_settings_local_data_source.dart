// ────────────────────────────────────────────────────────
// واجهة مصدر البيانات المحلي للإعدادات (ISettingsLocalDataSource)
// تدعم ربط المفاتيح بـ userId المستخدم لمنع اختلاط الجلسات
// ────────────────────────────────────────────────────────

abstract class ISettingsLocalDataSource {
  /// جلب معرف العيادة النشطة المخزنة محلياً لمستخدم معين
  Future<String?> getActiveClinicId(String userId);

  /// حفظ معرف العيادة النشطة محلياً لمستخدم معين
  Future<void> saveActiveClinicId(String userId, String clinicId);

  /// جلب معرف الطبيب النشط المخزن محلياً لمستخدم معين
  Future<String?> getActiveDoctorId(String userId);

  /// حفظ معرف الطبيب النشط محلياً لمستخدم معين
  Future<void> saveActiveDoctorId(String userId, String doctorId);

  /// مسح البيانات المحفوظة محلياً لمستخدم معين
  Future<void> clearSettings(String userId);
}

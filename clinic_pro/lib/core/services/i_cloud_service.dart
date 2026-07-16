// ────────────────────────────────────────────────────────
// واجهة الخدمة السحابية (ICloudService Interface)
// تفصل بين منطق التطبيق (DataSources) ومكتبة Supabase أو الخدمة الوهمية (Mock)
// ────────────────────────────────────────────────────────

abstract class ICloudService {
  /// جلب قائمة سجلات من جدول معين مع شروط التصفية والترتيب
  Future<List<Map<String, dynamic>>> select({
    required String table,
    String columns = '*',
    Map<String, dynamic>? eq,
    Map<String, dynamic>? neq,
    String? notIsNull,
    String? order,
    bool ascending = true,
  });

  /// إدخال سجل جديد في جدول
  Future<Map<String, dynamic>> insert({
    required String table,
    required Map<String, dynamic> data,
  });

  /// تحديث سجل أو مجموعة سجلات
  Future<List<Map<String, dynamic>>> update({
    required String table,
    required Map<String, dynamic> data,
    required String matchColumn,
    required dynamic matchValue,
  });

  /// حذف سجل من جدول
  Future<void> delete({
    required String table,
    String? matchColumn,
    dynamic matchValue,
    Map<String, dynamic>? matchMap,
  });

  /// الاشتراك المباشر بالوقت الفعلي (Realtime Stream)
  Stream<List<Map<String, dynamic>>> subscribe({
    required String table,
    required String primaryKey,
    String? clinicId,
  });
}

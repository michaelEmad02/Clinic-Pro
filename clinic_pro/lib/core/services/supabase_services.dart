import 'package:clinic_pro/core/services/i_cloud_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseServices extends ICloudService {
  final SupabaseClient supabase;

  SupabaseServices({required this.supabase});
  @override
  Future<void> delete({
    required String table,
    String? matchColumn,
    dynamic matchValue,
    Map<String, dynamic>? matchMap,
  }) async {
    dynamic query = supabase.from(table).delete();

    if (matchColumn != null && matchValue != null) {
      query = query.eq(matchColumn, matchValue);
    }

    if (matchMap != null) {
      matchMap.forEach((key, value) {
        query = query.eq(key, value);
      });
    }

    await query;
  }

  @override
  Future<Map<String, dynamic>> insert(
      {required String table, required Map<String, dynamic> data}) async {
    return await supabase.from(table).insert(data).select().single();
  }

  @override
  Future<List<Map<String, dynamic>>> select(
      {required String table,
      String columns = '*',
      Map<String, dynamic>? eq,
      Map<String, dynamic>? neq,
      String? notIsNull,
      String? order,
      bool ascending = true}) async {
    // بدء بناء الاستعلام لجلب البيانات وتحديد الأعمدة المطلوبة
    dynamic query = supabase.from(table).select(columns);

    // تطبيق فلاتر التساوي (eq) إذا كانت متوفرة
    if (eq != null) {
      eq.forEach((key, value) {
        query = query.eq(key, value);
      });
    }

    // تطبيق فلاتر عدم التساوي (neq) إذا كانت متوفرة
    if (neq != null) {
      neq.forEach((key, value) {
        query = query.neq(key, value);
      });
    }

    // تطبيق شرط التأكد من أن الحقل المحدد ليس فارغاً (IS NOT NULL)
    if (notIsNull != null) {
      query = query.not(notIsNull, 'is', null);
    }

    // تطبيق ترتيب النتائج (order) حسب الحقل والاتجاه المحدد
    if (order != null) {
      query = query.order(order, ascending: ascending);
    }

    // تنفيذ الاستعلام وانتظار النتيجة من Supabase
    final response = await query;

    // تحويل النتيجة إلى قائمة من الخرائط (List of Maps) وإرجاعها
    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Stream<List<Map<String, dynamic>>> subscribe(
      {required String table, required String primaryKey, String? clinicId}) {
    // TODO: implement subscribe
    throw UnimplementedError();
  }

  @override
  Future<List<Map<String, dynamic>>> update(
      {required String table,
      required Map<String, dynamic> data,
      required String matchColumn,
      required matchValue}) async {
    return await supabase
        .from(table)
        .update(data)
        .eq(matchColumn, matchValue)
        .select();
  }
}

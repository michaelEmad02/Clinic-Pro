import 'dart:async';
import 'package:clinic_pro/core/services/i_cloud_service.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@LazySingleton(as: ICloudService)
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
    var result = await supabase.from(table).insert(data).select().single();
    return result;
  }

  @override
  Future<List<Map<String, dynamic>>> select(
      {required String table,
      String columns = '*',
      Map<String, dynamic>? eq,
      Map<String, dynamic>? neq,
      Map<String, dynamic>? gte,
      Map<String, dynamic>? lte,
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

    // تطبيق فلاتر أكبر من أو يساوي (gte) إذا كانت متوفرة
    if (gte != null) {
      gte.forEach((key, value) {
        query = query.gte(key, value);
      });
    }

    // تطبيق فلاتر أصغر من أو يساوي (lte) إذا كانت متوفرة
    if (lte != null) {
      lte.forEach((key, value) {
        query = query.lte(key, value);
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
  Stream<List<Map<String, dynamic>>> subscribe({
    required String table,
    required String primaryKey,
    String? clinicId,
  }) {
    // استخدام Realtime Channel مباشرة بدلاً من .stream() البطيئة
    // .stream() فيها debounce داخلي يسبب تأخير 1-3 ثوانٍ
    // Channel يُرسل الإشعار فوراً بأجزاء من الملي ثانية

    final controller = StreamController<List<Map<String, dynamic>>>();
    RealtimeChannel? channel;

    controller.onListen = () async {
      // 1. جلب البيانات الأولية فوراً
      try {
        final initial = await select(
          table: table,
          eq: (clinicId != null && clinicId.isNotEmpty)
              ? {'clinic_id': clinicId}
              : null,
        );
        if (!controller.isClosed) controller.add(initial);
      } catch (_) {}

      // 2. الاشتراك بالـ Realtime Channel للإشعارات الفورية
      final name = 'rt_${table}_${clinicId ?? 'all'}_${DateTime.now().microsecondsSinceEpoch}';
      channel = supabase.channel(name);

      channel!.onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: table,
        callback: (payload) async {
          // عند أي حدث (INSERT, UPDATE, DELETE) نعيد جلب القائمة الخام
          try {
            final updated = await select(
              table: table,
              eq: (clinicId != null && clinicId.isNotEmpty)
                  ? {'clinic_id': clinicId}
                  : null,
            );
            if (!controller.isClosed) controller.add(updated);
          } catch (_) {}
        },
      );

      channel!.subscribe();
    };

    controller.onCancel = () {
      if (channel != null) supabase.removeChannel(channel!);
      if (!controller.isClosed) controller.close();
    };

    return controller.stream;
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

  @override
  Future<dynamic> rpc(String functionName, {Map<String, dynamic>? params}) async {
    return await supabase.rpc(functionName, params: params);
  }
}

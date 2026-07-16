// ────────────────────────────────────────────────────────
// هذا الملف مسؤول عن تسجيل المكتبات الخارجية (Third-party packages)
// في حاوية الاعتماديات (GetIt) عبر مكتبة (Injectable)
// ────────────────────────────────────────────────────────

import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@module
abstract class RegisterModule {
  // تهيئة SharedPreferences مسبقاً قبل تحميل باقي الاعتماديات
  // تسجيلها كـ singleton لضمان إعادة استخدام نفس النسخة في كل مكان
  @preResolve
  @lazySingleton
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();
  
  @lazySingleton
  SupabaseClient get supabase => Supabase.instance.client;
}
  
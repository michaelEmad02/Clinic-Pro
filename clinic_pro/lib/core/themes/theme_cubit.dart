// ────────────────────────────────────────────────────────
// هذا الملف مسؤول عن إدارة حالة المظهر (Theme Mode) للتطبيق
// يدعم حفظ واسترجاع اختيار المستخدم (فاتح، داكن، تلقائي) محلياً
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@lazySingleton
class ThemeCubit extends Cubit<ThemeMode> {
  static const String _themeKey = 'theme_mode';
  final SharedPreferences _prefs;

  // استقبال SharedPreferences مباشرة عبر منشئ الفئة (Constructor Injection)
  ThemeCubit(this._prefs) : super(ThemeMode.system) {
    _loadTheme();
  }

  /// تحميل المظهر المحفوظ بشكل متزامن وآمن من الذاكرة
  void _loadTheme() {
    try {
      final themeIndex = _prefs.getInt(_themeKey);
      if (themeIndex != null && themeIndex < ThemeMode.values.length) {
        emit(ThemeMode.values[themeIndex]);
      }
    } catch (_) {
      // في حالة حدوث أي استثناء، نعتمد مظهر النظام الافتراضي
      emit(ThemeMode.system);
    }
  }

  /// تحديث المظهر المختار وحفظه محلياً
  Future<void> setThemeMode(ThemeMode mode) async {
    emit(mode);
    try {
      await _prefs.setInt(_themeKey, mode.index);
    } catch (_) {
      // تجاهل أخطاء التخزين المحلي أثناء مرحلة التطوير التجريبي
    }
  }

  /// تبديل المظهر مباشرة بين الفاتح والداكن
  Future<void> toggleTheme(bool isDark) async {
    final newMode = isDark ? ThemeMode.dark : ThemeMode.light;
    await setThemeMode(newMode);
  }
}

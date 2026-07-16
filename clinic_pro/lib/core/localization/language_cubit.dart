import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../strings/app_strings.dart';

@lazySingleton
class LanguageCubit extends Cubit<Locale> {
  static const String _languageKey = 'language_code';
  final SharedPreferences _prefs;

  LanguageCubit(this._prefs) : super(const Locale('ar')) {
    _loadLanguage();
  }

  void _loadLanguage() {
    try {
      final code = _prefs.getString(_languageKey) ?? 'ar';
      AppStrings.isArabic = (code == 'ar');
      emit(Locale(code));
    } catch (_) {
      AppStrings.isArabic = true;
      emit(const Locale('ar'));
    }
  }

  Future<void> changeLanguage(String code) async {
    AppStrings.isArabic = (code == 'ar');
    emit(Locale(code));
    try {
      await _prefs.setString(_languageKey, code);
    } catch (_) {}
  }

  bool get isArabic => state.languageCode == 'ar';
}

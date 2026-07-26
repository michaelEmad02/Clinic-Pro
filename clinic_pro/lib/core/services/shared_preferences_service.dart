// ────────────────────────────────────────────────────────
// تطبيق خدمة التخزين المحلي عبر SharedPreferences (SharedPreferencesService)
// ────────────────────────────────────────────────────────

import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'i_local_data_service.dart';

@LazySingleton(as: ILocalDataService)
class SharedPreferencesService implements ILocalDataService {
  final SharedPreferences _prefs;

  SharedPreferencesService(this._prefs);

  @override
  Future<String?> getString(String key) async {
    return _prefs.getString(key);
  }

  @override
  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  @override
  Future<int?> getInt(String key) async {
    return _prefs.getInt(key);
  }

  @override
  Future<void> setInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }

  @override
  Future<bool?> getBool(String key) async {
    return _prefs.getBool(key);
  }

  @override
  Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  @override
  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  @override
  Future<void> clear() async {
    await _prefs.clear();
  }
}

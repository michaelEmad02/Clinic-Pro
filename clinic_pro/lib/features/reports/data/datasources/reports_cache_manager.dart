import 'package:injectable/injectable.dart';

class _CacheEntry<T> {
  final T data;
  final DateTime createdAt;

  _CacheEntry(this.data) : createdAt = DateTime.now();

  bool isValid(Duration ttl) {
    return DateTime.now().difference(createdAt) < ttl;
  }
}

/// مدير التخزين المؤقت الذكي لبيانات التقارير (Reports Cache Manager)
/// يحفظ استجابات الشبكة لمدة زمنية محددة (5 دقائق افتراضياً)
/// ويمنع جلب نفس البيانات تكراراً عند التنقل بين الشاشات أو الفلاتر
@lazySingleton
class ReportsCacheManager {
  final Map<String, _CacheEntry<dynamic>> _cache = {};
  static const Duration _defaultTtl = Duration(minutes: 5);

  ReportsCacheManager();

  /// جلب البيانات المخبأة إن وجِدت وكانت لا تزال صالحة
  T? get<T>(String key) {
    final entry = _cache[key];
    if (entry != null && entry.isValid(_defaultTtl)) {
      return entry.data as T;
    }
    // مسح الكاش المنتهي الصلاحية
    if (entry != null) {
      _cache.remove(key);
    }
    return null;
  }

  /// إدخال بيانات جديدة في الـ Cache
  void set<T>(String key, T data) {
    _cache[key] = _CacheEntry<T>(data);
  }

  /// مسح مفتاح محدد أو إخلاء الكاش بالكامل عند forceRefresh
  void clear([String? key]) {
    if (key != null) {
      _cache.remove(key);
    } else {
      _cache.clear();
    }
  }
}

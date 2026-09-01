import 'package:flutter/material.dart';
import 'package:clinic_pro/features/reports/presentation/manager/reports_state.dart';

/// Helper مشترك لحساب النطاق الزمني — يُستخدم في كل دوال التقارير
/// بدلاً من تكرار نفس الكود 4-5 مرات
class DateRangeHelper {
  final DateTime rangeStart;
  final DateTime rangeEnd;

  /// ISO strings تحول إلى UTC لضمان التطابق مع Supabase (created_at)
  String get rangeStartUtcIso => rangeStart.toUtc().toIso8601String();
  String get rangeEndUtcIso => rangeEnd.toUtc().toIso8601String();

  /// صيغ YYYY-MM-DD المقارنة مع حقل date في المواعيد
  String get rangeStartDateStr =>
      '${rangeStart.year}-${rangeStart.month.toString().padLeft(2, '0')}-${rangeStart.day.toString().padLeft(2, '0')}';
  String get rangeEndDateStr =>
      '${rangeEnd.year}-${rangeEnd.month.toString().padLeft(2, '0')}-${rangeEnd.day.toString().padLeft(2, '0')}';

  DateRangeHelper._({required this.rangeStart, required this.rangeEnd});

  /// ينشئ نطاق زمني بناءً على `ReportsDateRange` أو `customDateRange`
  factory DateRangeHelper.fromRange({
    ReportsDateRange range = ReportsDateRange.thisMonth,
    DateTimeRange? customDateRange,
  }) {
    final now = DateTime.now();
    late final DateTime start;
    late final DateTime end;

    if (range == ReportsDateRange.custom && customDateRange != null) {
      start = DateTime(customDateRange.start.year,
          customDateRange.start.month, customDateRange.start.day, 0, 0, 0);
      end = DateTime(customDateRange.end.year, customDateRange.end.month,
          customDateRange.end.day, 23, 59, 59, 999);
    } else if (range == ReportsDateRange.thisWeek) {
      final daysSinceSaturday = (now.weekday % 7 + 1) % 7;
      final startOfWeek = now.subtract(Duration(days: daysSinceSaturday));
      start = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day, 0, 0, 0);
      final endOfWeek = startOfWeek.add(const Duration(days: 6));
      end = DateTime(endOfWeek.year, endOfWeek.month, endOfWeek.day, 23, 59, 59, 999);
    } else if (range == ReportsDateRange.threeMonths) {
      final dt = DateTime(now.year, now.month - 2, 1);
      start = DateTime(dt.year, dt.month, dt.day, 0, 0, 0);
      end = DateTime(now.year, now.month + 1, 0, 23, 59, 59, 999);
    } else {
      // thisMonth (default)
      start = DateTime(now.year, now.month, 1, 0, 0, 0);
      end = DateTime(now.year, now.month + 1, 0, 23, 59, 59, 999);
    }

    return DateRangeHelper._(rangeStart: start, rangeEnd: end);
  }

  /// نطاق زمني موسّع (6 أشهر إلى الخلف) — يُستخدم لبيانات الشارت و الترندات
  factory DateRangeHelper.extended() {
    final now = DateTime.now();
    final sixMonthsAgo = DateTime(now.year, now.month - 5, 1, 0, 0, 0);
    return DateRangeHelper._(
      rangeStart: sixMonthsAgo,
      rangeEnd: DateTime(now.year, now.month, now.day, 23, 59, 59, 999),
    );
  }

  /// تحقق ما إذا كان التاريخ يقع داخل النطاق
  bool inRange(DateTime dt) =>
      (dt.isAfter(rangeStart) || dt.isAtSameMomentAs(rangeStart)) &&
      (dt.isBefore(rangeEnd) || dt.isAtSameMomentAs(rangeEnd));
}

// ─────────────────────────────────────────
// واجهة المستودع لـ Owner Dashboard (Domain Layer)
// تحوي 4 دوال تجريدية مستقلة لتغذية المكونات بشكل منفصل
// ─────────────────────────────────────────

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/owner_summary_stats_entity.dart';
import '../entities/clinic_summary_entity.dart';
import '../entities/dashboard_alert_entity.dart';

abstract class IOwnerDashboardRepository {
  /// جلب إحصائيات الملخص الـ 3 الرئيسية (إيراد اليوم، مواعيد اليوم، وإجمالي المرضى)
  Future<Either<Failure, OwnerSummaryStatsEntity>> getSummaryStats(
    String ownerId, {
    bool forceRefresh = false,
  });

  /// جلب إيرادات الأيام الـ 7 الأخيرة للمخطط البياني
  Future<Either<Failure, List<double>>> getWeeklyRevenue(
    String ownerId, {
    bool forceRefresh = false,
  });

  /// جلب ملخص العيادات النشطة
  Future<Either<Failure, List<ClinicSummaryEntity>>> getClinicsOverview(
    String ownerId, {
    bool forceRefresh = false,
  });

  /// جلب التنبيهات الذكية (حالة الاشتراك والدعوات المعلقة)
  Future<Either<Failure, List<DashboardAlertEntity>>> getAlerts(
    String ownerId, {
    bool forceRefresh = false,
  });
}

// ─────────────────────────────────────────
// واجهة مصدر البيانات البعيدة لـ Owner Dashboard (Data Layer)
// تحوي 4 دوال استعلام مستقلة وسريعة
// ─────────────────────────────────────────

import '../../domain/entities/clinic_summary_entity.dart';
import '../../domain/entities/dashboard_alert_entity.dart';
import '../models/owner_summary_stats_model.dart';

abstract class IOwnerDashboardRemoteDataSource {
  Future<OwnerSummaryStatsModel> fetchSummaryStats(
    String ownerId, {
    bool forceRefresh = false,
  });

  Future<List<double>> fetchWeeklyRevenue(
    String ownerId, {
    bool forceRefresh = false,
  });

  Future<List<ClinicSummaryEntity>> fetchClinicsOverview(
    String ownerId, {
    bool forceRefresh = false,
  });

  Future<List<DashboardAlertEntity>> fetchAlerts(
    String ownerId, {
    bool forceRefresh = false,
  });
}

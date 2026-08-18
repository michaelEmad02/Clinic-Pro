// ─────────────────────────────────────────
// Model إحصائيات الملخص كائن البيانات (Data Layer)
// ─────────────────────────────────────────

import '../../domain/entities/owner_summary_stats_entity.dart';

class OwnerSummaryStatsModel extends OwnerSummaryStatsEntity {
  const OwnerSummaryStatsModel({
    required super.todayNetRevenue,
    required super.todayAppointments,
    required super.todayCompletedAppointments,
    required super.totalPatients,
  });
}

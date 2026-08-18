// ─────────────────────────────────────────
// Entity إحصائيات الملخص الكلية للوحة تحكم المالك (Domain Layer)
// ─────────────────────────────────────────

import 'package:equatable/equatable.dart';

class OwnerSummaryStatsEntity extends Equatable {
  final num todayNetRevenue;
  final int todayAppointments;
  final int todayCompletedAppointments;
  final int totalPatients;

  const OwnerSummaryStatsEntity({
    required this.todayNetRevenue,
    required this.todayAppointments,
    required this.todayCompletedAppointments,
    required this.totalPatients,
  });

  @override
  List<Object?> get props => [
        todayNetRevenue,
        todayAppointments,
        todayCompletedAppointments,
        totalPatients,
      ];
}

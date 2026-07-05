// ─────────────────────────────────────────
// Entity البيانات المجمعة للوحة تحكم المالك
// يحتوي على جميع الإحصائيات المجمعة من جميع العيادات
// ─────────────────────────────────────────

import 'package:equatable/equatable.dart';
import 'clinic_summary_entity.dart';
import 'dashboard_alert_entity.dart';

class OwnerDashboardEntity extends Equatable {
  final String ownerName;
  final num totalRevenue;
  final int totalPatients;
  final int todayAppointments;
  final int activeClinics;
  final List<ClinicSummaryEntity> clinics;
  final List<DashboardAlertEntity> alerts;
  final List<double> weeklyRevenue;

  const OwnerDashboardEntity({
    required this.ownerName,
    required this.totalRevenue,
    required this.totalPatients,
    required this.todayAppointments,
    required this.activeClinics,
    required this.clinics,
    required this.alerts,
    required this.weeklyRevenue,
  });

  @override
  List<Object?> get props => [
        ownerName,
        totalRevenue,
        totalPatients,
        todayAppointments,
        activeClinics,
        clinics,
        alerts,
        weeklyRevenue,
      ];
}

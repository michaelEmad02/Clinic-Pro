import 'package:clinic_pro/core/enities/performance_statistics.dart';
import 'package:clinic_pro/features/clinics/domain/entities/clinic_statistics_entity.dart';

class ClinicStatisticsModel extends ClinicStatisticsEntity {
  ClinicStatisticsModel(super.clinicMonthlyPerformance,
      {required super.dayAppointments,
      required super.numberOfDoctors,
      required super.monthlyRevenue,
      required super.numberOfFinishedAppointments});

  factory ClinicStatisticsModel.fromJson(Map<String, dynamic> data) {
    var performance =
        (data["clinic_monthly_performance"] as List<Map<String, dynamic>>)
            .map((p) => PerformanceStatistics.fromJson(p))
            .toList();

    return ClinicStatisticsModel(performance,
        dayAppointments: data["day_appointments"],
        numberOfDoctors: data["number_of_doctors"],
        monthlyRevenue: data["monthly_revenue"],
        numberOfFinishedAppointments: data["number_of_finished_appointments"]);
  }
}

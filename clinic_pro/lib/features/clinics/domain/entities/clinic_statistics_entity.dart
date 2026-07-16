import 'package:clinic_pro/core/enities/performance_statistics.dart';

class ClinicStatisticsEntity {
  final int dayAppointments;
  final int numberOfDoctors;
  final double monthlyRevenue;
  final int numberOfFinishedAppointments;
  final List<PerformanceStatistics> clinicMonthlyPerformance;

  ClinicStatisticsEntity(this.clinicMonthlyPerformance,
      {required this.dayAppointments,
      required this.numberOfDoctors,
      required this.monthlyRevenue,
      required this.numberOfFinishedAppointments});
}

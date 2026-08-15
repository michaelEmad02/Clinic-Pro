
class ClinicStatisticsEntity {
  final int dayAppointments;
  final int numberOfDoctors;
  final double monthlyRevenue;
  final int numberOfFinishedAppointments;
  final double monthlyExpenses;
  final double netProfit;
  final List<PerformanceStatistics> clinicMonthlyPerformance;

  ClinicStatisticsEntity(this.clinicMonthlyPerformance,
      {required this.dayAppointments,
      required this.numberOfDoctors,
      required this.monthlyRevenue,
      required this.numberOfFinishedAppointments,
      required this.monthlyExpenses,
      required this.netProfit});
}

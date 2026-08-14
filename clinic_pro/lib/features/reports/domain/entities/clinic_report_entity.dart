import 'package:equatable/equatable.dart';
import 'package:clinic_pro/core/enities/performance_statistics.dart';

class ClinicComparisonItem extends Equatable {
  final String clinicId;
  final String clinicName;
  final double expectedRevenue; // من جدول appointments (مجموع أسعار المواعيد لهذا الشهر)
  final double collectedAmount; // من جدول invoices (مجموع paid_amount لهذا الشهر)
  final double monthlyExpenses;
  final double netProfit; // collectedAmount - monthlyExpenses
  final double profitMargin; // netProfit / (collectedAmount > 0 ? collectedAmount : expectedRevenue) * 100
  final int dayAppointments;
  final int finishedAppointments;
  final int numberOfDoctors;
  final double revenuePerDoctor; // collectedAmount / numberOfDoctors
  final List<PerformanceStatistics> monthlyPerformance; // الإيرادات المحصلة الفعلية عبر الأشهر
  final List<PerformanceStatistics> monthlyExpectedPerformance; // الإيرادات المتوقعة عبر الأشهر

  const ClinicComparisonItem({
    required this.clinicId,
    required this.clinicName,
    required this.expectedRevenue,
    required this.collectedAmount,
    required this.monthlyExpenses,
    required this.netProfit,
    required this.profitMargin,
    required this.dayAppointments,
    required this.finishedAppointments,
    required this.numberOfDoctors,
    required this.revenuePerDoctor,
    required this.monthlyPerformance,
    required this.monthlyExpectedPerformance,
  });

  @override
  List<Object?> get props => [
        clinicId,
        clinicName,
        expectedRevenue,
        collectedAmount,
        monthlyExpenses,
        netProfit,
        profitMargin,
        dayAppointments,
        finishedAppointments,
        numberOfDoctors,
        revenuePerDoctor,
        monthlyPerformance,
        monthlyExpectedPerformance,
      ];
}

class ClinicReportEntity extends Equatable {
  final int totalActiveClinics;
  final double totalExpectedRevenue;
  final double totalCollectedAmount;
  final double totalExpenses;
  final double totalNetProfit;
  final int totalAppointmentsToday;
  final int totalDoctors;
  final List<ClinicComparisonItem> clinics;

  const ClinicReportEntity({
    required this.totalActiveClinics,
    required this.totalExpectedRevenue,
    required this.totalCollectedAmount,
    required this.totalExpenses,
    required this.totalNetProfit,
    required this.totalAppointmentsToday,
    required this.totalDoctors,
    required this.clinics,
  });

  @override
  List<Object?> get props => [
        totalActiveClinics,
        totalExpectedRevenue,
        totalCollectedAmount,
        totalExpenses,
        totalNetProfit,
        totalAppointmentsToday,
        totalDoctors,
        clinics,
      ];
}

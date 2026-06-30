// ────────────────────────────────────────────────────────
// حالات شاشة التقارير — نماذج البيانات والتقارير
// ────────────────────────────────────────────────────────

import 'package:equatable/equatable.dart';

enum ReportsDateRange { thisWeek, thisMonth, threeMonths, custom }

class ReportSummary extends Equatable {
  final double revenue;
  final double expenses;
  final double netProfit;
  final int totalPatients;
  final String revenueChange;  // eg. '+12%'
  final String expensesChange; // eg. '-5%'

  const ReportSummary({
    required this.revenue,
    required this.expenses,
    required this.netProfit,
    required this.totalPatients,
    required this.revenueChange,
    required this.expensesChange,
  });

  @override
  List<Object?> get props =>
      [revenue, expenses, netProfit, totalPatients];
}

class WeeklyData extends Equatable {
  final String week;
  final double revenue;
  final double expenses;

  const WeeklyData({
    required this.week,
    required this.revenue,
    required this.expenses,
  });

  @override
  List<Object?> get props => [week, revenue, expenses];
}

class TopServiceItem extends Equatable {
  final String name;
  final double revenue;
  final String icon;

  const TopServiceItem({
    required this.name,
    required this.revenue,
    required this.icon,
  });

  @override
  List<Object?> get props => [name, revenue];
}

class DoctorPerformanceItem extends Equatable {
  final String doctorId;
  final String doctorName;
  final int patientCount;
  final double revenue;
  final int rating;      // percentage 0-100
  final String trend;    // 'up', 'down', 'stable'
  final String? avatarUrl;

  const DoctorPerformanceItem({
    required this.doctorId,
    required this.doctorName,
    required this.patientCount,
    required this.revenue,
    required this.rating,
    required this.trend,
    this.avatarUrl,
  });

  @override
  List<Object?> get props =>
      [doctorId, doctorName, patientCount, rating];
}

abstract class ReportsState extends Equatable {
  const ReportsState();
  @override
  List<Object?> get props => [];
}

class ReportsInitial extends ReportsState {}

class ReportsLoading extends ReportsState {}

class ReportsLoaded extends ReportsState {
  final ReportSummary summary;
  final List<WeeklyData> weeklyData;
  final List<TopServiceItem> topServices;
  final List<DoctorPerformanceItem> doctorPerformance;
  final ReportsDateRange activeRange;

  const ReportsLoaded({
    required this.summary,
    required this.weeklyData,
    required this.topServices,
    required this.doctorPerformance,
    this.activeRange = ReportsDateRange.thisMonth,
  });

  ReportsLoaded copyWith({
    ReportsDateRange? activeRange,
  }) {
    return ReportsLoaded(
      summary: summary,
      weeklyData: weeklyData,
      topServices: topServices,
      doctorPerformance: doctorPerformance,
      activeRange: activeRange ?? this.activeRange,
    );
  }

  @override
  List<Object?> get props => [
    summary,
    weeklyData,
    topServices,
    doctorPerformance,
    activeRange,
  ];
}

class ReportsError extends ReportsState {
  final String message;
  const ReportsError(this.message);
  @override
  List<Object?> get props => [message];
}

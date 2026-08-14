import 'package:equatable/equatable.dart';
import '../../domain/entities/reports_entities.dart';

enum ReportsDateRange { thisWeek, thisMonth, threeMonths, custom }

typedef WeeklyData = WeeklyRevenueEntity;
typedef DoctorPerformanceItem = DoctorPerformanceEntity;
typedef TopServiceItem = TopServiceEntity;

class ReportSummary extends Equatable {
  final double revenue;
  final double collected;
  final double expenses;
  final double netProfit;
  final int totalPatients;
  final String revenueChange;
  final String expensesChange;

  const ReportSummary({
    required this.revenue,
    this.collected = 0.0,
    required this.expenses,
    required this.netProfit,
    required this.totalPatients,
    required this.revenueChange,
    required this.expensesChange,
  });

  @override
  List<Object?> get props => [revenue, collected, expenses, netProfit, totalPatients];
}

abstract class ReportsState extends Equatable {
  const ReportsState();
  @override
  List<Object?> get props => [];
}

class ReportsInitial extends ReportsState {}

class ReportsLoading extends ReportsState {}

class ReportsLoaded extends ReportsState {
  final RevenueSummaryEntity? revenueSummary;
  final AppointmentStatsEntity? appointmentStats;
  final PatientStatsEntity? patientStats;
  final List<DoctorPerformanceEntity> doctorPerformance;
  final DrugStatsEntity? drugStats;
  final List<TemplateStatsEntity> templateStats;
  final ReportsDateRange activeRange;

  const ReportsLoaded({
    this.revenueSummary,
    this.appointmentStats,
    this.patientStats,
    this.doctorPerformance = const [],
    this.drugStats,
    this.templateStats = const [],
    this.activeRange = ReportsDateRange.thisMonth,
  });

  ReportsLoaded copyWith({
    RevenueSummaryEntity? revenueSummary,
    AppointmentStatsEntity? appointmentStats,
    PatientStatsEntity? patientStats,
    List<DoctorPerformanceEntity>? doctorPerformance,
    DrugStatsEntity? drugStats,
    List<TemplateStatsEntity>? templateStats,
    ReportsDateRange? activeRange,
  }) {
    return ReportsLoaded(
      revenueSummary: revenueSummary ?? this.revenueSummary,
      appointmentStats: appointmentStats ?? this.appointmentStats,
      patientStats: patientStats ?? this.patientStats,
      doctorPerformance: doctorPerformance ?? this.doctorPerformance,
      drugStats: drugStats ?? this.drugStats,
      templateStats: templateStats ?? this.templateStats,
      activeRange: activeRange ?? this.activeRange,
    );
  }

  @override
  List<Object?> get props => [
        revenueSummary,
        appointmentStats,
        patientStats,
        doctorPerformance,
        drugStats,
        templateStats,
        activeRange,
      ];
}

class ReportsError extends ReportsState {
  final String message;
  const ReportsError(this.message);
  @override
  List<Object?> get props => [message];
}

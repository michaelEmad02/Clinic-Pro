import 'package:equatable/equatable.dart';

class RevenueSummaryEntity extends Equatable {
  final double totalRevenue;
  final double collectedAmount;
  final double totalExpenses;
  final double netProfit;
  final double pendingAmount;
  final String revenueChange;
  final String expensesChange;
  final List<WeeklyRevenueEntity> chart;
  final List<ExpenseCategoryStatEntity> expensesBreakdown;

  double get revenue => totalRevenue;
  double get expenses => totalExpenses;

  const RevenueSummaryEntity({
    required this.totalRevenue,
    required this.collectedAmount,
    required this.totalExpenses,
    required this.netProfit,
    required this.pendingAmount,
    required this.revenueChange,
    required this.expensesChange,
    required this.chart,
    this.expensesBreakdown = const [],
  });

  @override
  List<Object?> get props => [
        totalRevenue,
        collectedAmount,
        totalExpenses,
        netProfit,
        pendingAmount,
        revenueChange,
        expensesChange,
        chart,
        expensesBreakdown,
      ];
}

class ExpenseCategoryStatEntity extends Equatable {
  final String category;
  final double amount;
  final double percentage;

  const ExpenseCategoryStatEntity({
    required this.category,
    required this.amount,
    required this.percentage,
  });

  @override
  List<Object?> get props => [category, amount, percentage];
}

class WeeklyRevenueEntity extends Equatable {
  final String week;
  final double revenue;
  final double collected;
  final double expenses;

  const WeeklyRevenueEntity({
    required this.week,
    required this.revenue,
    required this.collected,
    required this.expenses,
  });

  @override
  List<Object?> get props => [week, revenue, collected, expenses];
}

class AppointmentStatsEntity extends Equatable {
  final int totalAppointments;
  final int completedAppointments;
  final int cancelledAppointments;
  final double attendanceRate;
  final int avgWaitTimeMinutes;
  final int urgentCount;
  final double urgentPercentage;
  final int noShowCount;
  final double noShowRate;
  final Map<String, int> statusBreakdown;
  final List<PeakHourEntity> peakHours;
  final List<PeakDayEntity> peakDays;
  final List<VisitTypeEntity> byType;

  const AppointmentStatsEntity({
    required this.totalAppointments,
    required this.completedAppointments,
    required this.cancelledAppointments,
    required this.attendanceRate,
    this.avgWaitTimeMinutes = 0,
    this.urgentCount = 0,
    this.urgentPercentage = 0.0,
    this.noShowCount = 0,
    this.noShowRate = 0.0,
    this.statusBreakdown = const {},
    required this.peakHours,
    required this.peakDays,
    required this.byType,
  });

  @override
  List<Object?> get props => [
        totalAppointments,
        completedAppointments,
        cancelledAppointments,
        attendanceRate,
        avgWaitTimeMinutes,
        urgentCount,
        urgentPercentage,
        noShowCount,
        noShowRate,
        statusBreakdown,
        peakHours,
        peakDays,
        byType,
      ];
}

class PeakHourEntity extends Equatable {
  final int hour;
  final int count;

  const PeakHourEntity({required this.hour, required this.count});

  @override
  List<Object?> get props => [hour, count];
}

class PeakDayEntity extends Equatable {
  final String dayName;
  final int count;

  const PeakDayEntity({required this.dayName, required this.count});

  @override
  List<Object?> get props => [dayName, count];
}

class VisitTypeEntity extends Equatable {
  final String name;
  final int count;

  const VisitTypeEntity({required this.name, required this.count});

  @override
  List<Object?> get props => [name, count];
}

class DoctorPerformanceEntity extends Equatable {
  final String doctorId;
  final String doctorName;
  final int visitCount;
  final double revenue;
  final int rating;
  final String trend;
  final String? avatarUrl;

  const DoctorPerformanceEntity({
    required this.doctorId,
    required this.doctorName,
    required this.visitCount,
    required this.revenue,
    required this.rating,
    required this.trend,
    this.avatarUrl,
  });

  @override
  List<Object?> get props =>
      [doctorId, doctorName, visitCount, revenue, rating, trend, avatarUrl];
}

class PatientStatsEntity extends Equatable {
  final int totalPatients;
  final int newPatients;
  final int returningPatients;
  final double returnRate;
  final double avgVisitsPerPatient;
  final double avgRevenuePerPatient;
  final double newPatientsPercentage;
  final double returningPatientsPercentage;
  final Map<String, int> byGender;
  final Map<String, int> byAgeGroup;
  final List<InactivePatientEntity> inactivePatients;

  const PatientStatsEntity({
    required this.totalPatients,
    required this.newPatients,
    required this.returningPatients,
    required this.returnRate,
    this.avgVisitsPerPatient = 0.0,
    this.avgRevenuePerPatient = 0.0,
    this.newPatientsPercentage = 0.0,
    this.returningPatientsPercentage = 0.0,
    required this.byGender,
    required this.byAgeGroup,
    required this.inactivePatients,
  });

  @override
  List<Object?> get props => [
        totalPatients,
        newPatients,
        returningPatients,
        returnRate,
        avgVisitsPerPatient,
        avgRevenuePerPatient,
        newPatientsPercentage,
        returningPatientsPercentage,
        byGender,
        byAgeGroup,
        inactivePatients,
      ];
}

class InactivePatientEntity extends Equatable {
  final String name;
  final String lastVisit;
  final int daysSinceLastVisit;

  const InactivePatientEntity({
    required this.name,
    required this.lastVisit,
    required this.daysSinceLastVisit,
  });

  @override
  List<Object?> get props => [name, lastVisit, daysSinceLastVisit];
}

class DrugStatsEntity extends Equatable {
  final int totalPrescriptions;
  final double avgDrugsPerPrescription;
  final double prnPercentage;
  final String topDiagnosisName;
  final List<DrugCategoryStatEntity> byCategory;
  final List<TopDrugStatEntity> topDrugs;
  final List<NameCountStatEntity> topDiagnoses;
  final List<TemplateStatsEntity> templateStats;
  final List<MonthlyPrescriptionTrendEntity> monthlyTrend;
  final List<DosingPatternStatEntity> commonDosages;
  final List<TopDrugStatEntity> chronicDrugs;
  final List<DrugDiagnosisStatEntity> drugDiagnosisLinks;
  final List<RepeatDrugStatEntity> repeatedDrugs;
  final List<SwitchedDrugStatEntity> switchedDrugs;
  final List<PatientReachStatEntity> patientReach;

  const DrugStatsEntity({
    this.totalPrescriptions = 0,
    this.avgDrugsPerPrescription = 0.0,
    this.prnPercentage = 0.0,
    this.topDiagnosisName = '',
    required this.byCategory,
    required this.topDrugs,
    this.topDiagnoses = const [],
    this.templateStats = const [],
    this.monthlyTrend = const [],
    this.commonDosages = const [],
    this.chronicDrugs = const [],
    this.drugDiagnosisLinks = const [],
    this.repeatedDrugs = const [],
    this.switchedDrugs = const [],
    this.patientReach = const [],
  });

  @override
  List<Object?> get props => [
        totalPrescriptions,
        avgDrugsPerPrescription,
        prnPercentage,
        topDiagnosisName,
        byCategory,
        topDrugs,
        topDiagnoses,
        templateStats,
        monthlyTrend,
        commonDosages,
        chronicDrugs,
        drugDiagnosisLinks,
        repeatedDrugs,
        switchedDrugs,
        patientReach,
      ];
}

class NameCountStatEntity extends Equatable {
  final String name;
  final int count;
  final double percentage;

  const NameCountStatEntity({
    required this.name,
    required this.count,
    required this.percentage,
  });

  @override
  List<Object?> get props => [name, count, percentage];
}

class MonthlyPrescriptionTrendEntity extends Equatable {
  final String month;
  final int count;
  final double avgDrugs;

  const MonthlyPrescriptionTrendEntity({
    required this.month,
    required this.count,
    required this.avgDrugs,
  });

  @override
  List<Object?> get props => [month, count, avgDrugs];
}

class DosingPatternStatEntity extends Equatable {
  final String pattern;
  final int count;
  final double percentage;

  const DosingPatternStatEntity({
    required this.pattern,
    required this.count,
    required this.percentage,
  });

  @override
  List<Object?> get props => [pattern, count, percentage];
}

class DrugDiagnosisStatEntity extends Equatable {
  final String diagnosis;
  final String drugName;
  final int count;

  const DrugDiagnosisStatEntity({
    required this.diagnosis,
    required this.drugName,
    required this.count,
  });

  @override
  List<Object?> get props => [diagnosis, drugName, count];
}

class RepeatDrugStatEntity extends Equatable {
  final String drugName;
  final int repeatCount;
  final int patientCount;

  const RepeatDrugStatEntity({
    required this.drugName,
    required this.repeatCount,
    required this.patientCount,
  });

  @override
  List<Object?> get props => [drugName, repeatCount, patientCount];
}

class SwitchedDrugStatEntity extends Equatable {
  final String initialDrugName;
  final String replacedByDrugName;
  final String diagnosis;
  final int switchCount;

  const SwitchedDrugStatEntity({
    required this.initialDrugName,
    required this.replacedByDrugName,
    required this.diagnosis,
    required this.switchCount,
  });

  @override
  List<Object?> get props => [initialDrugName, replacedByDrugName, diagnosis, switchCount];
}

class PatientReachStatEntity extends Equatable {
  final String drugName;
  final int uniquePatients;
  final int totalPrescribedCount;

  const PatientReachStatEntity({
    required this.drugName,
    required this.uniquePatients,
    required this.totalPrescribedCount,
  });

  @override
  List<Object?> get props => [drugName, uniquePatients, totalPrescribedCount];
}

class DrugCategoryStatEntity extends Equatable {
  final String category;
  final int count;
  final double percentage;

  const DrugCategoryStatEntity({
    required this.category,
    required this.count,
    required this.percentage,
  });

  @override
  List<Object?> get props => [category, count, percentage];
}

class TopDrugStatEntity extends Equatable {
  final String name;
  final String? genericName;
  final int count;
  final double percentage;

  const TopDrugStatEntity({
    required this.name,
    this.genericName,
    required this.count,
    required this.percentage,
  });

  @override
  List<Object?> get props => [name, genericName, count, percentage];
}

class TopServiceEntity extends Equatable {
  final String name;
  final double revenue;
  final String icon;

  const TopServiceEntity({
    required this.name,
    required this.revenue,
    required this.icon,
  });

  @override
  List<Object?> get props => [name, revenue, icon];
}

class TemplateStatsEntity extends Equatable {
  final String id;
  final String name;
  final int userCount;
  final double percentage;

  const TemplateStatsEntity({
    required this.id,
    required this.name,
    required this.userCount,
    required this.percentage,
  });

  @override
  List<Object?> get props => [id, name, userCount, percentage];
}

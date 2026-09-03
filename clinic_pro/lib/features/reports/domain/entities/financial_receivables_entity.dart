// ────────────────────────────────────────────────────────
// FinancialReceivablesEntity — كيانات تقرير المستحقات المالية والمرضى المديونين
// ────────────────────────────────────────────────────────

import 'package:equatable/equatable.dart';

/// كيان تفكيك أعمار الديون (Aging Analysis)
class ReceivableAgingEntity extends Equatable {
  final double under7Days;
  final double days7To30;
  final double over30Days;

  const ReceivableAgingEntity({
    required this.under7Days,
    required this.days7To30,
    required this.over30Days,
  });

  @override
  List<Object?> get props => [under7Days, days7To30, over30Days];
}

/// كيان المريض المديون
class PatientDebtorEntity extends Equatable {
  final String patientId;
  final String patientName;
  final String? patientPhone;
  final double issuedPendingAmount;
  final double unbilledAmount;
  final int unbilledVisitsCount;
  final double totalDue;
  final String? lastVisitDate;

  const PatientDebtorEntity({
    required this.patientId,
    required this.patientName,
    this.patientPhone,
    required this.issuedPendingAmount,
    required this.unbilledAmount,
    required this.unbilledVisitsCount,
    required this.totalDue,
    this.lastVisitDate,
  });

  @override
  List<Object?> get props => [
        patientId,
        patientName,
        patientPhone,
        issuedPendingAmount,
        unbilledAmount,
        unbilledVisitsCount,
        totalDue,
        lastVisitDate,
      ];
}

/// كيان التقرير المالي الرئيسي للمستحقات
class FinancialReceivablesEntity extends Equatable {
  final double totalReceivables;
  final double issuedInvoicesPending;
  final double unbilledVisitsAmount;
  final int debtorPatientsCount;
  final ReceivableAgingEntity aging;
  final List<PatientDebtorEntity> debtors;

  const FinancialReceivablesEntity({
    required this.totalReceivables,
    required this.issuedInvoicesPending,
    required this.unbilledVisitsAmount,
    required this.debtorPatientsCount,
    required this.aging,
    required this.debtors,
  });

  @override
  List<Object?> get props => [
        totalReceivables,
        issuedInvoicesPending,
        unbilledVisitsAmount,
        debtorPatientsCount,
        aging,
        debtors,
      ];
}

// ────────────────────────────────────────────────────────
// FinancialReceivablesModel — موديل تحويل خريطة RPC JSONB إلى كيانات المستحقات المالية
// ────────────────────────────────────────────────────────

import '../../domain/entities/financial_receivables_entity.dart';

class ReceivableAgingModel extends ReceivableAgingEntity {
  const ReceivableAgingModel({
    required super.under7Days,
    required super.days7To30,
    required super.over30Days,
  });

  factory ReceivableAgingModel.fromJson(Map<String, dynamic> json) {
    return ReceivableAgingModel(
      under7Days: (json['under_7_days'] as num?)?.toDouble() ?? 0.0,
      days7To30: (json['days_7_to_30'] as num?)?.toDouble() ?? 0.0,
      over30Days: (json['over_30_days'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class PatientDebtorModel extends PatientDebtorEntity {
  const PatientDebtorModel({
    required super.patientId,
    required super.patientName,
    super.patientPhone,
    required super.issuedPendingAmount,
    required super.unbilledAmount,
    required super.unbilledVisitsCount,
    required super.totalDue,
    super.lastVisitDate,
  });

  factory PatientDebtorModel.fromJson(Map<String, dynamic> json) {
    return PatientDebtorModel(
      patientId: json['patient_id'] as String? ?? '',
      patientName: json['patient_name'] as String? ?? 'مريض غير معروف',
      patientPhone: json['patient_phone'] as String?,
      issuedPendingAmount: (json['issued_pending_amount'] as num?)?.toDouble() ?? 0.0,
      unbilledAmount: (json['unbilled_amount'] as num?)?.toDouble() ?? 0.0,
      unbilledVisitsCount: (json['unbilled_visits_count'] as num?)?.toInt() ?? 0,
      totalDue: (json['total_due'] as num?)?.toDouble() ?? 0.0,
      lastVisitDate: json['last_visit_date'] as String?,
    );
  }
}

class FinancialReceivablesModel extends FinancialReceivablesEntity {
  const FinancialReceivablesModel({
    required super.totalReceivables,
    required super.issuedInvoicesPending,
    required super.unbilledVisitsAmount,
    required super.debtorPatientsCount,
    required super.aging,
    required super.debtors,
  });

  factory FinancialReceivablesModel.fromJson(Map<String, dynamic> json) {
    final debtorsList = (json['debtors'] as List<dynamic>?)
            ?.map((e) => PatientDebtorModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    final agingMap = (json['aging'] as Map<String, dynamic>?) ?? {};

    return FinancialReceivablesModel(
      totalReceivables: (json['total_receivables'] as num?)?.toDouble() ?? 0.0,
      issuedInvoicesPending: (json['issued_invoices_pending'] as num?)?.toDouble() ?? 0.0,
      unbilledVisitsAmount: (json['unbilled_visits_amount'] as num?)?.toDouble() ?? 0.0,
      debtorPatientsCount: (json['debtor_patients_count'] as num?)?.toInt() ?? 0,
      aging: ReceivableAgingModel.fromJson(agingMap),
      debtors: debtorsList,
    );
  }
}

// ────────────────────────────────────────────────────────
// FinancialReceivablesState — حالة تقرير المستحقات المالية
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/features/reports/domain/entities/financial_receivables_entity.dart';
import 'package:clinic_pro/features/reports/presentation/manager/reports_state.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum FinancialReceivablesStatus { initial, loading, loaded, error }

const Object _unspecified = Object();

class FinancialReceivablesState extends Equatable {
  final FinancialReceivablesStatus status;
  final FinancialReceivablesEntity? report;
  final String? errorMessage;
  final ReportsDateRange activeDateRange;
  final DateTimeRange? customDateRange;
  final String? selectedOwnerId;
  final String? selectedClinicId;
  final String? selectedDoctorId;
  final String searchQuery;
  final int activeTab; // 0: كشف حساب المرضى المديونين، 1: السجل التفصيلي للمستحقات
  final int typeFilter; // 0: الكل، 1: فواتير معلقة فقط، 2: زيارات غير مفوترة فقط

  const FinancialReceivablesState({
    this.status = FinancialReceivablesStatus.initial,
    this.report,
    this.errorMessage,
    this.activeDateRange = ReportsDateRange.thisMonth,
    this.customDateRange,
    this.selectedOwnerId,
    this.selectedClinicId,
    this.selectedDoctorId,
    this.searchQuery = '',
    this.activeTab = 0,
    this.typeFilter = 0,
  });

  /// قائمة المرضى المديونين المصفاة بحسب مربع البحث ونوع المستحق
  List<PatientDebtorEntity> get filteredDebtors {
    if (report == null) return [];
    var list = report!.debtors;

    if (typeFilter == 1) {
      list = list.where((d) => d.issuedPendingAmount > 0).toList();
    } else if (typeFilter == 2) {
      list = list.where((d) => d.unbilledAmount > 0).toList();
    }

    if (searchQuery.trim().isNotEmpty) {
      final query = searchQuery.trim().toLowerCase();
      list = list.where((d) {
        final name = d.patientName.toLowerCase();
        final phone = (d.patientPhone ?? '').toLowerCase();
        return name.contains(query) || phone.contains(query);
      }).toList();
    }

    return list;
  }

  FinancialReceivablesState copyWith({
    FinancialReceivablesStatus? status,
    FinancialReceivablesEntity? report,
    String? errorMessage,
    ReportsDateRange? activeDateRange,
    DateTimeRange? customDateRange,
    Object? selectedOwnerId = _unspecified,
    Object? selectedClinicId = _unspecified,
    Object? selectedDoctorId = _unspecified,
    String? searchQuery,
    int? activeTab,
    int? typeFilter,
  }) {
    return FinancialReceivablesState(
      status: status ?? this.status,
      report: report ?? this.report,
      errorMessage: errorMessage ?? this.errorMessage,
      activeDateRange: activeDateRange ?? this.activeDateRange,
      customDateRange: customDateRange ?? this.customDateRange,
      selectedOwnerId: selectedOwnerId == _unspecified ? this.selectedOwnerId : selectedOwnerId as String?,
      selectedClinicId: selectedClinicId == _unspecified ? this.selectedClinicId : selectedClinicId as String?,
      selectedDoctorId: selectedDoctorId == _unspecified ? this.selectedDoctorId : selectedDoctorId as String?,
      searchQuery: searchQuery ?? this.searchQuery,
      activeTab: activeTab ?? this.activeTab,
      typeFilter: typeFilter ?? this.typeFilter,
    );
  }

  @override
  List<Object?> get props => [
        status,
        report,
        errorMessage,
        activeDateRange,
        customDateRange,
        selectedOwnerId,
        selectedClinicId,
        selectedDoctorId,
        searchQuery,
        activeTab,
        typeFilter,
      ];
}

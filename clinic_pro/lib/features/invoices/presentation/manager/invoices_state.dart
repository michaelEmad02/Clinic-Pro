// ────────────────────────────────────────────────────────
// InvoicesState — حالة إدارة الفواتير بـ Presentation Layer
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/features/invoices/domain/entities/invoice_entity.dart';
import 'package:clinic_pro/features/invoices/domain/entities/unpaid_appointment_entity.dart';
import 'package:equatable/equatable.dart';

enum InvoicesStatus { initial, loading, success, failure, saving, deleting }

enum InvoicesDateRange { today, thisWeek, thisMonth, threeMonths, all, custom }

class InvoicesState extends Equatable {
  final InvoicesStatus status;
  final List<InvoiceEntity> invoices;
  final List<InvoiceEntity> filteredInvoices;
  final List<UnpaidAppointmentEntity> unbilledAppointments;
  final List<UnpaidAppointmentEntity> filteredUnbilledAppointments;
  final List<UnpaidAppointmentEntity> patientUnpaidAppointments;
  final String activeTab; // 'invoices' | 'unbilled'
  final String activeStatusFilter; // 'الكل', 'معلق', 'جزئي', 'مدفوع'
  final InvoicesDateRange activeDateRange;
  final String? selectedUnbilledPatientId;
  final DateTime? customStartDate;
  final DateTime? customEndDate;
  final String searchQuery;
  final String? errorMessage;
  final String? successMessage;

  const InvoicesState({
    this.status = InvoicesStatus.initial,
    this.invoices = const [],
    this.filteredInvoices = const [],
    this.unbilledAppointments = const [],
    this.filteredUnbilledAppointments = const [],
    this.patientUnpaidAppointments = const [],
    this.activeTab = 'invoices',
    this.activeStatusFilter = 'الكل',
    this.activeDateRange = InvoicesDateRange.all,
    this.selectedUnbilledPatientId,
    this.customStartDate,
    this.customEndDate,
    this.searchQuery = '',
    this.errorMessage,
    this.successMessage,
  });

  /// استخراج المرضى الجدد غير المكررين من قائمة الزيارات غير المفوترة بدون تكرار
  List<({String id, String name})> get availableUnbilledPatients {
    final Map<String, String> map = {};
    for (final appt in unbilledAppointments) {
      if (appt.patientId.isNotEmpty &&
          appt.patientName != null &&
          appt.patientName!.trim().isNotEmpty) {
        map[appt.patientId] = appt.patientName!.trim();
      }
    }
    return map.entries.map((e) => (id: e.key, name: e.value)).toList();
  }

  /// حساب إجمالي الإيرادات المسجلة (المبالغ المحصلة فعلياً) للفواتير المفلترة
  double get totalRevenue =>
      filteredInvoices.fold(0.0, (sum, inv) => sum + inv.paidAmount);

  /// حساب إجمالي المبالغ المعلقة المتأخرة للفواتير المفلترة مع مراعاة الفواتير المتعددة لنفس الموعد
  double get totalPending {
    final Map<String, List<InvoiceEntity>> grouped = {};
    final List<InvoiceEntity> nonAppointmentInvoices = [];

    for (final inv in filteredInvoices) {
      if (inv.sourceType == 'appointment' && inv.sourceId.isNotEmpty) {
        grouped.putIfAbsent(inv.sourceId, () => []).add(inv);
      } else {
        nonAppointmentInvoices.add(inv);
      }
    }

    double pending = 0.0;
    for (final entry in grouped.entries) {
      final list = entry.value;
      if (list.isEmpty) continue;

      final visitPrice = list.first.totalAmount;
      final totalPaid = list.fold<double>(0.0, (sum, inv) => sum + inv.paidAmount);
      final remaining = (visitPrice - totalPaid) > 0 ? (visitPrice - totalPaid) : 0.0;
      pending += remaining;
    }

    for (final inv in nonAppointmentInvoices) {
      pending += inv.remainingAmount;
    }

    return pending;
  }

  /// حساب إجمالي المستحقات غير المفوترة (المواعيد التي تمت ولم تُسجل لها فواتير بالكامل)
  double get unbilledTotalAmount {
    return filteredUnbilledAppointments.fold(
      0.0,
      (sum, appt) => sum + (appt.expectedPrice - appt.paidSoFar),
    );
  }

  InvoicesState copyWith({
    InvoicesStatus? status,
    List<InvoiceEntity>? invoices,
    List<InvoiceEntity>? filteredInvoices,
    List<UnpaidAppointmentEntity>? unbilledAppointments,
    List<UnpaidAppointmentEntity>? filteredUnbilledAppointments,
    List<UnpaidAppointmentEntity>? patientUnpaidAppointments,
    String? activeTab,
    String? activeStatusFilter,
    InvoicesDateRange? activeDateRange,
    Object? selectedUnbilledPatientId = _undefined,
    DateTime? customStartDate,
    DateTime? customEndDate,
    String? searchQuery,
    String? errorMessage,
    String? successMessage,
  }) {
    return InvoicesState(
      status: status ?? this.status,
      invoices: invoices ?? this.invoices,
      filteredInvoices: filteredInvoices ?? this.filteredInvoices,
      unbilledAppointments: unbilledAppointments ?? this.unbilledAppointments,
      filteredUnbilledAppointments:
          filteredUnbilledAppointments ?? this.filteredUnbilledAppointments,
      patientUnpaidAppointments:
          patientUnpaidAppointments ?? this.patientUnpaidAppointments,
      activeTab: activeTab ?? this.activeTab,
      activeStatusFilter: activeStatusFilter ?? this.activeStatusFilter,
      activeDateRange: activeDateRange ?? this.activeDateRange,
      selectedUnbilledPatientId: selectedUnbilledPatientId == _undefined
          ? this.selectedUnbilledPatientId
          : selectedUnbilledPatientId as String?,
      customStartDate: customStartDate ?? this.customStartDate,
      customEndDate: customEndDate ?? this.customEndDate,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        invoices,
        filteredInvoices,
        unbilledAppointments,
        filteredUnbilledAppointments,
        patientUnpaidAppointments,
        activeTab,
        activeStatusFilter,
        activeDateRange,
        selectedUnbilledPatientId,
        customStartDate,
        customEndDate,
        searchQuery,
        errorMessage,
        successMessage,
      ];
}

const Object _undefined = Object();

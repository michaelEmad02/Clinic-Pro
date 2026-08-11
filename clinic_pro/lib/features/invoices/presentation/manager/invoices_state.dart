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
  final List<UnpaidAppointmentEntity> patientUnpaidAppointments;
  final String activeStatusFilter; // 'الكل', 'معلق', 'جزئي', 'مدفوع'
  final InvoicesDateRange activeDateRange;
  final DateTime? customStartDate;
  final DateTime? customEndDate;
  final String searchQuery;
  final String? errorMessage;
  final String? successMessage;

  const InvoicesState({
    this.status = InvoicesStatus.initial,
    this.invoices = const [],
    this.filteredInvoices = const [],
    this.patientUnpaidAppointments = const [],
    this.activeStatusFilter = 'الكل',
    this.activeDateRange = InvoicesDateRange.all,
    this.customStartDate,
    this.customEndDate,
    this.searchQuery = '',
    this.errorMessage,
    this.successMessage,
  });

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

  InvoicesState copyWith({
    InvoicesStatus? status,
    List<InvoiceEntity>? invoices,
    List<InvoiceEntity>? filteredInvoices,
    List<UnpaidAppointmentEntity>? patientUnpaidAppointments,
    String? activeStatusFilter,
    InvoicesDateRange? activeDateRange,
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
      patientUnpaidAppointments:
          patientUnpaidAppointments ?? this.patientUnpaidAppointments,
      activeStatusFilter: activeStatusFilter ?? this.activeStatusFilter,
      activeDateRange: activeDateRange ?? this.activeDateRange,
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
        patientUnpaidAppointments,
        activeStatusFilter,
        activeDateRange,
        customStartDate,
        customEndDate,
        searchQuery,
        errorMessage,
        successMessage,
      ];
}

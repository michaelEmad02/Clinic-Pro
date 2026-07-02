// ────────────────────────────────────────────────────────
// حالات شاشة الفواتير — نماذج InvoiceItem وفلاترها
// ────────────────────────────────────────────────────────

import 'package:equatable/equatable.dart';

enum InvoiceFilter { all, paid, pending, partial }

class InvoiceItem extends Equatable {
  final String id;
  final String clinicId;
  final String patientId;
  final String patientName;
  final String appointmentType;
  final String sourceId;
  final String sourceType;
  final double totalAmount;
  final double paidAmount;
  final String? paymentMethod;
  final String createdAt;
  final String createdBy;

  const InvoiceItem({
    required this.id,
    this.clinicId = 'c-1',
    required this.patientId,
    required this.patientName,
    required this.appointmentType,
    required this.sourceId,
    this.sourceType = 'appointment',
    required this.totalAmount,
    required this.paidAmount,
    this.paymentMethod,
    required this.createdAt,
    required this.createdBy,
  });

  String get status {
    if (paidAmount <= 0) return 'pending';
    if (paidAmount < totalAmount) return 'partial';
    return 'paid';
  }

  String get statusLabel {
    switch (status) {
      case 'paid':
        return 'مدفوع';
      case 'pending':
        return 'معلق';
      case 'partial':
        return 'جزئي';
      default:
        return status;
    }
  }

  String get paymentMethodLabel {
    switch (paymentMethod) {
      case 'cash':
        return 'نقدي';
      case 'card':
        return 'بطاقة';
      case 'bank':
        return 'تحويل بنكي';
      default:
        return '—';
    }
  }

  String get formattedDate {
    final date = DateTime.tryParse(createdAt);
    if (date == null) return createdAt;
    final months = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  InvoiceItem copyWith({
    double? totalAmount,
    double? paidAmount,
    String? paymentMethod,
  }) {
    return InvoiceItem(
      id: id,
      clinicId: clinicId,
      patientId: patientId,
      patientName: patientName,
      appointmentType: appointmentType,
      sourceId: sourceId,
      sourceType: sourceType,
      totalAmount: totalAmount ?? this.totalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      createdAt: createdAt,
      createdBy: createdBy,
    );
  }

  @override
  List<Object?> get props =>
      [id, clinicId, patientName, totalAmount, paidAmount, status, sourceType];
}

enum InvoicesDateRange { today, thisWeek, thisMonth, threeMonths, custom, all }

abstract class InvoicesState extends Equatable {
  const InvoicesState();
  @override
  List<Object?> get props => [];
}

class InvoicesInitial extends InvoicesState {}

class InvoicesLoading extends InvoicesState {}

class InvoicesLoaded extends InvoicesState {
  final List<InvoiceItem> allInvoices;
  final InvoiceFilter activeFilter;
  final InvoicesDateRange activeRange;
  final DateTime? customStart;
  final DateTime? customEnd;

  const InvoicesLoaded({
    required this.allInvoices,
    this.activeFilter = InvoiceFilter.all,
    this.activeRange = InvoicesDateRange.thisMonth,
    this.customStart,
    this.customEnd,
  });

  List<InvoiceItem> get filteredInvoices {
    final now = DateTime.now();
    DateTime start;
    DateTime end = DateTime.now();

    switch (activeRange) {
      case InvoicesDateRange.today:
        start = DateTime(now.year, now.month, now.day);
        break;
      case InvoicesDateRange.thisWeek:
        start = now.subtract(const Duration(days: 7));
        break;
      case InvoicesDateRange.thisMonth:
        start = DateTime(now.year, now.month, 1);
        break;
      case InvoicesDateRange.threeMonths:
        start = now.subtract(const Duration(days: 90));
        break;
      case InvoicesDateRange.custom:
        start = customStart ?? DateTime(2000);
        end = customEnd ?? DateTime.now();
        break;
      case InvoicesDateRange.all:
        start = DateTime(2000);
        break;
    }

    final dateFiltered = allInvoices.where((inv) {
      final date = DateTime.tryParse(inv.createdAt);
      if (date == null) return true;
      return date.isAfter(start.subtract(const Duration(seconds: 1))) &&
          date.isBefore(end.add(const Duration(days: 1)));
    }).toList();

    switch (activeFilter) {
      case InvoiceFilter.all:
        return dateFiltered;
      case InvoiceFilter.paid:
        return dateFiltered.where((inv) => inv.status == 'paid').toList();
      case InvoiceFilter.pending:
        return dateFiltered.where((inv) => inv.status == 'pending').toList();
      case InvoiceFilter.partial:
        return dateFiltered.where((inv) => inv.status == 'partial').toList();
    }
  }

  double get todayRevenue {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    return allInvoices
        .where((inv) =>
            inv.status == 'paid' &&
            inv.createdAt.startsWith(today))
        .fold(0.0, (sum, inv) => sum + inv.paidAmount);
  }

  int get pendingCount =>
      allInvoices.where((inv) => inv.status == 'pending').length;

  double get monthRevenue {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1)
        .toIso8601String()
        .substring(0, 10);
    return allInvoices
        .where((inv) =>
            inv.status == 'paid' && inv.createdAt.compareTo(monthStart) >= 0)
        .fold(0.0, (sum, inv) => sum + inv.paidAmount);
  }

  InvoicesLoaded copyWith({
    List<InvoiceItem>? allInvoices,
    InvoiceFilter? activeFilter,
    InvoicesDateRange? activeRange,
    DateTime? customStart,
    DateTime? customEnd,
  }) {
    return InvoicesLoaded(
      allInvoices: allInvoices ?? this.allInvoices,
      activeFilter: activeFilter ?? this.activeFilter,
      activeRange: activeRange ?? this.activeRange,
      customStart: customStart ?? this.customStart,
      customEnd: customEnd ?? this.customEnd,
    );
  }

  @override
  List<Object?> get props => [
        allInvoices,
        activeFilter,
        activeRange,
        customStart,
        customEnd,
      ];
}

class InvoicesError extends InvoicesState {
  final String message;
  const InvoicesError(this.message);
  @override
  List<Object?> get props => [message];
}

// ────────────────────────────────────────────────────────
// حالات شاشة المواعيد — تحتوي على نموذج AppointmentItem
// ────────────────────────────────────────────────────────

import 'package:equatable/equatable.dart';

/// تبويبات شاشة المواعيد: اليوم / القادمة / السجل
enum AppointmentsTab { today, upcoming, history }

/// نموذج موعد للعرض في واجهة المستخدم (UI Phase — Mock)
class AppointmentItem extends Equatable {
  final String id;
  final String patientId;
  final String patientName;
  final String patientPhone;
  final String doctorId;
  final String doctorName;
  final String typeId;
  final String typeName;
  final String date;
  final String displayTime;
  final String status;
  final double price;
  final bool isUrgent;
  final String? notes;
  final DateTime? arrivedAt;
  final DateTime? calledAt;
  final bool hasPrescription;
  final bool hasInvoice;
  final String? prescriptionDiagnosis;
  final String? invoiceAmount;
  final String? invoiceStatus;
  final String? invoiceNumber;

  const AppointmentItem({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.patientPhone,
    required this.doctorId,
    required this.doctorName,
    required this.typeId,
    required this.typeName,
    required this.date,
    required this.displayTime,
    required this.status,
    required this.price,
    required this.isUrgent,
    this.notes,
    this.arrivedAt,
    this.calledAt,
    this.hasPrescription = false,
    this.hasInvoice = false,
    this.prescriptionDiagnosis,
    this.invoiceAmount,
    this.invoiceStatus,
    this.invoiceNumber,
  });

  AppointmentItem copyWith({
    String? status,
    bool? isUrgent,
    DateTime? arrivedAt,
    DateTime? calledAt,
    bool? hasPrescription,
    bool? hasInvoice,
  }) {
    return AppointmentItem(
      id: id,
      patientId: patientId,
      patientName: patientName,
      patientPhone: patientPhone,
      doctorId: doctorId,
      doctorName: doctorName,
      typeId: typeId,
      typeName: typeName,
      date: date,
      displayTime: displayTime,
      status: status ?? this.status,
      price: price,
      isUrgent: isUrgent ?? this.isUrgent,
      notes: notes,
      arrivedAt: arrivedAt ?? this.arrivedAt,
      calledAt: calledAt ?? this.calledAt,
      hasPrescription: hasPrescription ?? this.hasPrescription,
      hasInvoice: hasInvoice ?? this.hasInvoice,
      prescriptionDiagnosis: prescriptionDiagnosis,
      invoiceAmount: invoiceAmount,
      invoiceStatus: invoiceStatus,
    );
  }

  @override
  List<Object?> get props => [id, status, isUrgent, arrivedAt, calledAt];
}

abstract class AppointmentsState extends Equatable {
  const AppointmentsState();

  @override
  List<Object?> get props => [];
}

class AppointmentsInitial extends AppointmentsState {}

class AppointmentsLoading extends AppointmentsState {}

class AppointmentsLoaded extends AppointmentsState {
  final List<AppointmentItem> allAppointments;
  final AppointmentsTab activeTab;
  final String statusFilter;

  const AppointmentsLoaded({
    required this.allAppointments,
    this.activeTab = AppointmentsTab.today,
    this.statusFilter = 'all',
  });

  /// فلترة المواعيد حسب التبويب النشط
  List<AppointmentItem> get filteredAppointments {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    List<AppointmentItem> base;

    switch (activeTab) {
      case AppointmentsTab.today:
        base = allAppointments.where((a) => a.date == today).toList();
      case AppointmentsTab.upcoming:
        base = allAppointments
            .where((a) => a.date.compareTo(today) > 0 && a.status != 'cancelled')
            .toList();
      case AppointmentsTab.history:
        base = allAppointments
            .where((a) => a.date.compareTo(today) < 0 || a.status == 'done' || a.status == 'cancelled')
            .where((a) => a.date != today || a.status == 'done' || a.status == 'cancelled')
            .toList();
    }

    if (statusFilter == 'all') return base;
    return base.where((a) => a.status == statusFilter).toList();
  }

  AppointmentsLoaded copyWith({
    List<AppointmentItem>? allAppointments,
    AppointmentsTab? activeTab,
    String? statusFilter,
  }) {
    return AppointmentsLoaded(
      allAppointments: allAppointments ?? this.allAppointments,
      activeTab: activeTab ?? this.activeTab,
      statusFilter: statusFilter ?? this.statusFilter,
    );
  }

  @override
  List<Object?> get props => [allAppointments, activeTab, statusFilter];
}

class AppointmentsError extends AppointmentsState {
  final String message;

  const AppointmentsError(this.message);

  @override
  List<Object?> get props => [message];
}

class AppointmentsActionSuccess extends AppointmentsState {
  final String message;
  final AppointmentsLoaded previousState;

  const AppointmentsActionSuccess({
    required this.message,
    required this.previousState,
  });

  @override
  List<Object?> get props => [message, previousState];
}

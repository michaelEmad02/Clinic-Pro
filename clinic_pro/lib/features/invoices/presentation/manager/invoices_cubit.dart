// ────────────────────────────────────────────────────────
// InvoicesCubit — Cubit إدارة واجهات الفواتير وفق المعمارية النظيفة
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/features/appointments/domain/entities/appointment_entity.dart';
import 'package:clinic_pro/features/appointments/domain/usecases/appointments/get_appointment_by_id_usecase.dart';
import 'package:clinic_pro/features/invoices/domain/entities/invoice_entity.dart';
import 'package:clinic_pro/features/invoices/domain/usecases/create_invoice_usecase.dart';
import 'package:clinic_pro/features/invoices/domain/usecases/delete_invoice_usecase.dart';
import 'package:clinic_pro/features/invoices/domain/usecases/get_invoices_usecase.dart';
import 'package:clinic_pro/features/invoices/domain/usecases/get_patient_unpaid_appointments_usecase.dart';
import 'package:clinic_pro/features/invoices/domain/usecases/update_invoice_usecase.dart';
import 'package:clinic_pro/features/patients/domain/entities/patient_entity.dart';
import 'package:clinic_pro/features/patients/domain/usecases/find_patient_by_id_usecase.dart';
import 'package:clinic_pro/features/patients/domain/usecases/load_patients_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'invoices_state.dart';

@injectable
class InvoicesCubit extends Cubit<InvoicesState> {
  final GetInvoicesUseCase _getInvoicesUseCase;
  final CreateInvoiceUseCase _createInvoiceUseCase;
  final UpdateInvoiceUseCase _updateInvoiceUseCase;
  final DeleteInvoiceUseCase _deleteInvoiceUseCase;
  final GetPatientUnpaidAppointmentsUseCase
      _getPatientUnpaidAppointmentsUseCase;
  final FindPatientByIdUseCase _findPatientByIdUseCase;
  final GetAppointmentByIdUseCase _getAppointmentByIdUseCase;
  final LoadPatientsUseCase _loadPatientsUseCase;

  InvoicesCubit(
    this._getInvoicesUseCase,
    this._createInvoiceUseCase,
    this._updateInvoiceUseCase,
    this._deleteInvoiceUseCase,
    this._getPatientUnpaidAppointmentsUseCase,
    this._findPatientByIdUseCase,
    this._getAppointmentByIdUseCase,
    this._loadPatientsUseCase,
  ) : super(const InvoicesState());

  /// تحميل جميع الفواتير الخاصة بالعيادة
  Future<void> loadInvoices(String clinicId) async {
    emit(state.copyWith(status: InvoicesStatus.loading));

    final result = await _getInvoicesUseCase(clinicId);

    result.fold(
      (failure) => emit(state.copyWith(
        status: InvoicesStatus.failure,
        errorMessage: failure.message,
      )),
      (invoices) {
        emit(state.copyWith(
          status: InvoicesStatus.success,
          invoices: invoices,
        ));
        _applyFilters();
      },
    );
  }

  /// فلترة الفواتير بحسب الحالة أو نطاق التواريخ أو نص البحث
  void filterInvoices({
    String? statusFilter,
    InvoicesDateRange? dateRange,
    DateTime? customStart,
    DateTime? customEnd,
    String? search,
  }) {
    emit(state.copyWith(
      activeStatusFilter: statusFilter ?? state.activeStatusFilter,
      activeDateRange: dateRange ?? state.activeDateRange,
      customStartDate: customStart ?? state.customStartDate,
      customEndDate: customEnd ?? state.customEndDate,
      searchQuery: search ?? state.searchQuery,
    ));
    _applyFilters();
  }

  void _applyFilters() {
    List<InvoiceEntity> result = List.from(state.invoices);

    // 1. تطبيق فلتر نطاق التاريخ
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    switch (state.activeDateRange) {
      case InvoicesDateRange.today:
        result = result.where((inv) => inv.createdAt.isAfter(todayStart) || inv.createdAt.isAtSameMomentAs(todayStart)).toList();
        break;
      case InvoicesDateRange.thisWeek:
        // بداية الأسبوع يوم السبت (Saturday = 6, Sunday = 7, Monday = 1, ... Friday = 5)
        final int daysFromSaturday = (now.weekday == DateTime.saturday)
            ? 0
            : (now.weekday == DateTime.sunday ? 1 : now.weekday + 1);
        final weekStart = todayStart.subtract(Duration(days: daysFromSaturday));
        result = result.where((inv) => inv.createdAt.isAfter(weekStart) || inv.createdAt.isAtSameMomentAs(weekStart)).toList();
        break;
      case InvoicesDateRange.thisMonth:
        final monthStart = DateTime(now.year, now.month, 1);
        result = result.where((inv) => inv.createdAt.isAfter(monthStart)).toList();
        break;
      case InvoicesDateRange.threeMonths:
        final threeMonthsAgo = DateTime(now.year, now.month - 3, now.day);
        result = result.where((inv) => inv.createdAt.isAfter(threeMonthsAgo)).toList();
        break;
      case InvoicesDateRange.custom:
        if (state.customStartDate != null && state.customEndDate != null) {
          final start = DateTime(state.customStartDate!.year, state.customStartDate!.month, state.customStartDate!.day);
          final end = DateTime(state.customEndDate!.year, state.customEndDate!.month, state.customEndDate!.day, 23, 59, 59);
          result = result.where((inv) => inv.createdAt.isAfter(start) && inv.createdAt.isBefore(end)).toList();
        }
        break;
      case InvoicesDateRange.all:
      default:
        break;
    }

    // 2. تطبيق فلتر الحالة
    if (state.activeStatusFilter != 'الكل') {
      result = result.where((inv) {
        return inv.statusArabic == state.activeStatusFilter;
      }).toList();
    }

    // 3. تطبيق البحث باسم المريض أو رقم الفاتورة
    if (state.searchQuery.trim().isNotEmpty) {
      final q = state.searchQuery.trim().toLowerCase();
      result = result.where((inv) {
        final nameMatch =
            inv.patientName?.toLowerCase().contains(q) ?? false;
        final idMatch = inv.id.toLowerCase().contains(q);
        return nameMatch || idMatch;
      }).toList();
    }

    emit(state.copyWith(filteredInvoices: result));
  }

  /// جلب المواعيد غير المدفوعة بالكامل لمريض محدد
  Future<void> loadPatientUnpaidAppointments(String patientId) async {
    final result = await _getPatientUnpaidAppointmentsUseCase(patientId);
    result.fold(
      (_) => emit(state.copyWith(patientUnpaidAppointments: const [])),
      (appointments) =>
          emit(state.copyWith(patientUnpaidAppointments: appointments)),
    );
  }

  /// إنشاء فاتورة جديدة
  Future<bool> createInvoice({
    required String clinicId,
    required String patientId,
    required String sourceId,
    required double totalAmount,
    required double paidAmount,
    String? paymentMethod,
    required String createdBy,
  }) async {
    emit(state.copyWith(status: InvoicesStatus.saving));

    final result = await _createInvoiceUseCase(
      clinicId: clinicId,
      patientId: patientId,
      sourceId: sourceId,
      totalAmount: totalAmount,
      paidAmount: paidAmount,
      paymentMethod: paymentMethod,
      createdBy: createdBy,
    );

    return result.fold(
      (failure) {
        emit(state.copyWith(
          status: InvoicesStatus.failure,
          errorMessage: failure.message,
        ));
        return false;
      },
      (_) {
        emit(state.copyWith(
          status: InvoicesStatus.success,
          successMessage: 'تم إنشاء الفاتورة بنجاح',
        ));
        loadInvoices(clinicId);
        return true;
      },
    );
  }

  /// تعديل فاتورة
  Future<bool> updateInvoice(InvoiceEntity invoice) async {
    emit(state.copyWith(status: InvoicesStatus.saving));

    final result = await _updateInvoiceUseCase(invoice);

    return result.fold(
      (failure) {
        emit(state.copyWith(
          status: InvoicesStatus.failure,
          errorMessage: failure.message,
        ));
        return false;
      },
      (_) {
        emit(state.copyWith(
          status: InvoicesStatus.success,
          successMessage: 'تم تعديل الفاتورة بنجاح',
        ));
        loadInvoices(invoice.clinicId);
        return true;
      },
    );
  }

  /// حذف فاتورة
  Future<bool> deleteInvoice(String invoiceId, String clinicId) async {
    emit(state.copyWith(status: InvoicesStatus.deleting));

    final result = await _deleteInvoiceUseCase(invoiceId);

    return result.fold(
      (failure) {
        emit(state.copyWith(
          status: InvoicesStatus.failure,
          errorMessage: failure.message,
        ));
        return false;
      },
      (_) {
        emit(state.copyWith(
          status: InvoicesStatus.success,
          successMessage: 'تم حذف الفاتورة بنجاح',
        ));
        loadInvoices(clinicId);
        return true;
      },
    );
  }

  /// جلب بيانات مريض محدد بمعرفه
  Future<PatientEntity?> getPatientById(String patientId) async {
    final result = await _findPatientByIdUseCase(patientId);
    return result.fold(
      (_) => null,
      (patient) => patient,
    );
  }

  /// جلب موعد محدد بمعرفه
  Future<AppointmentEntity?> getAppointmentById(String appointmentId) async {
    final result = await _getAppointmentByIdUseCase(appointmentId);
    return result.fold(
      (_) => null,
      (appointment) => appointment,
    );
  }

  /// تحميل كل مرضى العيادة لغرض البحث
  Future<List<PatientEntity>> loadPatientsForClinic(String clinicId) async {
    final result = await _loadPatientsUseCase(clinicId: clinicId);
    return result.fold(
      (_) => const [],
      (patients) => patients,
    );
  }
}

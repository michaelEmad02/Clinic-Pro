// ────────────────────────────────────────────────────────
// Cubit شاشة الفواتير — تحميل وإضافة وتعديل عبر المستودع
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/strings/app_strings.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'invoices_state.dart';
import 'invoices_repository.dart';

@injectable
class InvoicesCubit extends Cubit<InvoicesState> {
  final InvoicesRepository _repository;

  InvoicesCubit(this._repository) : super(InvoicesInitial());

  Future<void> loadInvoices() async {
    emit(InvoicesLoading());
    try {
      final items = await _repository.loadInvoices();
      emit(InvoicesLoaded(allInvoices: _mapInvoices(items)));
    } catch (_) {
      emit(InvoicesError(AppStrings.loadFailedMsg));
    }
  }

  void changeFilter(InvoiceFilter filter) {
    if (state is InvoicesLoaded) {
      emit((state as InvoicesLoaded).copyWith(activeFilter: filter));
    }
  }

  void changeDateRange(InvoicesDateRange range,
      {DateTime? start, DateTime? end}) {
    if (state is InvoicesLoaded) {
      emit((state as InvoicesLoaded).copyWith(
        activeRange: range,
        customStart: start,
        customEnd: end,
      ));
    }
  }

  Future<void> createInvoice({
    required String patientId,
    required String patientName,
    required String appointmentType,
    required String sourceId,
    required double totalAmount,
    required double paidAmount,
    String? paymentMethod,
  }) async {
    if (state is! InvoicesLoaded) return;
    final loaded = state as InvoicesLoaded;

    try {
      await _repository.createInvoice(
        patientId: patientId,
        patientName: patientName,
        appointmentType: appointmentType,
        sourceId: sourceId,
        totalAmount: totalAmount,
        paidAmount: paidAmount,
        paymentMethod: paymentMethod,
      );
      // إعادة تحميل الفواتير لتحديث القائمة مع الحفاظ على الفلتر
      final items = await _repository.loadInvoices();
      emit(loaded.copyWith(allInvoices: _mapInvoices(items)));
    } catch (_) {
      emit(InvoicesError(AppStrings.loadFailedMsg));
    }
  }

  Future<void> updatePaidAmount({
    required String invoiceId,
    required double newPaidAmount,
    String? paymentMethod,
  }) async {
    if (state is! InvoicesLoaded) return;
    final loaded = state as InvoicesLoaded;

    try {
      await _repository.updatePaidAmount(
        invoiceId: invoiceId,
        newPaidAmount: newPaidAmount,
        paymentMethod: paymentMethod,
      );
      // إعادة تحميل الفواتير لتحديث القائمة مع الحفاظ على الفلتر
      final items = await _repository.loadInvoices();
      emit(loaded.copyWith(allInvoices: _mapInvoices(items)));
    } catch (_) {
      emit(InvoicesError(AppStrings.loadFailedMsg));
    }
  }

  /// تحديث بيانات فاتورة قائمة بالكامل
  Future<void> updateInvoice({
    required String invoiceId,
    required double totalAmount,
    required double paidAmount,
    String? paymentMethod,
  }) async {
    if (state is! InvoicesLoaded) return;
    final loaded = state as InvoicesLoaded;

    try {
      await _repository.updateInvoice(
        invoiceId: invoiceId,
        totalAmount: totalAmount,
        paidAmount: paidAmount,
        paymentMethod: paymentMethod,
      );
      // إعادة تحميل الفواتير
      final items = await _repository.loadInvoices();
      emit(loaded.copyWith(allInvoices: _mapInvoices(items)));
    } catch (_) {
      emit(InvoicesError(AppStrings.loadFailedMsg));
    }
  }

  /// البحث عن المرضى عبر المستودع
  Future<List<Map<String, dynamic>>> searchPatients(String query) async {
    try {
      final patients = await _repository.loadPatients();
      if (query.isEmpty) return patients;
      final q = query.trim().toLowerCase();
      return patients.where((p) {
        final name = (p['name'] as String).toLowerCase();
        final phone = (p['phone'] as String);
        return name.contains(q) || phone.contains(q);
      }).toList();
    } catch (_) {
      return [];
    }
  }

  /// تحميل مواعيد المريض المنتهية وغير المفوترة بعد
  Future<List<Map<String, dynamic>>> loadPatientAppointments(
      String patientId) async {
    try {
      return await _repository.loadAppointmentsForPatient(patientId);
    } catch (_) {
      return [];
    }
  }

  /// جلب تفاصيل موعد محدد
  Future<Map<String, dynamic>?> getAppointmentDetails(
      String appointmentId) async {
    try {
      return await _repository.getAppointment(appointmentId);
    } catch (_) {
      return null;
    }
  }

  /// جلب تفاصيل مريض محدد
  Future<Map<String, dynamic>?> getPatientDetails(String patientId) async {
    try {
      return await _repository.getPatient(patientId);
    } catch (_) {
      return null;
    }
  }

  /// حذف الفاتورة نهائياً وإعادة تحميل القائمة
  Future<void> deleteInvoice(String invoiceId) async {
    if (state is! InvoicesLoaded) return;
    final loaded = state as InvoicesLoaded;
    try {
      await _repository.deleteInvoice(invoiceId);
      final items = await _repository.loadInvoices();
      emit(loaded.copyWith(allInvoices: _mapInvoices(items)));
    } catch (_) {
      emit(InvoicesError(AppStrings.loadFailedMsg));
    }
  }

  List<InvoiceItem> _mapInvoices(List<Map<String, dynamic>> rawList) {
    return rawList.map((inv) {
      return InvoiceItem(
        id: inv['id'] as String,
        clinicId: inv['clinic_id'] as String? ?? 'c-1',
        patientId: inv['patient_id'] as String,
        patientName: inv['patient_name'] as String,
        appointmentType: inv['appointment_type'] as String,
        sourceId: inv['source_id'] as String,
        sourceType: inv['source_type'] as String? ?? 'appointment',
        totalAmount: (inv['total_amount'] as num).toDouble(),
        paidAmount: (inv['paid_amount'] as num).toDouble(),
        paymentMethod: inv['payment_method'] as String?,
        createdAt: inv['created_at'] as String,
        createdBy: inv['created_by'] as String,
      );
    }).toList();
  }
}

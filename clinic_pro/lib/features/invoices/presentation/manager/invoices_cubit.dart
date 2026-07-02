// ────────────────────────────────────────────────────────
// Cubit شاشة الفواتير — تحميل وإضافة وتعديل عبر المستودع
// ────────────────────────────────────────────────────────

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
      emit(const InvoicesError('تعذّر تحميل الفواتير'));
    }
  }

  void changeFilter(InvoiceFilter filter) {
    if (state is InvoicesLoaded) {
      emit((state as InvoicesLoaded).copyWith(activeFilter: filter));
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
      emit(const InvoicesError('تعذّر إنشاء الفاتورة'));
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
      emit(const InvoicesError('تعذّر تحديث مبلغ الفاتورة'));
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

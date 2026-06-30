// ────────────────────────────────────────────────────────
// Cubit شاشة الفواتير — تحميل وإضافة وتعديل (Mock)
// ────────────────────────────────────────────────────────

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/mocks/mock_data.dart';
import 'invoices_state.dart';

class InvoicesCubit extends Cubit<InvoicesState> {
  InvoicesCubit() : super(InvoicesInitial());

  Future<void> loadInvoices() async {
    emit(InvoicesLoading());
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final items = _mapInvoicesFromMock();
      emit(InvoicesLoaded(allInvoices: items));
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
    await Future.delayed(const Duration(milliseconds: 400));

    final newInvoice = InvoiceItem(
      id: 'inv-new-${DateTime.now().millisecondsSinceEpoch}',
      clinicId: 'c-1',
      patientId: patientId,
      patientName: patientName,
      appointmentType: appointmentType,
      sourceId: sourceId,
      sourceType: 'appointment',
      totalAmount: totalAmount,
      paidAmount: paidAmount,
      paymentMethod: paymentMethod,
      createdAt: DateTime.now().toIso8601String(),
      createdBy: 'u-sec-1',
    );

    emit(loaded.copyWith(
        allInvoices: [newInvoice, ...loaded.allInvoices]));
  }

  Future<void> updatePaidAmount({
    required String invoiceId,
    required double newPaidAmount,
    String? paymentMethod,
  }) async {
    if (state is! InvoicesLoaded) return;
    final loaded = state as InvoicesLoaded;
    await Future.delayed(const Duration(milliseconds: 300));

    final list = loaded.allInvoices.map((inv) {
      if (inv.id != invoiceId) return inv;
      return inv.copyWith(
        paidAmount: newPaidAmount,
        paymentMethod: paymentMethod ?? inv.paymentMethod,
      );
    }).toList();

    emit(loaded.copyWith(allInvoices: list));
  }

  List<InvoiceItem> _mapInvoicesFromMock() {
    return MockData.invoices.map((inv) {
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

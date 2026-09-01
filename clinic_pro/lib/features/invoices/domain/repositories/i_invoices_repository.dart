// ────────────────────────────────────────────────────────
// IInvoicesRepository — واجهة مستودع الفواتير بـ Domain Layer
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/error/failures.dart';
import 'package:clinic_pro/features/invoices/domain/entities/invoice_entity.dart';
import 'package:clinic_pro/features/invoices/domain/entities/unpaid_appointment_entity.dart';
import 'package:dartz/dartz.dart';

abstract class IInvoicesRepository {
  /// جلب جميع الفواتير لعيادة معينة (مع فلترة الطبيب إن وُجد)
  Future<Either<Failure, List<InvoiceEntity>>> getInvoices(String clinicId, {String? doctorId});

  /// إنشاء فاتورة جديدة
  Future<Either<Failure, InvoiceEntity>> createInvoice({
    required String clinicId,
    required String patientId,
    String? doctorId,
    required String sourceId,
    required double totalAmount,
    required double paidAmount,
    String? paymentMethod,
    required String createdBy,
  });

  /// تعديل مبالغ أو وسيلة دفع الفاتورة
  Future<Either<Failure, Unit>> updateInvoice(InvoiceEntity invoice);

  /// حذف فاتورة
  Future<Either<Failure, Unit>> deleteInvoice(String invoiceId);

  /// جلب المواعيد غير المدفوعة بالكامل لمريض محدد
  Future<Either<Failure, List<UnpaidAppointmentEntity>>>
      getPatientUnpaidAppointments(String patientId);
}

// ────────────────────────────────────────────────────────
// CreateInvoiceUseCase — إنشاء فاتورة جديدة مع إجراء التحققات
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/error/failures.dart';
import 'package:clinic_pro/core/error/query_failure.dart';
import 'package:clinic_pro/features/invoices/domain/repositories/i_invoices_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@injectable
class CreateInvoiceUseCase {
  final IInvoicesRepository _repository;

  CreateInvoiceUseCase(this._repository);

  Future<Either<Failure, Unit>> call({
    required String clinicId,
    required String patientId,
    required String sourceId,
    required double totalAmount,
    required double paidAmount,
    String? paymentMethod,
    required String createdBy,
  }) {
    if (patientId.isEmpty) {
      return Future.value(const Left(UnknownQueryFailure(message: 'يرجى اختيار المريض')));
    }
    if (sourceId.isEmpty) {
      return Future.value(const Left(UnknownQueryFailure(message: 'يرجى اختيار الموعد المرتبط بالفاتورة')));
    }
    if (totalAmount <= 0) {
      return Future.value(const Left(UnknownQueryFailure(message: 'يجب أن يكون المبلغ الإجمالي أكبر من الصفر')));
    }
    if (paidAmount < 0) {
      return Future.value(const Left(UnknownQueryFailure(message: 'المبلغ المدفوع لا يمكن أن يكون بالسالب')));
    }
    if (paidAmount > totalAmount) {
      return Future.value(const Left(UnknownQueryFailure(message: 'المبلغ المدفوع لا يمكن أن يتجاوز المبلغ الإجمالي')));
    }

    return _repository.createInvoice(
      clinicId: clinicId,
      patientId: patientId,
      sourceId: sourceId,
      totalAmount: totalAmount,
      paidAmount: paidAmount,
      paymentMethod: paymentMethod,
      createdBy: createdBy,
    );
  }
}

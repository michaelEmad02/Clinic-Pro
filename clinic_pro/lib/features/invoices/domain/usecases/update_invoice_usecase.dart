// ────────────────────────────────────────────────────────
// UpdateInvoiceUseCase — تعديل فاتورة قائمة
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/error/failures.dart';
import 'package:clinic_pro/core/error/query_failure.dart';
import 'package:clinic_pro/features/invoices/domain/entities/invoice_entity.dart';
import 'package:clinic_pro/features/invoices/domain/repositories/i_invoices_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@injectable
class UpdateInvoiceUseCase {
  final IInvoicesRepository _repository;

  UpdateInvoiceUseCase(this._repository);

  Future<Either<Failure, Unit>> call(InvoiceEntity invoice) {
    if (invoice.totalAmount <= 0) {
      return Future.value(const Left(UnknownQueryFailure(message: 'يجب أن يكون المبلغ الإجمالي أكبر من الصفر')));
    }
    if (invoice.paidAmount < 0) {
      return Future.value(const Left(UnknownQueryFailure(message: 'المبلغ المدفوع لا يمكن أن يكون بالسالب')));
    }
    if (invoice.paidAmount > invoice.totalAmount) {
      return Future.value(const Left(UnknownQueryFailure(message: 'المبلغ المدفوع لا يمكن أن يتجاوز المبلغ الإجمالي')));
    }

    return _repository.updateInvoice(invoice);
  }
}

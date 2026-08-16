// ────────────────────────────────────────────────────────
// DeleteInvoiceUseCase — حذف فاتورة مسجلة
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/error/failures.dart';
import 'package:clinic_pro/core/error/query_failure.dart';
import 'package:clinic_pro/features/invoices/domain/repositories/i_invoices_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@injectable
class DeleteInvoiceUseCase {
  final IInvoicesRepository _repository;

  DeleteInvoiceUseCase(this._repository);

  Future<Either<Failure, Unit>> call(String invoiceId) {
    if (invoiceId.isEmpty) {
      return Future.value(const Left(UnknownQueryFailure(message: 'رقم الفاتورة غير صحيح')));
    }
    return _repository.deleteInvoice(invoiceId);
  }
}

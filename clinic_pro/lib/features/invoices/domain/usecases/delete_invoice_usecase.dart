// ────────────────────────────────────────────────────────
// DeleteInvoiceUseCase — حذف فاتورة مسجلة
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/error/failures.dart';
import 'package:clinic_pro/core/strings/failure_strings.dart';
import 'package:clinic_pro/features/invoices/domain/repositories/i_invoices_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@injectable
class DeleteInvoiceUseCase {
  final IInvoicesRepository _repository;

  DeleteInvoiceUseCase(this._repository);

  Future<Either<Failure, Unit>> call(String invoiceId) {
    if (invoiceId.isEmpty) {
      return Future.value(const Left(InvalidInvoiceIdFailure()));
    }
    return _repository.deleteInvoice(invoiceId);
  }
}

class InvalidInvoiceIdFailure extends Failure {
  const InvalidInvoiceIdFailure([super.customMessage]);

  @override
  String get defaultMessage => FailureStrings.invalidInvoiceId;
}

// ────────────────────────────────────────────────────────
// GetInvoicesUseCase — جلب قائمة الفواتير لعيادة معينة
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/error/failures.dart';
import 'package:clinic_pro/features/invoices/domain/entities/invoice_entity.dart';
import 'package:clinic_pro/features/invoices/domain/repositories/i_invoices_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetInvoicesUseCase {
  final IInvoicesRepository _repository;

  GetInvoicesUseCase(this._repository);

  Future<Either<Failure, List<InvoiceEntity>>> call(String clinicId, {String? doctorId}) {
    return _repository.getInvoices(clinicId, doctorId: doctorId);
  }
}

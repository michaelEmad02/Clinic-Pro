// ────────────────────────────────────────────────────────
// CreateInvoiceUseCase — إنشاء فاتورة جديدة مع إجراء التحققات
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/error/failures.dart';
import 'package:clinic_pro/core/strings/failure_strings.dart';
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
      return Future.value(const Left(SelectPatientRequiredFailure()));
    }
    if (sourceId.isEmpty) {
      return Future.value(const Left(SelectSourceAppointmentRequiredFailure()));
    }
    if (totalAmount <= 0) {
      return Future.value(const Left(TotalAmountMustBePositiveFailure()));
    }
    if (paidAmount < 0) {
      return Future.value(const Left(PaidAmountCannotBeNegativeFailure()));
    }
    if (paidAmount > totalAmount) {
      return Future.value(const Left(PaidCannotExceedTotalFailure()));
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

class SelectPatientRequiredFailure extends Failure {
  const SelectPatientRequiredFailure([super.customMessage]);

  @override
  String get defaultMessage => FailureStrings.selectPatientRequired;
}

class SelectSourceAppointmentRequiredFailure extends Failure {
  const SelectSourceAppointmentRequiredFailure([super.customMessage]);

  @override
  String get defaultMessage => FailureStrings.selectSourceAppointmentRequired;
}

class TotalAmountMustBePositiveFailure extends Failure {
  const TotalAmountMustBePositiveFailure([super.customMessage]);

  @override
  String get defaultMessage => FailureStrings.totalAmountMustBePositive;
}

class PaidAmountCannotBeNegativeFailure extends Failure {
  const PaidAmountCannotBeNegativeFailure([super.customMessage]);

  @override
  String get defaultMessage => FailureStrings.paidAmountCannotBeNegative;
}

class PaidCannotExceedTotalFailure extends Failure {
  const PaidCannotExceedTotalFailure([super.customMessage]);

  @override
  String get defaultMessage => FailureStrings.paidCannotExceedTotal;
}

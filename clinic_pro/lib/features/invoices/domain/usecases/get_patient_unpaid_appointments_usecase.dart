// ────────────────────────────────────────────────────────
// GetPatientUnpaidAppointmentsUseCase — جلب مواعيد المريض غير المدفوعة بالكامل
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/error/failures.dart';
import 'package:clinic_pro/core/error/query_failure.dart';
import 'package:clinic_pro/features/invoices/domain/entities/unpaid_appointment_entity.dart';
import 'package:clinic_pro/features/invoices/domain/repositories/i_invoices_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetPatientUnpaidAppointmentsUseCase {
  final IInvoicesRepository _repository;

  GetPatientUnpaidAppointmentsUseCase(this._repository);

  Future<Either<Failure, List<UnpaidAppointmentEntity>>> call(String patientId) {
    if (patientId.isEmpty) {
      return Future.value(const Left(UnknownQueryFailure(message: 'رقم المريض غير صحيح')));
    }
    return _repository.getPatientUnpaidAppointments(patientId);
  }
}

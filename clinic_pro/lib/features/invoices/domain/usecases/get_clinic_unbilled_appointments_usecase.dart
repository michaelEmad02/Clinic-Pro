// ────────────────────────────────────────────────────────
// GetClinicUnbilledAppointmentsUseCase — استخدام جلب المواعيد غير المفوترة للعيادة
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/error/failures.dart';
import 'package:clinic_pro/features/invoices/domain/entities/unpaid_appointment_entity.dart';
import 'package:clinic_pro/features/invoices/domain/repositories/i_invoices_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class GetClinicUnbilledAppointmentsUseCase {
  final IInvoicesRepository _repository;

  GetClinicUnbilledAppointmentsUseCase(this._repository);

  Future<Either<Failure, List<UnpaidAppointmentEntity>>> call(
    String clinicId, {
    String? doctorId,
  }) async {
    return await _repository.getClinicUnbilledAppointments(
      clinicId,
      doctorId: doctorId,
    );
  }
}

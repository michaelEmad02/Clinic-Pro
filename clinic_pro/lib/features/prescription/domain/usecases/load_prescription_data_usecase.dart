// ────────────────────────────────────────────────────────
// حالة استخدام تحميل بيانات الروشتة (LoadPrescriptionDataUseCase)
// ────────────────────────────────────────────────────────

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/prescription_load_data_entity.dart';
import '../repositories/i_prescription_repository.dart';

@injectable
class LoadPrescriptionDataUseCase {
  final IPrescriptionRepository _repository;

  LoadPrescriptionDataUseCase(this._repository);

  Future<Either<Failure, PrescriptionLoadDataEntity>> call(
    String appointmentId,
    String doctorId,
  ) {
    return _repository.getPrescriptionData(appointmentId, doctorId);
  }
}

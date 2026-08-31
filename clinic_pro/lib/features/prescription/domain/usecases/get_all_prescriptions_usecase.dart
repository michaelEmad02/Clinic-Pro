// ────────────────────────────────────────────────────────
// حالة استخدام جلب كل الروشتات (GetAllPrescriptionsUseCase)
// تتبع الـ Prescription Feature وتجلب الروشتات مع دعم الفلترة
// ────────────────────────────────────────────────────────

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/prescription_entity.dart';
import '../repositories/i_prescription_repository.dart';

@injectable
class GetAllPrescriptionsUseCase {
  final IPrescriptionRepository _repository;

  GetAllPrescriptionsUseCase(this._repository);

  Future<Either<Failure, List<PrescriptionEntity>>> call({
    String? clinicId,
    String? doctorId,
  }) {
    return _repository.getAllPrescriptions(
      clinicId: clinicId,
      doctorId: doctorId,
    );
  }
}

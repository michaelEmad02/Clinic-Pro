// ─────────────────────────────────────────
// UseCase جلب قائمة ملخص العيادات النشطة
// ─────────────────────────────────────────

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/clinic_summary_entity.dart';
import '../repositories/i_owner_dashboard_repository.dart';

@lazySingleton
class GetOwnerClinicsOverviewUseCase {
  final IOwnerDashboardRepository _repository;

  GetOwnerClinicsOverviewUseCase(this._repository);

  Future<Either<Failure, List<ClinicSummaryEntity>>> call(
    String ownerId, {
    bool forceRefresh = false,
  }) {
    return _repository.getClinicsOverview(
      ownerId,
      forceRefresh: forceRefresh,
    );
  }
}

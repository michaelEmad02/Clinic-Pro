// ─────────────────────────────────────────
// UseCase جلب إحصائيات الملخص الكلية لـ Owner Dashboard
// ─────────────────────────────────────────

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/owner_summary_stats_entity.dart';
import '../repositories/i_owner_dashboard_repository.dart';

@lazySingleton
class GetOwnerSummaryStatsUseCase {
  final IOwnerDashboardRepository _repository;

  GetOwnerSummaryStatsUseCase(this._repository);

  Future<Either<Failure, OwnerSummaryStatsEntity>> call(
    String ownerId, {
    bool forceRefresh = false,
  }) {
    return _repository.getSummaryStats(
      ownerId,
      forceRefresh: forceRefresh,
    );
  }
}

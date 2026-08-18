// ─────────────────────────────────────────
// UseCase جلب إيرادات الأسبوع للمخطط البياني
// ─────────────────────────────────────────

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/i_owner_dashboard_repository.dart';

@lazySingleton
class GetOwnerWeeklyRevenueUseCase {
  final IOwnerDashboardRepository _repository;

  GetOwnerWeeklyRevenueUseCase(this._repository);

  Future<Either<Failure, List<double>>> call(
    String ownerId, {
    bool forceRefresh = false,
  }) {
    return _repository.getWeeklyRevenue(
      ownerId,
      forceRefresh: forceRefresh,
    );
  }
}

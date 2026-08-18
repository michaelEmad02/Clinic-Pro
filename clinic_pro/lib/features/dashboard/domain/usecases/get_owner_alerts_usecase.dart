// ─────────────────────────────────────────
// UseCase جلب التنبيهات الذكية الخاصة بالمالك
// ─────────────────────────────────────────

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/dashboard_alert_entity.dart';
import '../repositories/i_owner_dashboard_repository.dart';

@lazySingleton
class GetOwnerAlertsUseCase {
  final IOwnerDashboardRepository _repository;

  GetOwnerAlertsUseCase(this._repository);

  Future<Either<Failure, List<DashboardAlertEntity>>> call(
    String ownerId, {
    bool forceRefresh = false,
  }) {
    return _repository.getAlerts(
      ownerId,
      forceRefresh: forceRefresh,
    );
  }
}

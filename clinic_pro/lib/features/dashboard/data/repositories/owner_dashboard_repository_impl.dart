// ─────────────────────────────────────────
// تنفيذ مستودع لوحة تحكم المالك (Data Layer)
// يحوي 4 دوال مستقلة ترجع نتائج إما Failure أو Entity مخصصة
// ─────────────────────────────────────────

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:clinic_pro/core/error/failures.dart';
import 'package:clinic_pro/core/error/query_failure.dart';
import '../../domain/entities/owner_summary_stats_entity.dart';
import '../../domain/entities/clinic_summary_entity.dart';
import '../../domain/entities/dashboard_alert_entity.dart';
import '../../domain/repositories/i_owner_dashboard_repository.dart';
import '../datasources/i_owner_dashboard_remote_data_source.dart';

@LazySingleton(as: IOwnerDashboardRepository)
class OwnerDashboardRepositoryImpl implements IOwnerDashboardRepository {
  final IOwnerDashboardRemoteDataSource _remoteDataSource;

  OwnerDashboardRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, OwnerSummaryStatsEntity>> getSummaryStats(
    String ownerId, {
    bool forceRefresh = false,
  }) async {
    try {
      final stats = await _remoteDataSource.fetchSummaryStats(
        ownerId,
        forceRefresh: forceRefresh,
      );
      return Right(stats);
    } catch (e) {
      return Left(QueryFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, List<double>>> getWeeklyRevenue(
    String ownerId, {
    bool forceRefresh = false,
  }) async {
    try {
      final revenue = await _remoteDataSource.fetchWeeklyRevenue(
        ownerId,
        forceRefresh: forceRefresh,
      );
      return Right(revenue);
    } catch (e) {
      return Left(QueryFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, List<ClinicSummaryEntity>>> getClinicsOverview(
    String ownerId, {
    bool forceRefresh = false,
  }) async {
    try {
      final clinics = await _remoteDataSource.fetchClinicsOverview(
        ownerId,
        forceRefresh: forceRefresh,
      );
      return Right(clinics);
    } catch (e) {
      return Left(QueryFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, List<DashboardAlertEntity>>> getAlerts(
    String ownerId, {
    bool forceRefresh = false,
  }) async {
    try {
      final alerts = await _remoteDataSource.fetchAlerts(
        ownerId,
        forceRefresh: forceRefresh,
      );
      return Right(alerts);
    } catch (e) {
      return Left(QueryFailure.fromException(e));
    }
  }
}

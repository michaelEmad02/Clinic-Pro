// ────────────────────────────────────────────────────────
// تطبيق المستودع لخاصية الخطط والاشتراكات (SubscriptionsRepositoryImpl)
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/error/query_failure.dart';
import 'package:clinic_pro/features/plans_and_subscriptions/data/models/subscription_model.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/company_info_entity.dart';
import '../../domain/entities/plan_entity.dart';
import '../../domain/entities/subscription_entity.dart';
import '../../domain/repositories/i_subscriptions_repository.dart';
import '../data_sources/subscriptions_remote_data_source.dart';

import '../../domain/entities/subscription_usage_entity.dart';

@LazySingleton(as: ISubscriptionsRepository)
class SubscriptionsRepositoryImpl implements ISubscriptionsRepository {
  final ISubscriptionsRemoteDataSource _remoteDataSource;

  SubscriptionsRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<PlanEntity>>> getPlans() async {
    try {
      final plans = await _remoteDataSource.getPlans();
      return Right(plans);
    } catch (e) {
      return Left(QueryFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, SubscriptionEntity?>> getActiveSubscription(String ownerId) async {
    try {
      final subscription = await _remoteDataSource.getActiveSubscription(ownerId);
      return Right(subscription);
    } catch (e) {
      return Left(QueryFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, SubscriptionEntity>> requestSubscription({
    required String ownerId,
  }) async {
    try {
      final result = await _remoteDataSource.requestSubscription(
        ownerId: ownerId,
      );
      return Right(result);
    } catch (e) {
      return Left(QueryFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, void>> updateSubscriptionStatus({
    required String subscriptionId,
    required String status,
  }) async {
    try {
      await _remoteDataSource.updateSubscriptionStatus(subscriptionId, status);
      return const Right(null);
    } catch (e) {
      return Left(QueryFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, SubscriptionUsageEntity>> getSubscriptionUsage(
      String ownerId) async {
    try {
      final rawUsage = await _remoteDataSource.getSubscriptionUsage(ownerId);

      final usageEntity = SubscriptionUsageEntity(
        clinicsCount: rawUsage['clinicsCount'] ?? 0,
        staffCount: rawUsage['staffCount'] ?? 0,
        patientsCount: rawUsage['patientsCount'] ?? 0,
      );

      return Right(usageEntity);
    } catch (e) {
      return Left(QueryFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, CompanyInfoEntity>> getCompanyInfo() async {
    try {
      final companyInfo = await _remoteDataSource.getCompanyInfo();
      return Right(companyInfo);
    } catch (e) {
      return Left(QueryFailure.fromException(e));
    }
  }
}

// ────────────────────────────────────────────────────────
// حالات جلب الخطط والاشتراكات (UseCases)
// ────────────────────────────────────────────────────────

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/company_info_entity.dart';
import '../entities/plan_entity.dart';
import '../entities/subscription_entity.dart';
import '../entities/subscription_usage_entity.dart';
import '../repositories/i_subscriptions_repository.dart';

@lazySingleton
class GetPlansUseCase {
  final ISubscriptionsRepository _repository;
  GetPlansUseCase(this._repository);

  Future<Either<Failure, List<PlanEntity>>> call() {
    return _repository.getPlans();
  }
}

@lazySingleton
class GetActiveSubscriptionUseCase {
  final ISubscriptionsRepository _repository;
  GetActiveSubscriptionUseCase(this._repository);

  Future<Either<Failure, SubscriptionEntity?>> call(String ownerId) {
    return _repository.getActiveSubscription(ownerId);
  }
}

@lazySingleton
class CheckSubscriptionStatusUseCase {
  final ISubscriptionsRepository _repository;
  CheckSubscriptionStatusUseCase(this._repository);

  Future<Either<Failure, SubscriptionEntity?>> call(String ownerId) async {
    final result = await _repository.getActiveSubscription(ownerId);
    return result.fold(
      (failure) => Left(failure),
      (subscription) async {
        if (subscription == null) return const Right(null);

        // التحقق مما إذا كان الاشتراك المفعل قد تخطى تاريخ الانتهاء
        if (subscription.isActive && subscription.endAt != null) {
          if (DateTime.now().isAfter(subscription.endAt!)) {
            // انقضى التاريخ -> تحديث الحالة في الداتا بيز إلى expired
            await _repository.updateSubscriptionStatus(
              subscriptionId: subscription.id,
              status: 'expired',
            );
            // إرجاع كائن محدث بحالة expired
            return Right(SubscriptionEntity(
              id: subscription.id,
              ownerId: subscription.ownerId,
              planId: subscription.planId,
              subscriptionType: subscription.subscriptionType,
              status: 'expired',
              startedAt: subscription.startedAt,
              endAt: subscription.endAt,
              createdAt: subscription.createdAt,
            ));
          }
        }
        return Right(subscription);
      },
    );
  }
}

@lazySingleton
class RequestSubscriptionUseCase {
  final ISubscriptionsRepository _repository;
  RequestSubscriptionUseCase(this._repository);

  Future<Either<Failure, SubscriptionEntity>> call({
    required String ownerId,
  }) {
    return _repository.requestSubscription(
      ownerId: ownerId,
    );
  }
}


@lazySingleton
class GetCompanyInfoUseCase {
  final ISubscriptionsRepository _repository;
  GetCompanyInfoUseCase(this._repository);

  Future<Either<Failure, CompanyInfoEntity>> call() {
    return _repository.getCompanyInfo();
  }
}

@lazySingleton
class GetSubscriptionUsageUseCase {
  final ISubscriptionsRepository _repository;
  GetSubscriptionUsageUseCase(this._repository);

  Future<Either<Failure, SubscriptionUsageEntity>> call(String ownerId) {
    return _repository.getSubscriptionUsage(ownerId);
  }
}

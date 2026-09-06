// ────────────────────────────────────────────────────────
// حالات جلب الخطط والاشتراكات (UseCases)
// ────────────────────────────────────────────────────────

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/billing_history_item_entity.dart';
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

  Future<Either<Failure, SubscriptionEntity?>> call(String ownerId) {
    // التحقق يتم مركزياً وسيرفرياً بالكامل داخل get_active_subscription_rpc
    // السيرفر يتحقق من تاريخ الصلاحية ويحدث الحالة إلى expired تلقائياً بتوقيت السيرفر
    return _repository.getActiveSubscription(ownerId);
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

@lazySingleton
class GetBillingHistoryUseCase {
  final ISubscriptionsRepository _repository;
  GetBillingHistoryUseCase(this._repository);

  Future<Either<Failure, List<BillingHistoryItemEntity>>> call(String ownerId) {
    return _repository.getBillingHistory(ownerId);
  }
}


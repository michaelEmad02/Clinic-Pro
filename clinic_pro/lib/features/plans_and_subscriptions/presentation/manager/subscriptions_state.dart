// ────────────────────────────────────────────────────────
// حالات Cubit لإدارة الخطط والاشتراكات (SubscriptionsState)
// ────────────────────────────────────────────────────────

import '../../domain/entities/billing_history_item_entity.dart';
import '../../domain/entities/company_info_entity.dart';
import '../../domain/entities/plan_entity.dart';
import '../../domain/entities/subscription_entity.dart';
import '../../domain/entities/subscription_usage_entity.dart';

abstract class SubscriptionsState {
  const SubscriptionsState();
}

class SubscriptionsInitial extends SubscriptionsState {}

class SubscriptionsLoading extends SubscriptionsState {}

class SubscriptionsLoaded extends SubscriptionsState {
  final List<PlanEntity> plans;
  final SubscriptionEntity? activeSubscription;
  final CompanyInfoEntity? companyInfo;
  final SubscriptionUsageEntity? usage;
  final List<BillingHistoryItemEntity> billingHistory;

  const SubscriptionsLoaded({
    required this.plans,
    this.activeSubscription,
    this.companyInfo,
    this.usage,
    this.billingHistory = const [],
  });
}

class SubscriptionPendingCreated extends SubscriptionsState {
  final SubscriptionEntity subscription;
  final PlanEntity? plan;
  final CompanyInfoEntity companyInfo;

  const SubscriptionPendingCreated({
    required this.subscription,
    required this.plan,
    required this.companyInfo,
  });
}

class SubscriptionsError extends SubscriptionsState {
  final String message;
  const SubscriptionsError(this.message);
}

// ────────────────────────────────────────────────────────
// كيان سجل الفاتورة والاشتراك (BillingHistoryItemEntity)
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/features/plans_and_subscriptions/domain/entities/plan_entity.dart';
import 'package:clinic_pro/features/plans_and_subscriptions/domain/entities/subscription_entity.dart';

class BillingHistoryItemEntity {
  final SubscriptionEntity subscription;
  final PlanEntity? plan;
  final double? originalAmount;
  final double? paidAmount;
  final double? discountAmount;
  final String? couponCode;
  final String? paymentMethod;
  final String? transactionStatus;
  final String? transactionId;

  const BillingHistoryItemEntity({
    required this.subscription,
    this.plan,
    this.originalAmount,
    this.paidAmount,
    this.discountAmount,
    this.couponCode,
    this.paymentMethod,
    this.transactionStatus,
    this.transactionId,
  });
}

// ────────────────────────────────────────────────────────
// تطبيق المستودع لخاصية الخطط والاشتراكات (SubscriptionsRepositoryImpl)
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/error/query_failure.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/billing_history_item_entity.dart';
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

  @override
  Future<Either<Failure, List<BillingHistoryItemEntity>>> getBillingHistory(
      String ownerId) async {
    try {
      final subscriptions = await _remoteDataSource.getAllSubscriptions(ownerId);
      final plans = await _remoteDataSource.getPlans();
      final transactions = await _remoteDataSource.getPaymentTransactions(ownerId);

      final List<BillingHistoryItemEntity> history = [];

      for (final sub in subscriptions) {
        final plan = plans.firstWhere(
          (p) => p.id == sub.planId || p.name.toLowerCase() == sub.subscriptionType.toLowerCase(),
          orElse: () => plans.firstWhere(
            (p) => p.name.toLowerCase() == 'basic',
          ),
        );

        // محاولة إيجاد المعاملة المالية المرتبطة بهذا الاشتراك
        final txList = transactions.where((t) => t.subscriptionId == sub.id);
        final tx = txList.isNotEmpty ? txList.first : null;

        double? paidAmount;
        double? originalAmount;
        double? discountAmount;
        String? couponCode;
        String? paymentMethod = sub.paymentMethod;
        String? txStatus;
        String? txId;

        // حساب السعر الأصلي الافتراضي من الخطة
        if (sub.isTrial) {
          originalAmount = 0.0;
        } else if (sub.subscriptionType == 'yearly') {
          originalAmount = plan.yearlyPriceEgp > 0 ? plan.yearlyPriceEgp : plan.yearlyPrice;
        } else if (sub.subscriptionType == 'lifetime') {
          originalAmount = plan.lifetimePriceEgp > 0 ? plan.lifetimePriceEgp : plan.lifetimePrice;
        } else {
          originalAmount = plan.monthlyPriceEgp > 0 ? plan.monthlyPriceEgp : plan.monthlyPrice;
        }

        if (tx != null) {
          paidAmount = tx.amount;
          paymentMethod ??= tx.paymentMethod;
          txStatus = tx.status;
          txId = tx.id;

          // فحص حقل metadata داخل المعاملة
          final meta = tx.metadata;
          if (meta != null) {
            if (meta['final_amount'] != null) {
              paidAmount = (meta['final_amount'] as num?)?.toDouble() ?? paidAmount;
            }
            if (meta['original_amount'] != null) {
              originalAmount = (meta['original_amount'] as num?)?.toDouble() ?? originalAmount;
            }
            if (meta['discount_amount'] != null) {
              discountAmount = (meta['discount_amount'] as num?)?.toDouble();
            }
            if (meta['coupon_code'] != null) {
              couponCode = meta['coupon_code']?.toString();
            }
          }
        }

        // إذا لم توجد معاملة دفع وكان الاشتراك تجريبي أو عبر كوبون/مجاني أو نشط بدون معاملة نحدد المدفوع 0
        final isCouponOrFree = sub.isTrial ||
            paymentMethod == 'coupon' ||
            (tx == null && (sub.isActive || sub.isPending));

        if (paidAmount == null && isCouponOrFree) {
          paidAmount = 0.0;
        }

        history.add(BillingHistoryItemEntity(
          subscription: sub,
          plan: plan,
          originalAmount: originalAmount,
          paidAmount: paidAmount,
          discountAmount: discountAmount ?? (paidAmount == 0.0 ? originalAmount : null),
          couponCode: couponCode,
          paymentMethod: paymentMethod,
          transactionStatus: txStatus ?? (paidAmount == 0.0 ? 'success' : null),
          transactionId: txId,
        ));
      }

      return Right(history);
    } catch (e) {
      return Left(QueryFailure.fromException(e));
    }
  }
}

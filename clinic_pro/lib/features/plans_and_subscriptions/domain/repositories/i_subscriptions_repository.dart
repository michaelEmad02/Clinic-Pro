// ────────────────────────────────────────────────────────
// واجهة المستودع لخاصية الخطط والاشتراكات (ISubscriptionsRepository)
// ────────────────────────────────────────────────────────

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/company_info_entity.dart';
import '../entities/plan_entity.dart';
import '../entities/subscription_entity.dart';

import '../entities/subscription_usage_entity.dart';

abstract class ISubscriptionsRepository {
  /// جلب جميع الخطط المتاحة ومميزاتها
  Future<Either<Failure, List<PlanEntity>>> getPlans();

  /// جلب الاشتراك الحالي أو الأخير للمالك
  Future<Either<Failure, SubscriptionEntity?>> getActiveSubscription(
      String ownerId);

  /// طلب اشتراك جديد أو ترقية (إدراج سطر بحالة pending)
  Future<Either<Failure, SubscriptionEntity>> requestSubscription(
      SubscriptionEntity subscription);

  /// تحديث حالة اشتراك معين (مثلاً إلى expired)
  Future<Either<Failure, void>> updateSubscriptionStatus({
    required String subscriptionId,
    required String status,
  });

  /// جلب إحصائيات استخدام الخطة للمالك (عدد العيادات والموظفين والمرضى في كافة عيادات المالك)
  Future<Either<Failure, SubscriptionUsageEntity>> getSubscriptionUsage(
      String ownerId);

  /// جلب معلومات الاتصال بالشركة
  Future<Either<Failure, CompanyInfoEntity>> getCompanyInfo();
}

import 'package:clinic_pro/core/constants/supabase_constants.dart';
import 'package:clinic_pro/core/error/failures.dart';
import 'package:clinic_pro/core/error/query_failure.dart';
import 'package:clinic_pro/features/clinics/domain/entities/clinic_entity.dart';
import 'package:clinic_pro/features/clinics/domain/repositories/clinics_repository.dart';
import 'package:clinic_pro/features/plans_and_subscriptions/domain/entities/subscription_usage_entity.dart';
import 'package:clinic_pro/features/plans_and_subscriptions/domain/repositories/i_subscriptions_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@injectable
class AddClinicUseCase {
  final ClinicsRepository clinicsRepository;
  final ISubscriptionsRepository subscriptionsRepository;

  AddClinicUseCase({
    required this.clinicsRepository,
    required this.subscriptionsRepository,
  });

  Future<Either<Failure, String>> call(ClinicEntity clinic) async {
    // 1. التحقق من حدود البزنس (Business Rules) بداخل الـ UseCase
    final subResult = await subscriptionsRepository.getActiveSubscription(clinic.ownerId);
    final usageResult = await subscriptionsRepository.getSubscriptionUsage(clinic.ownerId);
    final plansResult = await subscriptionsRepository.getPlans();

    // 1. فحص حد العيادات المسموح به في خطة المالك بـ Domain
    if (subResult.isRight() && usageResult.isRight() && plansResult.isRight()) {
      try {
        final activeSub = subResult.getOrElse(() => null);
        final usage = usageResult.getOrElse(() => const SubscriptionUsageEntity(clinicsCount: 0, staffCount: 0, patientsCount: 0));
        final plans = plansResult.getOrElse(() => []);

        final planKey = activeSub?.subscriptionType.isNotEmpty == true
            ? activeSub!.subscriptionType
            : PlanName.basic;

        final currentPlan = plans.firstWhere(
          (p) =>
              (activeSub?.planId != null && activeSub?.planId.isNotEmpty == true && p.id == activeSub?.planId) ||
              p.name.toLowerCase() == planKey.toLowerCase(),
        );

        final maxClinics = currentPlan.features?.maxClinics ?? 1;

        // إذا كانت القيمة > 0 وتم الوصول للحد الأقصى المسموح به
        if (maxClinics > 0 && usage.clinicsCount >= maxClinics) {
          return const Left(
            PlanLimitQueryFailure(
              message: 'لقد وصلت للحد الأقصى المسموح به من العيادات في خطتك الحالية',
            ),
          );
        }
      } catch (e) {
        // حماية التطبيق من أي استثناء غير متوقع وتوجيهه لـ Failure سليم دون تدمير العملية
        return Left(
          UnknownQueryFailure(
            message: 'حدث خطأ: ${e.toString()}',
          ),
        );
      }
    }

    // 2. التنفيذ والإضافة بحالة استيفاء شروط البزنس
    return clinicsRepository.addClinic(clinic);
  }
}

import 'package:clinic_pro/core/constants/staff_roles.dart';
import 'package:clinic_pro/core/constants/supabase_constants.dart';
import 'package:clinic_pro/core/error/failures.dart';
import 'package:clinic_pro/core/error/query_failure.dart';
import 'package:clinic_pro/features/clinics/domain/repositories/clinics_repository.dart';
import 'package:clinic_pro/features/plans_and_subscriptions/domain/entities/subscription_usage_entity.dart';
import 'package:clinic_pro/features/plans_and_subscriptions/domain/repositories/i_subscriptions_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@injectable
class AddStaffUseCase {
  final ClinicsRepository clinicsRepository;
  final ISubscriptionsRepository subscriptionsRepository;

  AddStaffUseCase({
    required this.clinicsRepository,
    required this.subscriptionsRepository,
  });

  Future<Either<Failure, void>> call(
      String clinicId, String staffId, String? doctorId, StaffRoles role, String ownerId) async {
    // 1. التحقق من حد الموظفين المسموح به في خطة المالك
    if (ownerId.isNotEmpty) {
      final subResult = await subscriptionsRepository.getActiveSubscription(ownerId);
      final usageResult = await subscriptionsRepository.getSubscriptionUsage(ownerId);
      final plansResult = await subscriptionsRepository.getPlans();

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

          final maxStaff = currentPlan.features?.maxStaff ?? 2;

          if (maxStaff > 0 && usage.staffCount >= maxStaff) {
            return const Left(
              PlanLimitQueryFailure(
                message: 'لقد وصلت للحد الأقصى المسموح به من الموظفين في خطتك الحالية',
              ),
            );
          }
        } catch (e) {
          return Left(
            UnknownQueryFailure(
              message: 'حدث خطأ: ${e.toString()}',
            ),
          );
        }
      }
    }

    // 2. إكمال إضافة الموظف
    return clinicsRepository.addStaff(clinicId, staffId, doctorId, role);
  }
}

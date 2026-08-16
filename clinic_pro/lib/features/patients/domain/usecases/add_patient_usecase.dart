import 'package:clinic_pro/core/constants/supabase_constants.dart';
import 'package:clinic_pro/core/error/query_failure.dart';
import 'package:clinic_pro/features/plans_and_subscriptions/domain/entities/subscription_usage_entity.dart';
import 'package:clinic_pro/features/plans_and_subscriptions/domain/repositories/i_subscriptions_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/patient_entity.dart';
import '../repositories/i_patients_repository.dart';

@injectable
class AddPatientUseCase {
  final IPatientsRepository _repository;
  final ISubscriptionsRepository _subscriptionsRepository;

  AddPatientUseCase(
    this._repository,
    this._subscriptionsRepository,
  );

  Future<Either<Failure, PatientEntity>> call(PatientEntity patient, {String? ownerId}) async {
    // 1. فحص حد المرضى إذا تم تمرير ownerId الخاص بالمالك
    if (ownerId != null && ownerId.isNotEmpty) {
      final subResult = await _subscriptionsRepository.getActiveSubscription(ownerId);
      final usageResult = await _subscriptionsRepository.getSubscriptionUsage(ownerId);
      final plansResult = await _subscriptionsRepository.getPlans();

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

          final maxPatients = currentPlan.features?.maxPatients ?? 500;

          if (maxPatients > 0 && usage.patientsCount >= maxPatients) {
            return const Left(
              PlanLimitQueryFailure(
                message: 'لقد وصلت للحد الأقصى المسموح به من المرضى في خطتك الحالية',
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

    // 2. التحقق من صحة المدخلات الأساسية
    if (patient.name.trim().length < 2) {
      return const Left(
        AddPatientFailure('اسم المريض مطلوب ولا يقل عن حرفين'),
      );
    }

    if (patient.gender.isEmpty) {
      return const Left(
        AddPatientFailure('الجنس مطلوب لإضافة مريض'),
      );
    }

    if (patient.dateOfBirth != null && patient.dateOfBirth!.isNotEmpty) {
      final dob = DateTime.tryParse(patient.dateOfBirth!);
      if (dob != null && dob.isAfter(DateTime.now())) {
        return const Left(
          AddPatientFailure('تاريخ الميلاد يجب أن يكون في الماضي'),
        );
      }
    }

    return _repository.addPatient(patient);
  }
}

class AddPatientFailure extends Failure {
  const AddPatientFailure(super.message);
}

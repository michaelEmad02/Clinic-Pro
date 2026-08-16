// ────────────────────────────────────────────────────────
// إدارة حالات الخطط والاشتراكات (SubscriptionsCubit)
// ────────────────────────────────────────────────────────

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/company_info_entity.dart';
import '../../domain/entities/plan_entity.dart';
import '../../domain/entities/subscription_entity.dart';
import '../../domain/entities/subscription_usage_entity.dart';
import '../../domain/usecases/subscriptions_usecases.dart';
import 'subscriptions_state.dart';

@injectable
class SubscriptionsCubit extends Cubit<SubscriptionsState> {
  final GetPlansUseCase _getPlansUseCase;
  final CheckSubscriptionStatusUseCase _checkSubscriptionStatusUseCase;
  final RequestSubscriptionUseCase _requestSubscriptionUseCase;
  final GetCompanyInfoUseCase _getCompanyInfoUseCase;
  final GetSubscriptionUsageUseCase _getSubscriptionUsageUseCase;

  List<PlanEntity> _cachedPlans = [];
  SubscriptionEntity? _cachedSubscription;
  CompanyInfoEntity? _cachedCompanyInfo;
  SubscriptionUsageEntity? _cachedUsage;

  SubscriptionsCubit({
    required GetPlansUseCase getPlansUseCase,
    required CheckSubscriptionStatusUseCase checkSubscriptionStatusUseCase,
    required RequestSubscriptionUseCase requestSubscriptionUseCase,
    required GetCompanyInfoUseCase getCompanyInfoUseCase,
    required GetSubscriptionUsageUseCase getSubscriptionUsageUseCase,
  })  : _getPlansUseCase = getPlansUseCase,
        _checkSubscriptionStatusUseCase = checkSubscriptionStatusUseCase,
        _requestSubscriptionUseCase = requestSubscriptionUseCase,
        _getCompanyInfoUseCase = getCompanyInfoUseCase,
        _getSubscriptionUsageUseCase = getSubscriptionUsageUseCase,
        super(SubscriptionsInitial());

  /// تحميل بيانات الخطط والاشتراك الحالي ومعلومات الشركة والاستخدام بالتوازي لحفظ الأداء
  Future<void> loadSubscriptionsData(String ownerId) async {
    emit(SubscriptionsLoading());

    final results = await Future.wait([
      _getPlansUseCase(),
      _checkSubscriptionStatusUseCase(ownerId),
      _getCompanyInfoUseCase(),
      if (ownerId.isNotEmpty)
        _getSubscriptionUsageUseCase(ownerId)
      else
        Future.value(null),
    ]);

    final plansResult = results[0] as dynamic;
    final subResult = results[1] as dynamic;
    final companyResult = results[2] as dynamic;
    final usageResult = results[3];

    if (usageResult != null) {
      (usageResult as dynamic).fold(
        (_) => _cachedUsage = null,
        (u) => _cachedUsage = u,
      );
    }

    plansResult.fold(
      (failure) => emit(SubscriptionsError(failure.message)),
      (plans) {
        _cachedPlans = plans;
        subResult.fold(
          (_) => _cachedSubscription = null,
          (sub) => _cachedSubscription = sub,
        );
        companyResult.fold(
          (_) => _cachedCompanyInfo = null,
          (info) => _cachedCompanyInfo = info,
        );
        emit(SubscriptionsLoaded(
          plans: _cachedPlans,
          activeSubscription: _cachedSubscription,
          companyInfo: _cachedCompanyInfo,
          usage: _cachedUsage,
        ));
      },
    );
  }

  /// طلب اشتراك جديد أو ترقية
  Future<void> requestSubscription({
    required String ownerId,
    required PlanEntity targetPlan,
    required String subscriptionType,
  }) async {
    emit(SubscriptionsLoading());

    final result = await _requestSubscriptionUseCase(
      ownerId: ownerId,
      planId: targetPlan.id,
      subscriptionType: subscriptionType,
    );

    result.fold(
      (failure) => emit(SubscriptionsError(failure.message)),
      (newSubscription) {
        _cachedSubscription = newSubscription;
        final companyInfo = _cachedCompanyInfo ??
            const CompanyInfoEntity(
              id: 'default',
              name: 'Clinic Pro Support',
              phone1: '+201000000000',
              whatsApp1: '+201000000000',
            );

        emit(SubscriptionPendingCreated(
          subscription: newSubscription,
          plan: targetPlan,
          companyInfo: companyInfo,
        ));

        // إعادة العودة للحالة المحملة
        emit(SubscriptionsLoaded(
          plans: _cachedPlans,
          activeSubscription: _cachedSubscription,
          companyInfo: _cachedCompanyInfo,
          usage: _cachedUsage,
        ));
      },
    );
  }
}

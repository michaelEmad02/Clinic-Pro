// ────────────────────────────────────────────────────────
// شاشة موازنة واختيار الخطط لترقية/طلب الاشتراك (PlansComparisonScreen)
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/constants/supabase_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/strings/app_strings.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../auth/presentation/manager/auth_cubit.dart';
import 'widgets/plan_card.dart';
import '../../domain/entities/plan_entity.dart';
import '../../domain/entities/subscription_entity.dart';
import '../manager/subscriptions_cubit.dart';
import '../manager/subscriptions_state.dart';
import 'widgets/plan_confirmation_bottom_sheet.dart';

class PlansComparisonScreen extends StatelessWidget {
  final bool isOnboarding;
  const PlansComparisonScreen({super.key, this.isOnboarding = false});

  @override
  Widget build(BuildContext context) {
    final ownerId = context.read<AuthCubit>().state.user?.id ?? '';

    return BlocProvider(
      create: (_) => sl<SubscriptionsCubit>()..loadSubscriptionsData(ownerId),
      child: _PlansComparisonBody(isOnboarding: isOnboarding),
    );
  }
}

class _PlansComparisonBody extends StatefulWidget {
  final bool isOnboarding;
  const _PlansComparisonBody({this.isOnboarding = false});

  @override
  State<_PlansComparisonBody> createState() => _PlansComparisonBodyState();
}

class _PlansComparisonBodyState extends State<_PlansComparisonBody> {
  String _selectedCycle = SubscriptionType.monthly; // 'monthly', 'yearly', 'lifetime'

  int _cycleWeight(String type) {
    switch (type) {
      case SubscriptionType.yearly:
        return 2;
      case SubscriptionType.lifetime:
        return 3;
      case SubscriptionType.monthly:
      default:
        return 1;
    }
  }

  int _planWeight(String name) {
    final n = name.toLowerCase();
    if (n == PlanName.enterprise.toLowerCase()) return 3;
    if (n == PlanName.pro.toLowerCase()) return 2;
    return 1;
  }

  void _onSelectPlan(
    BuildContext context,
    PlanEntity selectedPlan,
    SubscriptionEntity? activeSub,
  ) {
    final ownerId = context.read<AuthCubit>().state.user?.id ?? '';

    // إذا كان المالك لديه اشتراك نشط ولم ينتهِ بعد
    if (activeSub != null && activeSub.isActive) {
      final isSamePlan = activeSub.planId.toLowerCase() == selectedPlan.id.toLowerCase() ||
          activeSub.planId.toLowerCase() == selectedPlan.name.toLowerCase();
      final currentCycleWeight = _cycleWeight(activeSub.subscriptionType);
      final selectedCycleWeight = _cycleWeight(_selectedCycle);
      final currentPlanWeight = _planWeight(activeSub.planId);
      final selectedPlanWeight = _planWeight(selectedPlan.name);

      // في حالة اختيار نفس الخطة ونفس الفوترة (محاولة تجديد قبل الانتهاء)
      if (isSamePlan && currentCycleWeight == selectedCycleWeight) {
      final endDateStr = activeSub.endAt != null
          ? '${activeSub.endAt!.day}/${activeSub.endAt!.month}/${activeSub.endAt!.year}'
          : AppStrings.notSpecified;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppStrings.activeUntil(endDateStr),
          ),
          backgroundColor: context.warningBg,
        ),
      );
      return;
    }

    final isUpgrade = selectedPlanWeight > currentPlanWeight ||
        (isSamePlan && selectedCycleWeight > currentCycleWeight);

    if (isUpgrade) {
      final remainingDays = activeSub.endAt != null
          ? activeSub.endAt!.difference(DateTime.now()).inDays
          : 0;

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppConstants.radiusSheet),
          ),
        ),
        builder: (_) => PlanConfirmationBottomSheet(
          targetPlan: selectedPlan,
          subscriptionType: _selectedCycle,
          isUpgrade: true,
          remainingDays: remainingDays < 0 ? 0 : remainingDays,
          onConfirm: () {
            context.read<SubscriptionsCubit>().requestSubscription(
                  ownerId: ownerId,
                  targetPlan: selectedPlan,
                  subscriptionType: _selectedCycle,
                );
          },
        ),
      );
      return;
    }

    final endDateStr = activeSub.endAt != null
        ? '${activeSub.endAt!.day}/${activeSub.endAt!.month}/${activeSub.endAt!.year}'
        : AppStrings.notSpecified;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppStrings.activePlanNoDowngrade(endDateStr),
        ),
        backgroundColor: context.warningText,
      ),
    );
    return;
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppConstants.radiusSheet),
      ),
    ),
    builder: (_) => PlanConfirmationBottomSheet(
      targetPlan: selectedPlan,
      subscriptionType: _selectedCycle,
      isUpgrade: false,
      remainingDays: 0,
      onConfirm: () {
        context.read<SubscriptionsCubit>().requestSubscription(
              ownerId: ownerId,
              targetPlan: selectedPlan,
              subscriptionType: _selectedCycle,
            );
      },
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    final ownerId = context.read<AuthCubit>().state.user?.id ?? '';

    return PopScope(
      canPop: !widget.isOnboarding,
      child: Scaffold(
        backgroundColor: context.backgroundColor,
        appBar: widget.isOnboarding
          ? null
          : AppBar(
              toolbarHeight: 64,
              backgroundColor: context.surfaceColor,
              elevation: 0,
              scrolledUnderElevation: 0,
              title: Text(
                AppStrings.plansAndSubscriptions,
                style: AppTextStyles.headlineMedium(context).copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.primary,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Container(color: context.borderColor, height: 1),
              ),
            ),
      body: BlocConsumer<SubscriptionsCubit, SubscriptionsState>(
        listener: (context, state) {
          if (state is SubscriptionPendingCreated) {
            if (state.subscription.isTrial) {
              context.go(RouteConstants.onboardingClinic);
            } else {
              context.go(
                RouteConstants.pendingSubscription,
                extra: {
                  'plan': state.plan,
                  'subscriptionType': state.subscription.subscriptionType,
                  'companyInfo': state.companyInfo,
                },
              );
            }
          } else if (state is SubscriptionsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is SubscriptionsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is SubscriptionsLoaded) {
            final plans = state.plans;
            final activeSub = state.activeSubscription;
            final isTrialUsed = activeSub != null;

            return ResponsiveHelper.responsiveCenter(
              maxWidth: 1024,
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppConstants.spaceLg),
                  child: Column(
                    children: [
                      Text(
                        AppStrings.choosePlanSubtitle,
                        style: AppTextStyles.headlineLarge(context),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppStrings.choosePlanDesc,
                        style: AppTextStyles.bodyLarge(context).copyWith(
                          color: context.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      // مفتاح دورة الفوترة: شهري | سنوي | مدى الحياة
                      Container(
                        decoration: BoxDecoration(
                          color: context.surfaceContainerLow.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(4),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildCycleButton(SubscriptionType.monthly, AppStrings.monthlyLabel),
                              _buildCycleButton(SubscriptionType.yearly, AppStrings.yearlyDiscount),
                              _buildCycleButton(SubscriptionType.lifetime, AppStrings.lifetimeLabel),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // عرض كروت الخطط (الخطة الحالية تظهر أولاً دائماً)
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth >= 768;
                          
                          final sortedPlans = List<PlanEntity>.from(plans);
                          if (activeSub != null && activeSub.isActive) {
                            sortedPlans.sort((a, b) {
                              final aIsCurrent = a.name.toLowerCase() == activeSub.planId.toLowerCase() ||
                                                 a.id.toLowerCase() == activeSub.planId.toLowerCase();
                              final bIsCurrent = b.name.toLowerCase() == activeSub.planId.toLowerCase() ||
                                                 b.id.toLowerCase() == activeSub.planId.toLowerCase();
                              if (aIsCurrent && !bIsCurrent) return -1;
                              if (!aIsCurrent && bIsCurrent) return 1;
                              return 0;
                            });
                          }

                          if (isWide) {
                            return IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: sortedPlans.map((plan) {
                                  return Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceSm),
                                      child: _buildPlanCardItem(context, plan, activeSub),
                                    ),
                                  );
                                }).toList(),
                              ),
                            );
                          }

                          return Column(
                            children: sortedPlans.map((plan) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: AppConstants.spaceLg),
                                child: _buildPlanCardItem(context, plan, activeSub),
                              );
                            }).toList(),
                          );
                        },
                      ),

                      const SizedBox(height: 32),

                      // زر تجربة 14 يوماً مجانية إذا لم يسبق له الاشتراك أو التجربة
                      if (!isTrialUsed) ...[
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 400),
                          child: ElevatedButton.icon(
                            onPressed: () {
                              final basicPlan = plans.firstWhere(
                                (p) => p.name.toLowerCase() == PlanName.basic.toLowerCase(),
                              );
                              context.read<SubscriptionsCubit>().requestSubscription(
                                    ownerId: ownerId,
                                    targetPlan: basicPlan,
                                    subscriptionType: SubscriptionType.trail,
                                  );
                            },
                            icon: const Icon(Icons.star_rounded, color: Colors.amber),
                            label: Flexible(
                              child: Text(
                                AppStrings.startFreeTrial14Days,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.primary,
                              foregroundColor: context.onPrimary,
                              minimumSize: const Size(double.infinity, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppConstants.radiusButton),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }

          return Center(
            child: ElevatedButton(
              onPressed: () => context
                  .read<SubscriptionsCubit>()
                  .loadSubscriptionsData(ownerId),
              child: Text(AppStrings.retry),
            ),
          );
        },
      ),
    ),
  );
}

  Widget _buildCycleButton(String key, String label) {
    final active = _selectedCycle == key;
    return GestureDetector(
      onTap: () => setState(() => _selectedCycle = key),
      child: Container(
        decoration: BoxDecoration(
          color: active ? context.surfaceColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(
          label,
          style: AppTextStyles.bodyMedium(context).copyWith(
            color: active ? context.primary : context.textSecondary,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ),
    );
  }

  Widget _buildPlanCardItem(
    BuildContext context,
    PlanEntity plan,
    SubscriptionEntity? activeSub,
  ) {
    double price = plan.monthlyPrice;
    String subText = AppStrings.perMonth;
    if (_selectedCycle == SubscriptionType.yearly) {
      price = plan.yearlyPrice;
      subText = AppStrings.perYear;
    } else if (_selectedCycle == SubscriptionType.lifetime) {
      price = plan.lifetimePrice;
      subText = AppStrings.lifetimeSuffix;
    }

    final isCurrentPlan = activeSub != null &&
        activeSub.isActive &&
        (activeSub.planId.toLowerCase() == plan.name.toLowerCase() ||
         activeSub.planId.toLowerCase() == plan.id.toLowerCase());

    final isSameCycle = activeSub != null && activeSub.subscriptionType == _selectedCycle;

    final isPro = plan.name.toLowerCase() == PlanName.pro.toLowerCase();

    String buttonText = AppStrings.requestSubscription;
    if (isCurrentPlan) {
      if (isSameCycle) {
        buttonText = AppStrings.renew;
      } else {
        buttonText = AppStrings.upgrade;
      }
    } else if (activeSub != null && activeSub.isActive) {
      buttonText = AppStrings.upgrade;
    }

    final List<PlanFeature> planFeaturesList = [];
    if (plan.features != null) {
      planFeaturesList.add(PlanFeature(text: AppStrings.supportClinics(plan.features!.maxClinics)));
      planFeaturesList.add(PlanFeature(text: AppStrings.supportStaff(plan.features!.maxStaff)));
      planFeaturesList.add(PlanFeature(text: AppStrings.supportPatients(plan.features!.maxPatients)));

      if (plan.features!.customFeatures != null) {
        final Map<String, dynamic> customFeats = plan.features!.customFeatures!;
        final isArabic = Localizations.localeOf(context).languageCode == 'ar';

        customFeats.forEach((key, val) {
          if (val is Map<String, dynamic>) {
            final String arbTitle = val['arb_title'] as String? ?? '';
            final String engTitle = val['eng_title'] as String? ?? '';
            final bool isIncluded = val['value'] as bool? ?? false;
            final String title = isArabic
                ? (arbTitle.isNotEmpty ? arbTitle : engTitle)
                : (engTitle.isNotEmpty ? engTitle : arbTitle);

            if (title.isNotEmpty) {
              planFeaturesList.add(
                PlanFeature(
                  text: title,
                  included: isIncluded,
                ),
              );
            }
          }
        });
      }
    }

    return PlanCard(
      title: plan.name.toUpperCase(),
      price: '\$${price.toInt()}',
      priceSubtext: subText,
      isFeatured: isPro,
      isCurrentPlan: isCurrentPlan,
      badgeText: isPro ? AppStrings.mostPopular : null,
      features: planFeaturesList,
      buttonText: buttonText,
      onSelect: () => _onSelectPlan(context, plan, activeSub),
    );
  }
}

// ────────────────────────────────────────────────────────
// شاشة اختيار الخطط والاشتراكات (PlanScreen)
// تعتمد على SubscriptionsCubit والبيانات الحقيقية بداخل داتا بيز Supabase
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/strings/app_strings.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../auth/presentation/manager/auth_cubit.dart';
import '../../../clinics/presentation/ui/widgets/progress_indicator_bar.dart';
import '../../../plans_and_subscriptions/domain/entities/plan_entity.dart';
import '../../../plans_and_subscriptions/domain/entities/subscription_entity.dart';
import '../../../plans_and_subscriptions/presentation/manager/subscriptions_cubit.dart';
import '../../../plans_and_subscriptions/presentation/manager/subscriptions_state.dart';
import '../../../plans_and_subscriptions/presentation/ui/widgets/upgrade_confirmation_dialog.dart';
import '../../../plans_and_subscriptions/presentation/ui/widgets/plan_card.dart';

class PlanScreen extends StatelessWidget {
  const PlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ownerId = context.read<AuthCubit>().state.user?.id ?? '';

    return BlocProvider(
      create: (_) => sl<SubscriptionsCubit>()..loadSubscriptionsData(ownerId),
      child: const _PlanScreenBody(),
    );
  }
}

class _PlanScreenBody extends StatefulWidget {
  const _PlanScreenBody();

  @override
  State<_PlanScreenBody> createState() => _PlanScreenBodyState();
}

class _PlanScreenBodyState extends State<_PlanScreenBody> {
  String _selectedBillingCycle = 'monthly'; // 'monthly', 'yearly', 'lifetime'
  PlanEntity? _selectedPlan;

  void _onConfirmSubscriptionRequest(
    BuildContext context,
    PlanEntity plan,
    SubscriptionEntity? activeSub, {
    bool isTrial = false,
  }) {
    final ownerId = context.read<AuthCubit>().state.user?.id ?? '';

    final cycle = isTrial ? 'trail' : _selectedBillingCycle;

    // إذا كان المالك يملك اشتراكاً نشطاً بالفعل
    if (activeSub != null && activeSub.isActive) {
      if (activeSub.planId == plan.id) {
        final endDateStr = activeSub.endAt != null
            ? '${activeSub.endAt!.day}/${activeSub.endAt!.month}/${activeSub.endAt!.year}'
            : 'غير محدد';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'اشتراكك الحالي في خطة (${plan.name.toUpperCase()}) نشط حتى $endDateStr. لا يمكنك إعادة التجديد بنفس الخطة الآن.',
            ),
            backgroundColor: context.warningText,
          ),
        );
        return;
      }

      // في حالة الترقية
      final remainingDays = activeSub.endAt != null
          ? activeSub.endAt!.difference(DateTime.now()).inDays
          : 0;

      showDialog(
        context: context,
        builder: (_) => UpgradeConfirmationDialog(
          currentPlanName: activeSub.planId,
          targetPlanName: plan.name,
          remainingDays: remainingDays < 0 ? 0 : remainingDays,
          onConfirmUpgrade: () {
            context.read<SubscriptionsCubit>().requestSubscription(
                  ownerId: ownerId,
                  targetPlan: plan,
                  subscriptionType: cycle,
                );
          },
        ),
      );
      return;
    }

    // اشتراك جديد أو منتهي
    context.read<SubscriptionsCubit>().requestSubscription(
          ownerId: ownerId,
          targetPlan: plan,
          subscriptionType: cycle,
        );
  }

  @override
  Widget build(BuildContext context) {
    final ownerId = context.read<AuthCubit>().state.user?.id ?? '';

    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: SafeArea(
        child: BlocConsumer<SubscriptionsCubit, SubscriptionsState>(
          listener: (context, state) {
            if (state is SubscriptionPendingCreated) {
              if (state.subscription.isTrial) {
                // التجربة المجانية تتخطى الشاشات المالية وتذهب فوراً لإنشاء العيادة
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

              // افتراضياً اختيار خطة Pro أو الخطة الأولى
              _selectedPlan ??= plans.firstWhere(
                (p) => p.name == 'Pro',
               
              );

              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1024),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // مؤشر التقدم (Onboarding Progress Bar)
                        SizedBox(
                          width: 896,
                          child: ProgressIndicatorBar(
                            step: 1,
                            totalSteps: 3,
                            title: AppStrings.choosePlan,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // العنوان
                        Text(
                          AppStrings.chooseYourPlan,
                          style: AppTextStyles.headlineLarge(context),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppStrings.planSubtitle,
                          style: AppTextStyles.bodyLarge(context).copyWith(
                            color: context.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),

                        // Toggle دورة الفوترة: شهري | سنوي | مدى الحياة
                        Center(
                          child: Container(
                            decoration: BoxDecoration(
                              color: context.surfaceContainerLow.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.all(4),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildCycleButton('monthly', AppStrings.monthlyLabel),
                                _buildCycleButton('yearly', AppStrings.yearlyLabel),
                                _buildCycleButton('lifetime', AppStrings.lifetimeLabel),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),

                        // كروت أسعار ومميزات الخطط
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final isWide = constraints.maxWidth > 800;
                            return isWide
                                ? Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: plans.map((plan) {
                                      return Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8),
                                          child: _buildPlanCardWidget(context, plan, activeSub),
                                        ),
                                      );
                                    }).toList(),
                                  )
                                : Column(
                                    children: plans.map((plan) {
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 24),
                                        child: _buildPlanCardWidget(context, plan, activeSub),
                                      );
                                    }).toList(),
                                  );
                          },
                        ),

                        const SizedBox(height: 48),

                        // زر التفعيل / الانتقال للخطوة التالية
                        Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 400),
                            child: ElevatedButton(
                              onPressed: () {
                                if (_selectedPlan != null) {
                                  _onConfirmSubscriptionRequest(
                                      context, _selectedPlan!, activeSub, isTrial: true);
                                } else {
                                  context.go(RouteConstants.onboardingClinic);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: context.primary,
                                foregroundColor: context.onPrimary,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 24),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 4,
                                shadowColor:
                                    context.primaryContainer.withOpacity(0.4),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  RichText(
                                    text: TextSpan(
                                      style: AppTextStyles.headlineMedium(context).copyWith(
                                        color: context.onPrimary,
                                      ),
                                      children: [
                                        TextSpan(text: AppStrings.startFreeTrial),
                                        const TextSpan(
                                          text: ' 14 ',
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        TextSpan(text: AppStrings.daysUnit),
                                      ],
                                    ),
                                  ),
                                  const Spacer(),
                                  const Icon(Icons.arrow_back),
                                ],
                              ),
                            ),
                          ),
                        ),
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
                child: const Text('إعادة المحاولة'),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCycleButton(String key, String label) {
    final active = _selectedBillingCycle == key;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedBillingCycle = key);
      },
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
        ),
      ),
    );
  }

  Widget _buildPlanCardWidget(
    BuildContext context,
    PlanEntity plan,
    SubscriptionEntity? activeSub,
  ) {
    String displayTitle = AppStrings.basicPlan;
    if (plan.name == 'pro') displayTitle = AppStrings.professionalPlan;
    if (plan.name == 'enterprise') displayTitle = AppStrings.enterprisePlan;

    double rawPrice = plan.monthlyPrice;
    String subText = AppStrings.perMonth;
    if (_selectedBillingCycle == 'yearly') {
      rawPrice = plan.yearlyPrice;
      subText = AppStrings.perYear;
    } else if (_selectedBillingCycle == 'lifetime') {
      rawPrice = plan.lifetimePrice;
      subText = AppStrings.lifetimeSuffix;
    }

    final displayPrice = '\$${rawPrice.toInt()}';
    final isSelected = _selectedPlan?.id == plan.id;

    final List<PlanFeature> planFeaturesList = [];
    if (plan.features != null) {
      planFeaturesList.add(PlanFeature(text: AppStrings.supportClinics(plan.features!.maxClinics)));
      planFeaturesList.add(PlanFeature(text: AppStrings.supportStaff(plan.features!.maxStaff)));
      planFeaturesList.add(PlanFeature(text: AppStrings.supportPatients(plan.features!.maxPatients)));
    }

    return PlanCard(
      title: displayTitle,
      price: displayPrice,
      priceSubtext: subText,
      isFeatured: plan.name == 'pro',
      badgeText: plan.name == 'pro' ? AppStrings.mostPopular : null,
      features: planFeaturesList,
      buttonText: isSelected ? AppStrings.planSelected : AppStrings.selectPlan,
      onSelect: () {
        setState(() {
          _selectedPlan = plan;
        });
      },
    );
  }
}

class PlanEntityFallback extends PlanEntity {
  const PlanEntityFallback()
      : super(
          id: '',
          name: 'basic',
          monthlyPrice: 7,
          yearlyPrice: 70,
          lifetimePrice: 155,
          monthlyDiscount: 0,
          yearlyDiscount: 20,
          lifetimeDiscount: 50,
          currency: r'USD $',
        );
}

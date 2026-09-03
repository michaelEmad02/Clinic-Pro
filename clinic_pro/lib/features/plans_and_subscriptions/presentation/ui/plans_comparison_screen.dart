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
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../auth/presentation/manager/auth_cubit.dart';
import 'widgets/plan_card.dart';
import 'widgets/plans_cycle_selector.dart';
import '../../domain/entities/plan_entity.dart';
import '../../domain/entities/subscription_entity.dart';
import '../manager/subscriptions_cubit.dart';
import '../manager/subscriptions_state.dart';
import 'widgets/plan_confirmation_bottom_sheet.dart';

import '../../../owner_referrals/domain/entities/apply_referral_result_entity.dart';

class PlansComparisonScreen extends StatelessWidget {
  final bool isOnboarding;
  final String? initialCouponCode;
  final ApplyReferralResultEntity? referralResult;

  const PlansComparisonScreen({
    super.key,
    this.isOnboarding = false,
    this.initialCouponCode,
    this.referralResult,
  });

  @override
  Widget build(BuildContext context) {
    final ownerId = context.read<AuthCubit>().state.user?.id ?? '';

    return BlocProvider(
      create: (_) => sl<SubscriptionsCubit>()..loadSubscriptionsData(ownerId),
      child: _PlansComparisonBody(
        isOnboarding: isOnboarding,
        initialCouponCode: initialCouponCode,
        referralResult: referralResult,
      ),
    );
  }
}

class _PlansComparisonBody extends StatefulWidget {
  final bool isOnboarding;
  final String? initialCouponCode;
  final ApplyReferralResultEntity? referralResult;

  const _PlansComparisonBody({
    this.isOnboarding = false,
    this.initialCouponCode,
    this.referralResult,
  });

  @override
  State<_PlansComparisonBody> createState() => _PlansComparisonBodyState();
}

class _PlansComparisonBodyState extends State<_PlansComparisonBody> {
  String _selectedCycle =
      SubscriptionType.monthly; // 'monthly', 'yearly', 'lifetime'

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
      final isSamePlan =
          activeSub.planId.toLowerCase() == selectedPlan.id.toLowerCase() ||
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
        AppSnackbar.info(
          context,
          message: AppStrings.activeUntil(endDateStr),
        );
        return;
      }

      final isUpgrade = selectedPlanWeight > currentPlanWeight ||
          (isSamePlan && selectedCycleWeight > currentCycleWeight);

      if (isUpgrade) {
        final remainingDays = activeSub.endAt != null
            ? activeSub.endAt!.difference(DateTime.now()).inDays
            : 0;

        PlanConfirmationBottomSheet.showAdaptive(
          context: context,
          targetPlan: selectedPlan,
          subscriptionType: _selectedCycle,
          isUpgrade: true,
          remainingDays: remainingDays < 0 ? 0 : remainingDays,
          onConfirm: () {
            context.read<SubscriptionsCubit>().requestSubscription(
                  ownerId: ownerId,
                );
          },
          onPayOnline: () {
            context.push(
              RouteConstants.paymentMethods,
              extra: {
                'targetPlan': selectedPlan,
                'subscriptionType': _selectedCycle,
                'initialCouponCode': widget.initialCouponCode,
              },
            );
          },
        );
        return;
      }

      final endDateStr = activeSub.endAt != null
          ? '${activeSub.endAt!.day}/${activeSub.endAt!.month}/${activeSub.endAt!.year}'
          : AppStrings.notSpecified;
      AppSnackbar.info(
        context,
        message: AppStrings.activePlanNoDowngrade(endDateStr),
      );
      return;
    }

    PlanConfirmationBottomSheet.showAdaptive(
      context: context,
      targetPlan: selectedPlan,
      subscriptionType: _selectedCycle,
      isUpgrade: false,
      remainingDays: 0,
      onConfirm: () {
        context.read<SubscriptionsCubit>().requestSubscription(
              ownerId: ownerId,
            );
      },
      onPayOnline: () {
        context.push(
          RouteConstants.paymentMethods,
          extra: {
            'targetPlan': selectedPlan,
            'subscriptionType': _selectedCycle,
            'initialCouponCode': widget.initialCouponCode,
          },
        );
      },
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
              AppSnackbar.error(context, message: state.message);
            }
          },
          builder: (context, state) {
            if (state is SubscriptionsLoading) {
              return const Center(child: AppLoadingWidget());
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
                        PlansCycleSelector(
                          selectedCycle: _selectedCycle,
                          onCycleChanged: (cycle) {
                            setState(() => _selectedCycle = cycle);
                          },
                        ),
                        const SizedBox(height: 16),

                        // زر / بانر إدخال كود الدعوة أو عرض الهدية الترحيبية المفعلة (تصميم متجاوب بالكامل)
                        if (widget.initialCouponCode != null &&
                            widget.initialCouponCode!.isNotEmpty)
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final isSmallScreen = constraints.maxWidth < 400;

                              return Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 12),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      context.accent.withOpacity(0.12),
                                      context.primary.withOpacity(0.06),
                                    ],
                                    begin: AlignmentDirectional.centerStart,
                                    end: AlignmentDirectional.centerEnd,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: context.accent.withOpacity(0.35)),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: context.accent,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.card_giftcard_rounded,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (isSmallScreen) ...[
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    'هدية الدعوة مفعلة 🎁',
                                                    style: AppTextStyles
                                                            .bodyMedium(context)
                                                        .copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          context.textPrimary,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 6,
                                                      vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: context.accent
                                                        .withOpacity(0.15),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6),
                                                    border: Border.all(
                                                        color: context.accent
                                                            .withOpacity(0.3)),
                                                  ),
                                                  child: Text(
                                                    widget.initialCouponCode!,
                                                    style:
                                                        AppTextStyles.caption(
                                                                context)
                                                            .copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: context.accent,
                                                      fontSize: 10,
                                                      letterSpacing: 0.5,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ] else ...[
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    'هدية الدعوة مفعلة بنجاح 🎁',
                                                    style: AppTextStyles
                                                            .bodyMedium(context)
                                                        .copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          context.textPrimary,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8,
                                                      vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: context.accent
                                                        .withOpacity(0.15),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6),
                                                    border: Border.all(
                                                        color: context.accent
                                                            .withOpacity(0.3)),
                                                  ),
                                                  child: Text(
                                                    widget.initialCouponCode!,
                                                    style:
                                                        AppTextStyles.caption(
                                                                context)
                                                            .copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: context.accent,
                                                      letterSpacing: 1,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                          const SizedBox(height: 4),
                                          Text(
                                            'سيتم تطبيق الخصم الترحيبي تلقائياً عند اختيار باقتك والمتابعة للدفع.',
                                            style:
                                                AppTextStyles.caption(context)
                                                    .copyWith(
                                              color: context.textSecondary,
                                              fontSize: 11,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        // else
                        //   InkWell(
                        //     onTap: () {
                        //       final ownerId =
                        //           context.read<AuthCubit>().state.user?.id ??
                        //               '';
                        //       EnterReferralCodeBottomSheet.show(
                        //         context: context,
                        //         ownerId: ownerId,
                        //       );
                        //     },
                        //     borderRadius: BorderRadius.circular(10),
                        //     child: Container(
                        //       padding: const EdgeInsets.symmetric(
                        //           horizontal: 14, vertical: 10),
                        //       decoration: BoxDecoration(
                        //         color: context.primary.withOpacity(0.06),
                        //         borderRadius: BorderRadius.circular(10),
                        //         border: Border.all(
                        //             color: context.primary.withOpacity(0.2)),
                        //       ),
                        //       child: Row(
                        //         mainAxisSize: MainAxisSize.min,
                        //         children: [
                        //           Icon(Icons.card_giftcard_rounded,
                        //               color: context.primary, size: 18),
                        //           const SizedBox(width: 8),
                        //           Text(
                        //             AppStrings.haveReferralCode,
                        //             style: AppTextStyles.bodyMedium(context)
                        //                 .copyWith(
                        //               color: context.primary,
                        //               fontWeight: FontWeight.bold,
                        //             ),
                        //           ),
                        //           const SizedBox(width: 6),
                        //           Icon(Icons.arrow_forward_ios,
                        //               color: context.primary, size: 12),
                        //         ],
                        //       ),
                        //     ),
                        //   ),
                        const SizedBox(height: 24),

                        // عرض كروت الخطط (الخطة الحالية تظهر أولاً دائماً)
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final isWide = constraints.maxWidth >= 768;

                            final sortedPlans = List<PlanEntity>.from(plans);
                            if (activeSub != null && activeSub.isActive) {
                              sortedPlans.sort((a, b) {
                                final aIsCurrent = a.name.toLowerCase() ==
                                        activeSub.planId.toLowerCase() ||
                                    a.id.toLowerCase() ==
                                        activeSub.planId.toLowerCase();
                                final bIsCurrent = b.name.toLowerCase() ==
                                        activeSub.planId.toLowerCase() ||
                                    b.id.toLowerCase() ==
                                        activeSub.planId.toLowerCase();
                                if (aIsCurrent && !bIsCurrent) return -1;
                                if (!aIsCurrent && bIsCurrent) return 1;
                                return 0;
                              });
                            }

                            if (isWide) {
                              return IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: sortedPlans.map((plan) {
                                    return Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: AppConstants.spaceSm),
                                        child: _buildPlanCardItem(
                                            context, plan, activeSub),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              );
                            }

                            return Column(
                              children: sortedPlans.map((plan) {
                                return Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: AppConstants.spaceLg),
                                  child: _buildPlanCardItem(
                                      context, plan, activeSub),
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
                                context
                                    .read<SubscriptionsCubit>()
                                    .requestSubscription(
                                      ownerId: ownerId,
                                    );
                              },
                              icon: const Icon(Icons.star_rounded,
                                  color: Colors.amber),
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
                                  borderRadius: BorderRadius.circular(
                                      AppConstants.radiusButton),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // زر المتابعة في وضع القراءة فقط إذا كان الاشتراك منتهياً
                        if (isTrialUsed && (activeSub == null || !activeSub.isActive)) ...[
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 400),
                            child: OutlinedButton.icon(
                              onPressed: () {
                                context.read<AuthCubit>().enterReadOnlyMode();
                                context.go(RouteConstants.ownerDashboard);
                              },
                              icon: Icon(Icons.visibility_outlined,
                                  color: context.primary),
                              label: Flexible(
                                child: Text(
                                  AppStrings.isArabic
                                      ? 'المتابعة في وضع القراءة فقط'
                                      : 'Continue in Read-Only Mode',
                                  style: AppTextStyles.bodyMedium(context).copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: context.primary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: context.primary,
                                minimumSize: const Size(double.infinity, 48),
                                side: BorderSide(
                                    color: context.primary, width: 1.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      AppConstants.radiusButton),
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

            final errorMsg = state is SubscriptionsError ? state.message : null;
            return AppErrorWidget.buildErrorView(
              context: context,
              error: errorMsg,
              onRetry: () => context
                  .read<SubscriptionsCubit>()
                  .loadSubscriptionsData(ownerId),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPlanCardItem(
    BuildContext context,
    PlanEntity plan,
    SubscriptionEntity? activeSub,
  ) {
    double price = plan.monthlyPriceEgp;
    String subText = AppStrings.perMonth;
    if (_selectedCycle == SubscriptionType.yearly) {
      price = plan.yearlyPriceEgp;
      subText = AppStrings.perYear;
    } else if (_selectedCycle == SubscriptionType.lifetime) {
      price = plan.lifetimePriceEgp;
      subText = AppStrings.lifetimeSuffix;
    }

    final isCurrentPlan = activeSub != null &&
        activeSub.isActive &&
        (activeSub.planId.toLowerCase() == plan.name.toLowerCase() ||
            activeSub.planId.toLowerCase() == plan.id.toLowerCase());

    final isSameCycle =
        activeSub != null && activeSub.subscriptionType == _selectedCycle;

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
      planFeaturesList.add(PlanFeature(
          text: AppStrings.supportClinics(plan.features!.maxClinics)));
      planFeaturesList.add(
          PlanFeature(text: AppStrings.supportStaff(plan.features!.maxStaff)));
      planFeaturesList.add(PlanFeature(
          text: AppStrings.supportPatients(plan.features!.maxPatients)));

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
      price: '${price.toInt()} ${AppStrings.egp}',
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

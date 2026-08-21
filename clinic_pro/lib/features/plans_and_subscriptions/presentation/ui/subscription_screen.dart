// ────────────────────────────────────────────────────────
// شاشة إدارة الاشتراك الحالية والحدود (SubscriptionScreen)
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/strings/app_strings.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../auth/presentation/manager/auth_cubit.dart';
import '../manager/subscriptions_cubit.dart';
import '../manager/subscriptions_state.dart';
import 'widgets/billing_history_list.dart';
import 'widgets/current_plan_card.dart';
import 'widgets/trial_countdown_card.dart';
import 'widgets/usage_progress_section.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthCubit>().state.user?.id ?? '';

    return BlocProvider(
      create: (_) => sl<SubscriptionsCubit>()..loadSubscriptionsData(userId),
      child: const _SubscriptionBody(),
    );
  }
}

class _SubscriptionBody extends StatelessWidget {
  const _SubscriptionBody();

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthCubit>().state.user?.id ?? '';

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        toolbarHeight: 64,
        backgroundColor: context.surfaceColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          AppStrings.subscriptionAndPlan,
          style: AppTextStyles.headlineMedium(context).copyWith(
            fontWeight: FontWeight.bold,
            color: context.primary,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: context.borderColor, height: 1),
        ),
      ),
      body: BlocBuilder<SubscriptionsCubit, SubscriptionsState>(
        builder: (context, state) {
          if (state is SubscriptionsLoading) {
            return const Center(child: AppLoadingWidget());
          }

          if (state is SubscriptionsLoaded) {
            final activeSub = state.activeSubscription;
            final planKey = activeSub?.subscriptionType.isNotEmpty == true
                ? activeSub!.subscriptionType
                : 'basic';
            final planStatus = activeSub?.status ?? 'active';

            // البحث عن الخطة الحالية ومميزاتها
            final currentPlan = state.plans.firstWhere(
              (p) => p.id == activeSub?.planId || p.name.toLowerCase() == planKey.toLowerCase(),
            );

            final maxClinics = currentPlan.features?.maxClinics ?? 1;
            final maxStaff = currentPlan.features?.maxStaff ?? 2;
            final maxPatients = currentPlan.features?.maxPatients ?? 500;

            final daysRemaining = activeSub?.endAt != null
                ? activeSub!.endAt!.difference(DateTime.now()).inDays
                : 0;
            final isTrial = activeSub?.isTrial ?? false;

            // استخدام إحصائيات قاعدة البيانات الفعلية المحسوبة
            final clinicsUsed = state.usage?.clinicsCount ?? 0;
            final staffUsed = state.usage?.staffCount ?? 0;
            final patientsUsed = state.usage?.patientsCount ?? 0;

            return ResponsiveHelper.responsiveCenter(
              maxWidth: 1100,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.screenEdgeH,
                  vertical: AppConstants.spaceLg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.subscriptionAndPlan,
                      style: AppTextStyles.headlineLarge(context),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: AppConstants.spaceXs),
                    Text(
                      AppStrings.manageSubscription,
                      style: AppTextStyles.bodyMedium(context).copyWith(
                        color: context.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: AppConstants.spaceLg),

                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isDesktop = constraints.maxWidth >= 900;
                        if (!isDesktop) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CurrentPlanCard(
                                plan: currentPlan,
                                planStatus: planStatus,
                              ),
                              const SizedBox(height: AppConstants.spaceLg),
                              if (isTrial) ...[
                                TrialCountdownCard(
                                  daysRemaining: daysRemaining > 0 ? daysRemaining : 0,
                                  isTrial: isTrial,
                                ),
                                const SizedBox(height: AppConstants.spaceLg),
                              ],
                              UsageProgressSection(
                                clinicsUsed: clinicsUsed,
                                clinicsMax: maxClinics,
                                usersUsed: staffUsed,
                                usersMax: maxStaff,
                                patientsUsed: patientsUsed,
                                patientsMax: maxPatients,
                              ),
                              const SizedBox(height: AppConstants.spaceLg),
                              UpgradeCtaButton(
                                onPressed: () {
                                  context.push(RouteConstants.plansComparison);
                                },
                              ),
                              const SizedBox(height: AppConstants.spaceXl),
                              const BillingHistoryList(),
                            ],
                          );
                        }

                        // Desktop / Laptop 2-Column Bento Layout
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // العمود الأيمن (الخطة الحالية والعد التنازلي)
                            Expanded(
                              flex: 5,
                              child: Column(
                                children: [
                                  CurrentPlanCard(
                                    plan: currentPlan,
                                    planStatus: planStatus,
                                  ),
                                  if (isTrial) ...[
                                    const SizedBox(height: AppConstants.spaceLg),
                                    TrialCountdownCard(
                                      daysRemaining: daysRemaining > 0 ? daysRemaining : 0,
                                      isTrial: isTrial,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(width: AppConstants.spaceLg),
                            // العمود الأيسر (استهلاك الحدود + الترقية + سجل الفواتير)
                            Expanded(
                              flex: 6,
                              child: Column(
                                children: [
                                  UsageProgressSection(
                                    clinicsUsed: clinicsUsed,
                                    clinicsMax: maxClinics,
                                    usersUsed: staffUsed,
                                    usersMax: maxStaff,
                                    patientsUsed: patientsUsed,
                                    patientsMax: maxPatients,
                                  ),
                                  const SizedBox(height: AppConstants.spaceLg),
                                  UpgradeCtaButton(
                                    onPressed: () {
                                      context.push(RouteConstants.plansComparison);
                                    },
                                  ),
                                  const SizedBox(height: AppConstants.spaceXl),
                                  const BillingHistoryList(),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: AppConstants.spaceLg),
                  ],
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
                .loadSubscriptionsData(userId),
          );
        },
      ),
    );
  }
}


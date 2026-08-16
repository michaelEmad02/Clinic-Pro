import 'package:clinic_pro/core/constants/staff_roles.dart';
import 'package:clinic_pro/core/di/injection_container.dart';
import 'package:clinic_pro/features/auth/presentation/manager/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/strings/app_strings.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../manager/settings_cubit.dart';
import '../manager/settings_state.dart';
import '../../../plans_and_subscriptions/domain/entities/plan_entity.dart';
import '../../../plans_and_subscriptions/domain/entities/subscription_entity.dart';
import '../../../plans_and_subscriptions/domain/entities/subscription_usage_entity.dart';
import '../../../plans_and_subscriptions/presentation/manager/subscriptions_cubit.dart';
import '../../../plans_and_subscriptions/presentation/manager/subscriptions_state.dart';
import '../../../../core/utils/responsive_helper.dart';
import 'widgets/trial_countdown_card.dart';
import 'widgets/current_plan_card.dart';
import 'widgets/usage_progress_section.dart';
import 'widgets/upgrade_cta_button.dart';
import 'widgets/billing_history_list.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthCubit>().state.user?.id ?? '';

    return MultiBlocProvider(
      providers: [
        BlocProvider<SettingsCubit>(
          create: (context) {
            final cubit = sl<SettingsCubit>();
            if (cubit.state.subscriptionEntity == null) {
              cubit.loadSettings(StaffRoles.owner, userId);
            }
            return cubit;
          },
        ),
        BlocProvider<SubscriptionsCubit>(
          create: (context) => sl<SubscriptionsCubit>()..loadSubscriptionsData(userId),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            AppStrings.subscriptionAndPlan,
            style: AppTextStyles.headlineMedium(context).copyWith(color: context.primary),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_forward, color: context.primary),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: BlocBuilder<SubscriptionsCubit, SubscriptionsState>(
          builder: (context, subState) {
            if (subState is SubscriptionsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            PlanEntity? currentPlan;
            SubscriptionEntity? activeSub;
            SubscriptionUsageEntity? usage;

            if (subState is SubscriptionsLoaded) {
              activeSub = subState.activeSubscription;
              usage = subState.usage;
              if (activeSub != null) {
                currentPlan = subState.plans.firstWhere(
                  (p) => p.id == activeSub!.planId || p.name.toLowerCase() == activeSub.planId.toLowerCase(),
                  orElse: () => subState.plans.first,
                );
              } else if (subState.plans.isNotEmpty) {
                currentPlan = subState.plans.first;
              }
            }

            final planKey = activeSub?.subscriptionType.isNotEmpty == true
                ? activeSub!.subscriptionType
                : (currentPlan?.name ?? 'basic');

            final planStatus = activeSub?.status ?? 'active';
            final features = currentPlan?.features;

            // الحدود الحقيقية الديناميكية القادمة من قاعدة البيانات
            final int maxClinics = features?.maxClinics ?? 1;
            final int maxStaff = features?.maxStaff ?? 2;
            final int maxPatients = features?.maxPatients ?? 500;

            final daysRemaining = activeSub?.daysRemaining ?? 0;
            final isTrial = activeSub?.isTrial ?? false;

            return BlocBuilder<SettingsCubit, SettingsState>(
              builder: (context, settingsState) {
                // الاستخدامات الفعلية الحقيقية القادمة مباشرة من قاعدة البيانات
                final clinicsUsed = usage?.clinicsCount ?? settingsState.availableClinics.length;
                final staffUsed = usage?.staffCount ?? settingsState.staffList.length;
                final patientsUsed = usage?.patientsCount ?? 0;

                return ResponsiveHelper.responsiveCenter(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.screenEdgeH,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: AppConstants.spaceSm),
                        Text(
                          AppStrings.subscriptionAndPlan,
                          style: AppTextStyles.headlineLarge(context),
                        ),
                        const SizedBox(height: AppConstants.spaceXs),
                        Text(
                          AppStrings.manageSubscription,
                          style: AppTextStyles.bodyMedium(context).copyWith(color: context.textSecondary),
                        ),
                        const SizedBox(height: AppConstants.spaceLg),
                        CurrentPlanCard(
                          planKey: currentPlan?.name ?? planKey,
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
                        const UpgradeCtaButton(),
                        const SizedBox(height: AppConstants.spaceXl),
                        const BillingHistoryList(),
                        const SizedBox(height: AppConstants.spaceLg),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

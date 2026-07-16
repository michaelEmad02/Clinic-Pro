import 'package:clinic_pro/core/di/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/strings/app_strings.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/constants/staff_roles.dart';
import '../../../../core/mocks/mock_data.dart';
import '../manager/settings_cubit.dart';
import '../manager/settings_state.dart';
import 'widgets/trial_countdown_card.dart';
import 'widgets/current_plan_card.dart';
import 'widgets/usage_progress_section.dart';
import 'widgets/upgrade_cta_button.dart';
import 'widgets/billing_history_list.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SettingsCubit>(
        create: (context) {
          final cubit = sl<SettingsCubit>();
          if (cubit.state.userName.isEmpty) {
            cubit.loadSettings(StaffRoles.owner);
          }
          return cubit;
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(AppStrings.subscriptionAndPlan, style: AppTextStyles.headlineMedium(context).copyWith(color: AppColors.primary)),
            leading: IconButton(
              icon: const Icon(Icons.arrow_forward, color: AppColors.primary),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: BlocBuilder<SettingsCubit, SettingsState>(
            builder: (context, state) {
              if (state.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              // Determine plan type key
              final planKey = state.planType.isNotEmpty ? state.planType : 'basic';
              
              // Calculate limit bounds
              int maxClinics = 1;
              int maxStaff = 2;
              int maxPatients = 500;

              if (planKey == 'pro' || planKey == 'growth') {
                maxClinics = 3;
                maxStaff = 5;
                maxPatients = 2000;
              } else if (planKey == 'professional' || planKey == 'enterprise') {
                maxClinics = 10;
                maxStaff = 20;
                maxPatients = 10000;
              }

              // Calculate active usages from MockData
              final clinicsUsed = MockData.clinics.length;
              final staffUsed = MockData.clinicStaff.where((e) => e['clinic_id'] == state.clinicId).length;
              final patientsUsed = MockData.patients.where((e) => e['clinic_id'] == state.clinicId).length;

              final daysRemaining = state.trialEndAt != null
                  ? DateTime.parse(state.trialEndAt!).difference(DateTime.now()).inDays
                  : 0;
              
              final isTrial = state.planStatus == 'trial' || state.planStatus == 'trail';

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.screenEdgeH),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppConstants.spaceSm),
                    Text(AppStrings.subscriptionAndPlan, style: AppTextStyles.headlineLarge(context)),
                    const SizedBox(height: AppConstants.spaceXs),
                    Text(AppStrings.manageSubscription,
                        style: AppTextStyles.bodyMedium(context).copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: AppConstants.spaceLg),
                    CurrentPlanCard(planKey: planKey, planStatus: state.planStatus),
                    const SizedBox(height: AppConstants.spaceLg),
                    if (isTrial) ...[
                      TrialCountdownCard(daysRemaining: daysRemaining > 0 ? daysRemaining : 0, isTrial: isTrial),
                      const SizedBox(height: AppConstants.spaceLg),
                    ],
                    const SizedBox(height: AppConstants.spaceMd),
                    UsageProgressSection(
                      clinicsUsed: clinicsUsed,
                      clinicsMax: maxClinics,
                      usersUsed: staffUsed, // Users represent staff
                      usersMax: maxStaff,
                      patientsUsed: patientsUsed,
                      patientsMax: maxPatients,
                    ),
                    const SizedBox(height: AppConstants.spaceLg),
                    const UpgradeCtaButton(),
                    const SizedBox(height: AppConstants.spaceLg),
                    const BillingHistoryList(),
                    const SizedBox(height: AppConstants.spaceXl),
                  ],
                ),
              );
            },
          ),
        ),
      );
  }
}

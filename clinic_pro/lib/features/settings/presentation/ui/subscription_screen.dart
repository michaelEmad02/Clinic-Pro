import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('الاشتراك والخطة', style: AppTextStyles.headlineMedium(context).copyWith(color: AppColors.primary)),
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
            final daysRemaining = state.trialEndAt != null
                ? DateTime.parse(state.trialEndAt!).difference(DateTime.now()).inDays
                : 0;
            final isTrial = state.planStatus == 'trial' || state.planStatus == 'active';
            final planLabel = _planTypeLabel(state.planType);

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.screenEdgeH),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppConstants.spaceSm),
                  Text('الاشتراك والخطة', style: AppTextStyles.headlineLarge(context)),
                  const SizedBox(height: AppConstants.spaceXs),
                  Text('إدارة باقة العيادة، ومراقبة الاستهلاك، وتحديث معلومات الدفع.',
                      style: AppTextStyles.bodyMedium(context).copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: AppConstants.spaceLg),
                  CurrentPlanCard(planType: planLabel, planStatus: state.planStatus),
                  const SizedBox(height: AppConstants.spaceLg),
                  TrialCountdownCard(daysRemaining: daysRemaining > 0 ? daysRemaining : 0, isTrial: isTrial),
                  const SizedBox(height: AppConstants.spaceXl),
                  const UsageProgressSection(),
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

  String _planTypeLabel(String type) {
    switch (type) {
      case 'growth': return 'باقة النمو';
      case 'professional': return 'الباقة الاحترافية';
      default: return 'الباقة الأساسية';
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// شاشة لوحة تحكم الدعوات والمكافآت (Referral Dashboard Screen)
// تتوافق تماماً مع قواعد Project Rules (Header comment, Subwidgets delegation, AppStrings, context colors)
// ─────────────────────────────────────────────────────────────────────────────

import 'package:clinic_pro/core/constants/app_constants.dart';
import 'package:clinic_pro/core/utils/responsive_helper.dart';
import 'package:clinic_pro/core/widgets/app_error_widget.dart';
import 'package:clinic_pro/core/widgets/app_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clinic_pro/core/di/injection_container.dart';
import 'package:clinic_pro/core/strings/app_strings.dart';
import 'package:clinic_pro/core/themes/app_colors.dart';
import 'package:clinic_pro/core/themes/app_text_styles.dart';
import 'package:clinic_pro/features/owner_referrals/presentation/manager/referral_cubit.dart';
import 'package:clinic_pro/features/owner_referrals/presentation/manager/referral_state.dart';
import 'package:clinic_pro/features/owner_referrals/presentation/ui/widgets/milestone_list_item.dart';
import 'package:clinic_pro/features/owner_referrals/presentation/ui/widgets/milestone_progress_card.dart';
import 'package:clinic_pro/features/owner_referrals/presentation/ui/widgets/referral_code_card.dart';

class ReferralDashboardScreen extends StatelessWidget {
  final String ownerId;

  const ReferralDashboardScreen({
    super.key,
    required this.ownerId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ReferralCubit>()..loadReferralDashboard(ownerId),
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppStrings.inviteDoctorsAndRewards),
          centerTitle: true,
        ),
        body: SafeArea(
          child: BlocBuilder<ReferralCubit, ReferralState>(
            builder: (context, state) {
              if (state is ReferralLoading) {
                return const Center(
                  child: AppLoadingWidget(size: AppLoadingSize.large),
                );
              }

              if (state is ReferralError) {
                return Center(
                  child: AppErrorWidget(
                    message: state.message,
                    onRetry: () =>
                        context.read<ReferralCubit>().loadReferralDashboard(ownerId),
                  ),
                );
              }

              if (state is ReferralDashboardLoaded) {
                final dashboard = state.dashboard;

                return ResponsiveHelper.responsiveCenter(
                  maxWidth: AppConstants.maxContentWidth,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.screenEdgeH,
                      vertical: AppConstants.screenEdgeV,
                    ),
                    children: [
                      ReferralCodeCard(referralCode: dashboard.referralCode),
                      const SizedBox(height: AppConstants.spaceMd),
                      MilestoneProgressCard(dashboard: dashboard),
                      const SizedBox(height: AppConstants.spaceLg),
                      Text(
                        AppStrings.milestoneRewardsTitle,
                        style: AppTextStyles.headlineSmall(context).copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppConstants.spaceSm + 4),
                      ...dashboard.milestones.map(
                        (m) => MilestoneListItem(milestone: m),
                      ),
                    ],
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}

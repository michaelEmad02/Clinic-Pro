// ─────────────────────────────────────────────────────────────────────────────
// شاشة لوحة تحكم الدعوات والمكافآت (Referral Dashboard Screen)
// تتوافق تماماً مع قواعد Project Rules (Header comment, Subwidgets delegation, AppStrings, context colors)
// ─────────────────────────────────────────────────────────────────────────────

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
        body: BlocBuilder<ReferralCubit, ReferralState>(
          builder: (context, state) {
            if (state is ReferralLoading) {
              return Center(
                child: CircularProgressIndicator(color: context.primary),
              );
            }

            if (state is ReferralError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      state.message,
                      style: AppTextStyles.bodyMedium(context),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => context.read<ReferralCubit>().loadReferralDashboard(ownerId),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.primary,
                        foregroundColor: context.onPrimary,
                      ),
                      child: Text(AppStrings.retry),
                    ),
                  ],
                ),
              );
            }

            if (state is ReferralDashboardLoaded) {
              final dashboard = state.dashboard;

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  ReferralCodeCard(referralCode: dashboard.referralCode),
                  const SizedBox(height: 18),
                  MilestoneProgressCard(dashboard: dashboard),
                  const SizedBox(height: 24),
                  Text(
                    AppStrings.milestoneRewardsTitle,
                    style: AppTextStyles.headlineSmall(context).copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...dashboard.milestones.map(
                    (m) => MilestoneListItem(milestone: m),
                  ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

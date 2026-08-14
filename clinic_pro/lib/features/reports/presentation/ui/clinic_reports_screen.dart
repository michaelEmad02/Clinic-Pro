import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clinic_pro/core/di/injection_container.dart';
import 'package:clinic_pro/core/strings/app_strings.dart';
import 'package:clinic_pro/core/themes/app_colors.dart';
import 'package:clinic_pro/core/themes/app_text_styles.dart';
import 'package:clinic_pro/core/widgets/shimmer_list.dart';
import 'package:clinic_pro/features/auth/presentation/manager/auth_cubit.dart';
import '../manager/clinic_reports_cubit.dart';
import 'widgets/clinic_summary_cards.dart';
import 'widgets/clinic_comparison_bar_chart.dart';
import 'widgets/clinic_leaderboard_table.dart';
import 'widgets/clinic_trend_line_chart.dart';

class ClinicReportsScreen extends StatelessWidget {
  const ClinicReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthCubit>().state.user?.id ?? '';
    return BlocProvider.value(
      value: sl<ClinicReportsCubit>()..loadReport(userId),
      child: const _ClinicReportsBody(),
    );
  }
}

class _ClinicReportsBody extends StatefulWidget {
  const _ClinicReportsBody();

  @override
  State<_ClinicReportsBody> createState() => _ClinicReportsBodyState();
}

class _ClinicReportsBodyState extends State<_ClinicReportsBody> {
  @override
  void dispose() {
    sl<ClinicReportsCubit>().clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        toolbarHeight: 64,
        backgroundColor: context.surfaceColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          AppStrings.isArabic ? 'تقارير العيادات والفروع' : 'Clinic Reports',
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
      body: BlocBuilder<ClinicReportsCubit, ClinicReportsState>(
        builder: (context, state) {
          if (state is ClinicReportsLoading) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: ShimmerList(itemCount: 5),
            );
          }
          if (state is ClinicReportsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      final userId = context.read<AuthCubit>().state.user?.id ?? '';
                      context.read<ClinicReportsCubit>().loadReport(userId, forceRefresh: true);
                    },
                    child: Text(AppStrings.retry),
                  ),
                ],
              ),
            );
          }
          if (state is ClinicReportsLoaded) {
            final report = state.report;
            if (report.clinics.isEmpty) {
              return Center(
                child: Text(
                  AppStrings.isArabic ? 'لا توجد عيادات مسجلة' : 'No clinics found',
                  style: AppTextStyles.bodyLarge(context),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                final userId = context.read<AuthCubit>().state.user?.id ?? '';
                await context.read<ClinicReportsCubit>().loadReport(userId, forceRefresh: true);
              },
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 16),
                children: [
                  ClinicSummaryCards(report: report),
                  const SizedBox(height: 16),
                  ClinicComparisonBarChart(clinics: report.clinics),
                  const SizedBox(height: 16),
                  ClinicTrendLineChart(clinics: report.clinics),
                  const SizedBox(height: 16),
                  ClinicLeaderboardTable(clinics: report.clinics),
                  const SizedBox(height: 24),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

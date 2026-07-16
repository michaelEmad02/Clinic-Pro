// ────────────────────────────────────────────────────────
// شاشة التقارير المالية والأداء — نظرة شاملة على أداء العيادة
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/strings/app_strings.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/localization/language_cubit.dart';
import '../../../../core/widgets/shimmer_list.dart';
import '../manager/reports_cubit.dart';
import '../manager/reports_state.dart';
import 'widgets/doctor_performance_list.dart';
import 'widgets/patients_count_chart.dart';
import 'widgets/reports_date_range_chips.dart';
import 'widgets/reports_summary_grid.dart';
import 'widgets/revenue_vs_expenses_chart.dart';
import 'widgets/top_services_list.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ReportsCubit>()..loadReports(),
      child: const _ReportsBody(),
    );
  }
}

class _ReportsBody extends StatelessWidget {
  const _ReportsBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        toolbarHeight: 64,
        backgroundColor: context.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.reports,
              style: AppTextStyles.headlineMedium(context).copyWith(
                fontWeight: FontWeight.bold,
                color: context.primary,
              ),
            ),
            Text(
              AppStrings.financialReports,
              style: AppTextStyles.caption(context).copyWith(
                color: context.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            color: context.primary,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppStrings.reportExported),
                ),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: context.border, height: 1),
        ),
      ),
      body: BlocBuilder<ReportsCubit, ReportsState>(
        builder: (context, state) {
          if (state is ReportsLoading) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: ShimmerList(itemCount: 6),
            );
          }
          if (state is ReportsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<ReportsCubit>().loadReports(),
                    child: Text(AppStrings.retry),
                  ),
                ],
              ),
            );
          }
          if (state is ReportsLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<ReportsCubit>().loadReports();
                await Future.delayed(const Duration(milliseconds: 600));
              },
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 16),
                children: [
                  ReportsDateRangeChips(
                    activeRange: state.activeRange,
                    onChanged: (r) {
                      final cubit = context.read<ReportsCubit>();
                      if (r == ReportsDateRange.custom) {
                        _pickCustomRange(context, cubit);
                      } else {
                        cubit.changeRange(r);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  ReportsSummaryGrid(summary: state.summary),
                  const SizedBox(height: 12),
                  RevenueVsExpensesChart(data: state.weeklyData),
                  const SizedBox(height: 12),
                  PatientsCountChart(doctors: state.doctorPerformance),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: TopServicesList(services: state.topServices),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DoctorPerformanceList(
                              doctors: state.doctorPerformance),
                        ),
                      ],
                    ),
                  ),
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

  Future<void> _pickCustomRange(
      BuildContext context, ReportsCubit cubit) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (ctx, child) => BlocBuilder<LanguageCubit, Locale>(
        builder: (context, locale) => Directionality(
          textDirection: locale.languageCode == 'ar'
              ? TextDirection.rtl
              : TextDirection.ltr,
          child: child!,
        ),
      ),
    );
    if (picked != null) {
      cubit.changeCustomRange(picked.start, picked.end);
    }
  }
}

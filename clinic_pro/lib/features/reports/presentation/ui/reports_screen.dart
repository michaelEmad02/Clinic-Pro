// ────────────────────────────────────────────────────────
// شاشة التقارير المالية والأداء — نظرة شاملة على أداء العيادة
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../manager/reports_cubit.dart';
import '../manager/reports_state.dart';
import 'widgets/doctor_performance_list.dart';
import 'widgets/patients_count_chart.dart';
import 'widgets/reports_date_range_chips.dart';
import 'widgets/reports_summary_grid.dart';
import 'widgets/revenue_vs_expenses_chart.dart';
import 'widgets/top_services_list.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/widgets/shimmer_list.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ReportsCubit()..loadReports(),
      child: const _ReportsBody(),
    );
  }
}

class _ReportsBody extends StatelessWidget {
  const _ReportsBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        toolbarHeight: 64,
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'التقارير المالية والأداء',
              style: AppTextStyles.headlineMedium(context).copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            Text(
              'نظرة شاملة على أداء العيادة والإيرادات',
              style: AppTextStyles.caption(context).copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            color: AppColors.primary,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم تصدير التقرير بنجاح'),
                ),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.border, height: 1),
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
                    onPressed: () =>
                        context.read<ReportsCubit>().loadReports(),
                    child: const Text('إعادة المحاولة'),
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
                    onChanged: (r) =>
                        context.read<ReportsCubit>().changeRange(r),
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
                          child: TopServicesList(
                              services: state.topServices),
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
}

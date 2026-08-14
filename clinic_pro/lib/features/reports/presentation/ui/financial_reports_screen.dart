import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clinic_pro/core/di/injection_container.dart';
import 'package:clinic_pro/core/strings/app_strings.dart';
import 'package:clinic_pro/core/themes/app_colors.dart';
import 'package:clinic_pro/core/themes/app_text_styles.dart';
import 'package:clinic_pro/core/utils/responsive_helper.dart';
import 'package:clinic_pro/core/widgets/shimmer_list.dart';
import 'package:clinic_pro/features/auth/presentation/manager/auth_cubit.dart';
import 'package:clinic_pro/features/clinics/domain/entities/clinic_entity.dart';
import 'package:clinic_pro/features/clinics/presentation/manager/cubit/clinics_cubit.dart';
import 'package:clinic_pro/features/clinics/presentation/manager/cubit/clinics_state.dart';
import '../manager/financial_reports_cubit.dart';
import '../manager/reports_state.dart';
import 'widgets/reports_date_range_chips.dart';
import 'widgets/reports_summary_grid.dart';
import 'widgets/revenue_vs_expenses_chart.dart';
import 'widgets/expenses_chart.dart';

class FinancialReportsScreen extends StatelessWidget {
  final String? doctorId;

  const FinancialReportsScreen({super.key, this.doctorId});

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthCubit>().state.user?.id ?? '';

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: sl<FinancialReportsCubit>()),
        BlocProvider(
          create: (_) => sl<ClinicsCubit>()..fetchClinics(userId),
        ),
      ],
      child: _FinancialReportsBody(doctorId: doctorId),
    );
  }
}

class _FinancialReportsBody extends StatefulWidget {
  final String? doctorId;
  const _FinancialReportsBody({this.doctorId});

  @override
  State<_FinancialReportsBody> createState() => _FinancialReportsBodyState();
}

class _FinancialReportsBodyState extends State<_FinancialReportsBody> {
  @override
  void initState() {
    super.initState();
    context.read<FinancialReportsCubit>().loadReports(doctorId: widget.doctorId);
  }

  @override
  void dispose() {
    sl<FinancialReportsCubit>().clear();
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
          AppStrings.isArabic ? 'التقارير المالية' : 'Financial Reports',
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
      body: BlocBuilder<FinancialReportsCubit, FinancialReportsState>(
        builder: (context, state) {
          if (state is FinancialReportsLoading) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: ShimmerList(itemCount: 5),
            );
          }
          if (state is FinancialReportsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<FinancialReportsCubit>().loadReports(forceRefresh: true),
                    child: Text(AppStrings.retry),
                  ),
                ],
              ),
            );
          }
          if (state is FinancialReportsLoaded) {
            final summary = ReportSummary(
              revenue: state.summary.totalRevenue,
              collected: state.summary.collectedAmount,
              expenses: state.summary.totalExpenses,
              netProfit: state.summary.netProfit,
              totalPatients: 0,
              revenueChange: state.summary.revenueChange,
              expensesChange: state.summary.expensesChange,
            );

            final weeklyData = state.summary.chart
                .map((c) => WeeklyData(
                      week: c.week,
                      revenue: c.revenue,
                      collected: c.collected,
                      expenses: c.expenses,
                    ))
                .toList();

            final expenseCategories = state.summary.expensesBreakdown
                .map((e) => {
                      'category': e.category,
                      'amount': e.amount,
                      'percentage': e.percentage,
                    })
                .toList();

            return RefreshIndicator(
              onRefresh: () async {
                await context
                    .read<FinancialReportsCubit>()
                    .loadReports(doctorId: widget.doctorId, forceRefresh: true);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: ResponsiveHelper.responsiveCenter(
                  maxWidth: 1100,
                  child: Column(
                    children: [
                      // Clinic Filter Dropdown
                      BlocBuilder<ClinicsCubit, ClinicsState>(
                        builder: (context, clinicsState) {
                          if (clinicsState is ClinicsLoaded &&
                              clinicsState.clinics.isNotEmpty) {
                            final List<ClinicEntity> clinics = clinicsState.clinics;
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: context.surfaceColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: context.borderColor, width: 0.5),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.local_hospital_outlined,
                                        size: 20, color: context.primary),
                                    const SizedBox(width: 8),
                                    Text(
                                      AppStrings.isArabic ? 'العيادة:' : 'Clinic:',
                                      style: AppTextStyles.bodyMedium(context)
                                          .copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String?>(
                                          isExpanded: true,
                                          value: state.selectedClinicId,
                                          hint: Text(
                                            AppStrings.isArabic
                                                ? 'جميع العيادات'
                                                : 'All Clinics',
                                            style:
                                                AppTextStyles.bodyMedium(context),
                                          ),
                                          items: [
                                            DropdownMenuItem<String?>(
                                              value: null,
                                              child: Text(
                                                AppStrings.isArabic
                                                    ? 'جميع العيادات'
                                                    : 'All Clinics',
                                                style: AppTextStyles.bodyMedium(
                                                        context)
                                                    .copyWith(
                                                  fontWeight:
                                                      state.selectedClinicId ==
                                                              null
                                                          ? FontWeight.bold
                                                          : FontWeight.normal,
                                                ),
                                              ),
                                            ),
                                            ...clinics.map((clinic) {
                                              return DropdownMenuItem<String?>(
                                                value: clinic.id,
                                                child: Text(
                                                  clinic.name,
                                                  style: AppTextStyles.bodyMedium(
                                                      context),
                                                ),
                                              );
                                            }),
                                          ],
                                          onChanged: (clinicId) {
                                            context
                                                .read<FinancialReportsCubit>()
                                                .changeClinic(clinicId, doctorId: widget.doctorId);
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                      const SizedBox(height: 12),

                      ReportsDateRangeChips(
                        activeRange: state.activeRange,
                        customDateRange: state.customDateRange,
                        onChanged: (range) {
                          context.read<FinancialReportsCubit>().changeRange(range, doctorId: widget.doctorId);
                        },
                        onCustomRangeSelected: (customRange) {
                          context.read<FinancialReportsCubit>().changeRange(
                                ReportsDateRange.custom,
                                customDateRange: customRange,
                                doctorId: widget.doctorId,
                              );
                        },
                      ),
                      const SizedBox(height: 12),
                      ReportsSummaryGrid(summary: summary),
                      const SizedBox(height: 16),
                      RevenueVsExpensesChart(data: weeklyData),
                      if (expenseCategories.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: ExpensesDonutChart(
                            categories: expenseCategories,
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

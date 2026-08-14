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
import '../manager/drug_reports_cubit.dart';
import 'widgets/reports_date_range_chips.dart';
import 'widgets/drug_stats_section.dart';
import 'widgets/drug_kpi_cards.dart';
import 'widgets/prescription_trend_chart.dart';
import 'widgets/top_diagnoses_widget.dart';
import 'widgets/template_usage_widget.dart';
import 'widgets/advanced_drug_analytics_widget.dart';

class DrugReportsScreen extends StatelessWidget {
  final String? doctorId;

  const DrugReportsScreen({super.key, this.doctorId});

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthCubit>().state.user?.id ?? '';

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: sl<DrugReportsCubit>()),
        BlocProvider(
          create: (_) => sl<ClinicsCubit>()..fetchClinics(userId),
        ),
      ],
      child: _DrugReportsBody(doctorId: doctorId),
    );
  }
}

class _DrugReportsBody extends StatefulWidget {
  final String? doctorId;
  const _DrugReportsBody({this.doctorId});

  @override
  State<_DrugReportsBody> createState() => _DrugReportsBodyState();
}

class _DrugReportsBodyState extends State<_DrugReportsBody> {
  @override
  void initState() {
    super.initState();
    context.read<DrugReportsCubit>().loadReports(doctorId: widget.doctorId);
  }

  @override
  void dispose() {
    sl<DrugReportsCubit>().clear();
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
          AppStrings.isArabic ? 'تقارير الأدوية' : 'Drugs Reports',
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
      body: BlocBuilder<DrugReportsCubit, DrugReportsState>(
        builder: (context, state) {
          if (state is DrugReportsLoading) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: ShimmerList(itemCount: 5),
            );
          }
          if (state is DrugReportsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<DrugReportsCubit>().loadReports(doctorId: widget.doctorId, forceRefresh: true),
                    child: Text(AppStrings.retry),
                  ),
                ],
              ),
            );
          }
          if (state is DrugReportsLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                await context
                    .read<DrugReportsCubit>()
                    .loadReports(doctorId: widget.doctorId, forceRefresh: true);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
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
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              margin: const EdgeInsets.only(bottom: 12),
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
                                              .read<DrugReportsCubit>()
                                              .changeClinic(clinicId, doctorId: widget.doctorId);
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                      ReportsDateRangeChips(
                        activeRange: state.activeRange,
                        onChanged: (range) {
                          context.read<DrugReportsCubit>().changeRange(range, doctorId: widget.doctorId);
                        },
                      ),
                      const SizedBox(height: 16),
                      DrugKpiCardsWidget(stats: state.stats),
                      const SizedBox(height: 16),
                      PrescriptionTrendChartWidget(trend: state.stats.monthlyTrend),
                      const SizedBox(height: 16),
                      DrugStatsSectionWidget(stats: state.stats),
                      const SizedBox(height: 16),
                      if (!ResponsiveHelper.isMobile(context))
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: TopDiagnosesWidget(diagnoses: state.stats.topDiagnoses)),
                            const SizedBox(width: 16),
                            Expanded(child: TemplateUsageWidget(templates: state.stats.templateStats)),
                          ],
                        )
                      else ...[
                        TopDiagnosesWidget(diagnoses: state.stats.topDiagnoses),
                        const SizedBox(height: 16),
                        TemplateUsageWidget(templates: state.stats.templateStats),
                      ],
                      const SizedBox(height: 16),
                      AdvancedDrugAnalyticsWidget(stats: state.stats),
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

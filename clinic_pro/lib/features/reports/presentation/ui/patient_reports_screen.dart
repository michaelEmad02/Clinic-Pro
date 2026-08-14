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
import '../manager/patient_reports_cubit.dart';
import '../manager/reports_state.dart';
import 'widgets/reports_date_range_chips.dart';
import 'widgets/patient_stats_section.dart';

class PatientReportsScreen extends StatelessWidget {
  final String? doctorId;

  const PatientReportsScreen({super.key, this.doctorId});

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthCubit>().state.user?.id ?? '';

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: sl<PatientReportsCubit>()),
        BlocProvider(
          create: (_) => sl<ClinicsCubit>()..fetchClinics(userId),
        ),
      ],
      child: _PatientReportsBody(doctorId: doctorId),
    );
  }
}

class _PatientReportsBody extends StatefulWidget {
  final String? doctorId;
  const _PatientReportsBody({this.doctorId});

  @override
  State<_PatientReportsBody> createState() => _PatientReportsBodyState();
}

class _PatientReportsBodyState extends State<_PatientReportsBody> {
  @override
  void initState() {
    super.initState();
    context.read<PatientReportsCubit>().loadReports(doctorId: widget.doctorId);
  }

  @override
  void dispose() {
    sl<PatientReportsCubit>().clear();
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
          AppStrings.isArabic ? 'تقارير المرضى' : 'Patient Reports',
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
      body: BlocBuilder<PatientReportsCubit, PatientReportsState>(
        builder: (context, state) {
          if (state is PatientReportsLoading) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: ShimmerList(itemCount: 5),
            );
          }
          if (state is PatientReportsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<PatientReportsCubit>().loadReports(forceRefresh: true),
                    child: Text(AppStrings.retry),
                  ),
                ],
              ),
            );
          }
          if (state is PatientReportsLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                await context
                    .read<PatientReportsCubit>()
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
                                              .read<PatientReportsCubit>()
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
                        customDateRange: state.customDateRange,
                        onChanged: (range) {
                          context.read<PatientReportsCubit>().changeRange(range, doctorId: widget.doctorId);
                        },
                        onCustomRangeSelected: (customRange) {
                          context.read<PatientReportsCubit>().changeRange(
                                ReportsDateRange.custom,
                                customDateRange: customRange,
                                doctorId: widget.doctorId,
                              );
                        },
                      ),
                      const SizedBox(height: 16),
                      PatientStatsSectionWidget(stats: state.stats),
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

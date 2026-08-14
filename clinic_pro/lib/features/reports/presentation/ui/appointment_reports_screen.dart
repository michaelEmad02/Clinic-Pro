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
import '../manager/appointment_reports_cubit.dart';
import '../manager/reports_state.dart';
import 'widgets/reports_date_range_chips.dart';
import 'widgets/appointment_stats_section.dart';

class AppointmentReportsScreen extends StatelessWidget {
  final String? doctorId;

  const AppointmentReportsScreen({super.key, this.doctorId});

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthCubit>().state.user?.id ?? '';

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: sl<AppointmentReportsCubit>()),
        BlocProvider(
          create: (_) => sl<ClinicsCubit>()..fetchClinics(userId),
        ),
      ],
      child: _AppointmentReportsBody(doctorId: doctorId),
    );
  }
}

class _AppointmentReportsBody extends StatefulWidget {
  final String? doctorId;
  const _AppointmentReportsBody({this.doctorId});

  @override
  State<_AppointmentReportsBody> createState() =>
      _AppointmentReportsBodyState();
}

class _AppointmentReportsBodyState extends State<_AppointmentReportsBody> {
  @override
  void initState() {
    super.initState();
    context.read<AppointmentReportsCubit>().loadReports(doctorId: widget.doctorId);
  }

  @override
  void dispose() {
    sl<AppointmentReportsCubit>().clear();
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
          AppStrings.isArabic ? 'تقارير المواعيد' : 'Appointment Reports',
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
      body: BlocBuilder<AppointmentReportsCubit, AppointmentReportsState>(
        builder: (context, reportsState) {
          if (reportsState is AppointmentReportsLoading) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: ShimmerList(itemCount: 5),
            );
          }
          if (reportsState is AppointmentReportsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(reportsState.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context
                        .read<AppointmentReportsCubit>()
                        .loadReports(forceRefresh: true),
                    child: Text(AppStrings.retry),
                  ),
                ],
              ),
            );
          }
          if (reportsState is AppointmentReportsLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                await context
                    .read<AppointmentReportsCubit>()
                    .loadReports(doctorId: widget.doctorId, forceRefresh: true);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: ResponsiveHelper.responsiveCenter(
                  maxWidth: 1100,
                  child: Column(
                    children: [
                      // Clinic Filter Dropdown (using ClinicsCubit)
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
                                          value: reportsState.selectedClinicId,
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
                                                      reportsState.selectedClinicId ==
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
                                                .read<AppointmentReportsCubit>()
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

                      // Date Range Chips Filter
                      ReportsDateRangeChips(
                        activeRange: reportsState.activeRange,
                        customDateRange: reportsState.customDateRange,
                        onChanged: (range) {
                          context
                              .read<AppointmentReportsCubit>()
                              .changeRange(range, doctorId: widget.doctorId);
                        },
                        onCustomRangeSelected: (customRange) {
                          context.read<AppointmentReportsCubit>().changeRange(
                                ReportsDateRange.custom,
                                customDateRange: customRange,
                                doctorId: widget.doctorId,
                              );
                        },
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: AppointmentStatsSectionWidget(
                            stats: reportsState.stats),
                      ),
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

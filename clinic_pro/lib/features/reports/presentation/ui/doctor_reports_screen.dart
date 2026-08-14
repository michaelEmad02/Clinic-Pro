import 'package:clinic_pro/features/reports/presentation/manager/doctor_performance_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clinic_pro/core/di/injection_container.dart';
import 'package:clinic_pro/core/strings/app_strings.dart';
import 'package:clinic_pro/core/themes/app_colors.dart';
import 'package:clinic_pro/core/themes/app_text_styles.dart';
import 'package:clinic_pro/core/widgets/shimmer_list.dart';
import 'package:clinic_pro/features/auth/presentation/manager/auth_cubit.dart';
import 'package:clinic_pro/features/clinics/domain/entities/clinic_entity.dart';
import 'package:clinic_pro/features/clinics/presentation/manager/cubit/clinics_cubit.dart';
import 'package:clinic_pro/features/clinics/presentation/manager/cubit/clinics_state.dart';
import '../manager/reports_state.dart';
import 'widgets/reports_date_range_chips.dart';
import 'widgets/doctor_performance_list.dart';

class DoctorReportsScreen extends StatelessWidget {
  const DoctorReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthCubit>().state.user?.id ?? '';

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: sl<DoctorPerformanceCubit>()),
        BlocProvider(
          create: (_) => sl<ClinicsCubit>()..fetchClinics(userId),
        ),
      ],
      child: const _DoctorReportsBody(),
    );
  }
}

class _DoctorReportsBody extends StatefulWidget {
  const _DoctorReportsBody();

  @override
  State<_DoctorReportsBody> createState() => _DoctorReportsBodyState();
}

class _DoctorReportsBodyState extends State<_DoctorReportsBody> {
  @override
  void initState() {
    super.initState();
    context.read<DoctorPerformanceCubit>().loadReports();
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
          AppStrings.isArabic ? 'تقارير أداء الأطباء' : 'Doctor Performance',
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
      body: BlocBuilder<DoctorPerformanceCubit, DoctorPerformanceState>(
        builder: (context, state) {
          if (state is DoctorPerformanceLoading) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: ShimmerList(itemCount: 4),
            );
          }
          if (state is DoctorPerformanceError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<DoctorPerformanceCubit>().loadReports(forceRefresh: true),
                    child: Text(AppStrings.retry),
                  ),
                ],
              ),
            );
          }
          if (state is DoctorPerformanceLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                await context
                    .read<DoctorPerformanceCubit>()
                    .loadReports(forceRefresh: true);
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
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
                          margin: const EdgeInsets.only(bottom: 16),
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
                                          .read<DoctorPerformanceCubit>()
                                          .changeClinic(clinicId);
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
                  const SizedBox(height: 4),

                  // Date Range Filter Chips
                  ReportsDateRangeChips(
                    activeRange: state.activeRange,
                    customDateRange: state.customDateRange,
                    onChanged: (range) {
                      context
                          .read<DoctorPerformanceCubit>()
                          .changeRange(range);
                    },
                    onCustomRangeSelected: (customRange) {
                      context.read<DoctorPerformanceCubit>().changeRange(
                            ReportsDateRange.custom,
                            customDateRange: customRange,
                          );
                    },
                  ),
                  const SizedBox(height: 16),

                  DoctorPerformanceList(doctors: state.doctors),
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

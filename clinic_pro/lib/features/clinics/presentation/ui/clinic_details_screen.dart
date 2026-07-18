// ────────────────────────────────────────────────────────
// شاشة تفاصيل العيادة — تخطيط عمودين (رئيسي + جانبي) مع Bento Grid
// مستوحى من تصميم phase8_ui/clinic_details_screen
// ────────────────────────────────────────────────────────
import 'package:clinic_pro/core/enities/performance_statistics.dart';
import 'package:clinic_pro/features/clinics/presentation/manager/cubit/clinics_cubit.dart';
import 'package:clinic_pro/features/clinics/presentation/manager/cubit/fetch_clinic_by_id_cubit.dart';
import 'package:clinic_pro/features/clinics/presentation/manager/cubit/fetch_clinic_staff_cubit.dart';
import 'package:clinic_pro/features/clinics/presentation/manager/cubit/fetch_clinic_statistics_cubit.dart';
import 'package:clinic_pro/features/clinics/presentation/ui/widgets/clinic_summary_cards.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../domain/entities/clinic_entity.dart';
import 'widgets/clinic_details_header.dart';
import 'widgets/clinic_staff_section.dart';
import 'widgets/clinic_performance_chart.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/strings/app_strings.dart';
import '../../../../core/themes/app_text_styles.dart';

class ClinicDetailsScreen extends StatelessWidget {
  final String id;

  const ClinicDetailsScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<FetchClinicByIdCubit>()..fetchClinicById(id),
        ),
        BlocProvider(
          create: (context) =>
              sl<FetchClinicStatisticsCubit>()..fetchClinicStatistics(id),
        ),
        BlocProvider(
          create: (context) => sl<ClinicsCubit>(),
        ),
        BlocProvider(
          create: (context) =>
              sl<FetchClinicStaffCubit>()..fetchClinicStaff(id),
        ),
      ],
      child: _ClinicDetailsBody(id: id),
    );
  }
}

class _ClinicDetailsBody extends StatelessWidget {
  final String id;

  const _ClinicDetailsBody({required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.background,
      appBar: AppBar(
        backgroundColor: context.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.textSecondary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppStrings.clinicDetails,
          style: AppTextStyles.headlineMedium(context),
        ),
        actions: [
          Container(
            margin: const EdgeInsetsDirectional.only(end: AppConstants.spaceSm),
            decoration: BoxDecoration(
              color: context.primaryLightColor,
              borderRadius: BorderRadius.circular(AppConstants.radiusChip),
            ),
            child: IconButton(
              icon: Icon(Icons.edit_outlined, color: context.primary, size: 20),
              onPressed: () {},
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: context.border, height: 1),
        ),
      ),
      body: BlocBuilder<FetchClinicByIdCubit, FetchClinicByIdState>(
        builder: (context, state) {
          if (state is FetchClinicByIdILoadind) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is FetchClinicByIdLoaded) {
            return _DetailsContent(clinic: state.clinic);
          } else if (state is FetchClinicByIdFailure) {
            return Center(child: Text(AppStrings.loadFailed));
          }
          return const Center();
        },
      ),
    );
  }
}

class _DetailsContent extends StatelessWidget {
  final ClinicEntity clinic;

  const _DetailsContent({required this.clinic});

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    List<PerformanceStatistics> performanceStatistics = [];

    return RefreshIndicator(
      onRefresh: () async {
        context
            .read<FetchClinicStatisticsCubit>()
            .fetchClinicStatistics(clinic.id);
        context.read<FetchClinicStaffCubit>().fetchClinicStaff(clinic.id);
        context.read<FetchClinicByIdCubit>().fetchClinicById(clinic.id);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppConstants.spaceMd),
        child: Center(
          child: SizedBox(
            width: isDesktop ? 1000 : double.infinity,
            child: Column(
              children: [
                ClinicDetailsHeader(clinic: clinic),
                const SizedBox(height: AppConstants.spaceMd),
                BlocBuilder<FetchClinicStatisticsCubit,
                    FetchClinicStatisticsState>(
                  builder: (context, state) {
                    if (state is FetchClinicStatisticsLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is FetchClinicStatisticsLoaded) {
                      performanceStatistics =
                          state.clinicStatistics.clinicMonthlyPerformance;
                      return ClinicSummaryCards(
                          statistics: state.clinicStatistics);
                    } else if (state is FetchClinicStatisticsFailure) {
                      return Center(
                          child: Text(
                              '${AppStrings.loadFailed} \n ${state.message}'));
                    }
                    return const Center();
                  },
                ),
                const SizedBox(height: AppConstants.spaceMd),
                ClinicPerformanceChart(
                    performanceStatistics: performanceStatistics),
                const SizedBox(height: AppConstants.spaceMd),
                // تخطيط عمودين في سطح المكتب، عمود واحد في الجوال
                if (isDesktop)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: ClinicStaffSection(clinicId: clinic.id),
                      ),
                      const SizedBox(width: 16),
                      // Expanded(
                      //   flex: 1,
                      //   child: _SidebarColumn(clinicId: clinic.id),
                      // ),
                    ],
                  )
                else
                  Column(
                    children: [
                      ClinicStaffSection(clinicId: clinic.id),
                      const SizedBox(height: AppConstants.spaceMd),
                      // _SidebarColumn(clinicId: clinic.id),
                    ],
                  ),
                const SizedBox(height: AppConstants.spaceLg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


// class _SidebarColumn extends StatelessWidget {
//   final String clinicId;

//   const _SidebarColumn({required this.clinicId});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         ClinicWorkingHoursSection(clinicId: clinicId),
//         const SizedBox(height: AppConstants.spaceMd),
//         const ClinicMapPlaceholder(),
//       ],
//     );
//   }
// }

// ────────────────────────────────────────────────────────
// شاشة تفاصيل المريض — تبويبات: المعلومات / الزيارات / الروشتات
// تستخدم PatientDetailsCubit بدلاً من FutureBuilder المباشر
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/utils/responsive_helper.dart';
import 'package:clinic_pro/features/patients/presentation/manager/patient_details_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/strings/app_strings.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/widgets/shimmer_list.dart';
import '../manager/patient_details_cubit.dart';
import 'widgets/patient_info_tab.dart';
import 'widgets/patient_prescriptions_tab.dart';
import 'widgets/patient_sliver_app_bar.dart';
import 'widgets/patient_visits_tab.dart';

class PatientDetailsScreen extends StatelessWidget {
  final String id;

  const PatientDetailsScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<PatientDetailsCubit>()..loadPatientDetails(id),
      child: BlocBuilder<PatientDetailsCubit, PatientDetailsState>(
        builder: (context, state) {
          if (state is PatientDetailsLoading) {
            return Scaffold(
              appBar: AppBar(title: Text(AppStrings.patientDetails)),
              body: const Padding(
                padding: EdgeInsets.all(16),
                child: ShimmerList(itemCount: 4),
              ),
            );
          }

          if (state is PatientDetailsError) {
            return Scaffold(
              appBar: AppBar(title: Text(AppStrings.patientDetails)),
              body: Center(
                child: Text(
                  AppStrings.isArabic ? 'المريض غير موجود' : 'Patient not found',
                ),
              ),
            );
          }

          if (state is PatientDetailsLoaded) {
            final patient = state.patient;
            return DefaultTabController(
              length: 3,
              child: Scaffold(
                backgroundColor: context.background,
                body: ResponsiveHelper.responsiveCenter(
                  maxWidth: 1100,
                  child: NestedScrollView(
                    headerSliverBuilder: (context, innerBoxIsScrolled) => [
                      PatientSliverAppBar(patient: patient),
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: _TabBarDelegate(
                          TabBar(
                            labelColor: context.primary,
                            unselectedLabelColor: context.textSecondary,
                            indicatorColor: context.primary,
                            labelStyle: AppTextStyles.bodyMedium(context).copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            tabs: [
                              Tab(text: AppStrings.isArabic ? 'المعلومات' : 'Info'),
                              Tab(text: AppStrings.isArabic ? 'الزيارات' : 'Visits'),
                              Tab(text: AppStrings.isArabic ? 'الروشتات' : 'Prescriptions'),
                            ],
                          ),
                        ),
                      ),
                    ],
                    body: TabBarView(
                      children: [
                        PatientInfoTab(patient: patient),
                        PatientVisitsTab(
                          visits: state.visits,
                          isLoading: state.visitsLoading,
                        ),
                        PatientPrescriptionsTab(patientId: id),
                      ],
                    ),
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

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _TabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: context.surface,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) => false;
}

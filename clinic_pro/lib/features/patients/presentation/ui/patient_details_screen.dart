// ────────────────────────────────────────────────────────
// شاشة تفاصيل المريض — تبويبات: المعلومات / الزيارات / الروشتات
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/strings/app_strings.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/widgets/shimmer_list.dart';
import '../manager/patients_repository.dart';
import '../manager/patients_state.dart';
import 'widgets/patient_info_tab.dart';
import 'widgets/patient_prescriptions_tab.dart';
import 'widgets/patient_sliver_app_bar.dart';
import 'widgets/patient_visits_tab.dart';

class PatientDetailsScreen extends StatelessWidget {
  final String id;

  const PatientDetailsScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    final repo = sl<PatientsRepository>();

    return FutureBuilder<PatientItem?>(
      future: repo.findPatientById(id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: Text(AppStrings.patientDetails)),
            body: const Padding(
              padding: EdgeInsets.all(16),
              child: ShimmerList(itemCount: 4),
            ),
          );
        }

        final patient = snapshot.data;
        if (patient == null || snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: Text(AppStrings.patientDetails)),
            body: Center(child: Text(AppStrings.isArabic ? 'المريض غير موجود' : 'Patient not found')),
          );
        }

        return DefaultTabController(
          length: 3,
          child: Scaffold(
            backgroundColor: context.background,
            body: NestedScrollView(
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
                  PatientVisitsTab(patientId: id),
                  PatientPrescriptionsTab(patientId: id),
                ],
              ),
            ),
          ),
        );
      },
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

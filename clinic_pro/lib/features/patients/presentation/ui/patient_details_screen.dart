// ────────────────────────────────────────────────────────
// شاشة تفاصيل المريض — تبويبات: المعلومات / الزيارات / الروشتات
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../manager/patients_cubit.dart';
import 'widgets/patient_info_tab.dart';
import 'widgets/patient_prescriptions_tab.dart';
import 'widgets/patient_sliver_app_bar.dart';
import 'widgets/patient_visits_tab.dart';

class PatientDetailsScreen extends StatelessWidget {
  final String id;

  const PatientDetailsScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    final patient = PatientsCubit.findPatientById(id);

    if (patient == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('تفاصيل المريض')),
        body: const Center(child: Text('المريض غير موجود')),
      );
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            PatientSliverAppBar(patient: patient),
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabBarDelegate(
                TabBar(
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textSecondary,
                  indicatorColor: AppColors.primary,
                  labelStyle: AppTextStyles.bodyMedium(context).copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  tabs: const [
                    Tab(text: 'المعلومات'),
                    Tab(text: 'الزيارات'),
                    Tab(text: 'الروشتات'),
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
      color: AppColors.surface,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) => false;
}

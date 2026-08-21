// ────────────────────────────────────────────────────────
// تبويب الزيارات في تفاصيل المريض — يستعرض سجل الزيارات
// بتصميم متجاوب Responsive UI بعمودين للشاشات الواسعة وقائمة رأسية للجوال
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/utils/responsive_helper.dart';
import 'package:flutter/material.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/widgets/app_loading.dart';
import '../../../../../core/widgets/empty_state.dart';
import '../../../../appointments/domain/entities/appointment_entity.dart';
import 'visit_timeline_item.dart';

class PatientVisitsTab extends StatelessWidget {
  final List<AppointmentEntity> visits;
  final bool isLoading;

  const PatientVisitsTab({
    super.key,
    required this.visits,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: AppLoadingWidget());
    }

    if (visits.isEmpty) {
      return EmptyState(
        title: AppStrings.isArabic ? 'لا توجد زيارات' : 'No Visits',
        subtitle: AppStrings.isArabic
            ? 'لم يُسجَّل أي زيارة لهذا المريض بعد.'
            : 'No visits have been recorded for this patient.',
        icon: Icons.history_outlined,
      );
    }

    final isMobile = ResponsiveHelper.isMobile(context);

    if (isMobile) {
      return ListView.builder(
        padding: const EdgeInsets.all(AppConstants.spaceMd),
        itemCount: visits.length,
        itemBuilder: (context, index) {
          return VisitTimelineItem(
            visit: visits[index],
            isLast: index == visits.length - 1,
          );
        },
      );
    }

    // تقسيم سجل الزيارات في عمودين متوازيين للشاشات الواسعة
    final leftColumnVisits = <AppointmentEntity>[];
    final rightColumnVisits = <AppointmentEntity>[];

    for (int i = 0; i < visits.length; i++) {
      if (i % 2 == 0) {
        leftColumnVisits.add(visits[i]);
      } else {
        rightColumnVisits.add(visits[i]);
      }
    }

    return ResponsiveHelper.responsiveCenter(
      maxWidth: 1100,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spaceMd),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: List.generate(
                  leftColumnVisits.length,
                  (index) => VisitTimelineItem(
                    visit: leftColumnVisits[index],
                    isLast: false,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                children: List.generate(
                  rightColumnVisits.length,
                  (index) => VisitTimelineItem(
                    visit: rightColumnVisits[index],
                    isLast: false,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

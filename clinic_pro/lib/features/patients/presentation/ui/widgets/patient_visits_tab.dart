// ────────────────────────────────────────────────────────
// تبويب الزيارات في تفاصيل المريض — يستعرض سجل الزيارات
// بتصميم متجاوب Responsive UI بعمودين للشاشات الواسعة وقائمة رأسية للجوال
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/constants/route_constants.dart';
import 'package:clinic_pro/core/utils/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
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

    final summaryChip = Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: context.primaryLightColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.primary.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.history_rounded, size: 15, color: context.primary),
          const SizedBox(width: 6),
          Text(
            '${AppStrings.isArabic ? "سجل الزيارات: " : "Visits History: "}${visits.length}',
            style: AppTextStyles.caption(context).copyWith(
              fontWeight: FontWeight.bold,
              color: context.primary,
            ),
          ),
        ],
      ),
    );

    if (isMobile) {
      return ListView.builder(
        padding: const EdgeInsets.all(AppConstants.spaceMd),
        itemCount: visits.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Align(
              alignment: AlignmentDirectional.centerStart,
              child: summaryChip,
            );
          }
          final visit = visits[index - 1];
          return VisitTimelineItem(
            visit: visit,
            isLast: index == visits.length,
            onTap: () => context.push('${RouteConstants.appointments}/${visit.id}'),
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

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      child: ResponsiveHelper.responsiveCenter(
        maxWidth: 1100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            summaryChip,
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: List.generate(
                      leftColumnVisits.length,
                      (index) {
                        final visit = leftColumnVisits[index];
                        return VisitTimelineItem(
                          visit: visit,
                          isLast: false,
                          onTap: () => context.push('${RouteConstants.appointments}/${visit.id}'),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: List.generate(
                      rightColumnVisits.length,
                      (index) {
                        final visit = rightColumnVisits[index];
                        return VisitTimelineItem(
                          visit: visit,
                          isLast: false,
                          onTap: () => context.push('${RouteConstants.appointments}/${visit.id}'),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

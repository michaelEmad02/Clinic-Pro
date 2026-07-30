// ────────────────────────────────────────────────────────
// تبويب الزيارات في تفاصيل المريض
// يستخدم AppointmentEntity مباشرة من طبقة المواعيد
// البيانات تمرر من PatientDetailsCubit بدلاً من FutureBuilder
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/strings/app_strings.dart';
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
      return const Center(child: CircularProgressIndicator());
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
}

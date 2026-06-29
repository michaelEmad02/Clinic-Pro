// ────────────────────────────────────────────────────────
// تبويب الزيارات في تفاصيل المريض
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/widgets/empty_state.dart';
import '../../manager/patients_cubit.dart';
import 'visit_timeline_item.dart';

class PatientVisitsTab extends StatelessWidget {
  final String patientId;

  const PatientVisitsTab({super.key, required this.patientId});

  @override
  Widget build(BuildContext context) {
    final visits = PatientsCubit.getVisitsForPatient(patientId);

    if (visits.isEmpty) {
      return const EmptyState(
        title: 'لا توجد زيارات',
        subtitle: 'لم يُسجَّل أي زيارة لهذا المريض بعد.',
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

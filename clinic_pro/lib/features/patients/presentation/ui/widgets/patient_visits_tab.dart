// ────────────────────────────────────────────────────────
// تبويب الزيارات في تفاصيل المريض
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/widgets/empty_state.dart';
import '../../manager/patients_repository.dart';
import '../../manager/patients_state.dart';
import 'visit_timeline_item.dart';

class PatientVisitsTab extends StatelessWidget {
  final String patientId;

  const PatientVisitsTab({super.key, required this.patientId});

  @override
  Widget build(BuildContext context) {
    final repo = sl<PatientsRepository>();

    return FutureBuilder<List<PatientVisitItem>>(
      future: repo.getVisitsForPatient(patientId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final visits = snapshot.data ?? [];
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
      },
    );
  }
}

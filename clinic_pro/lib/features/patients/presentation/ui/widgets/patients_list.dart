// ────────────────────────────────────────────────────────
// قائمة المرضى
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/widgets/empty_state.dart';
import '../../manager/patients_state.dart';
import 'patient_list_item.dart';

class PatientsList extends StatelessWidget {
  final List<PatientItem> patients;
  final ValueChanged<PatientItem> onItemTap;
  final ValueChanged<PatientItem> onItemMore;

  const PatientsList({
    super.key,
    required this.patients,
    required this.onItemTap,
    required this.onItemMore,
  });

  @override
  Widget build(BuildContext context) {
    if (patients.isEmpty) {
      return EmptyState(
        title: AppStrings.noPatients,
        subtitle: AppStrings.noPatients,
        icon: Icons.people_outline,
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: patients.length,
      itemBuilder: (context, index) {
        final patient = patients[index];
        return PatientListItem(
          patient: patient,
          onTap: () => onItemTap(patient),
          onMore: () => onItemMore(patient),
        );
      },
    );
  }
}

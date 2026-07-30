// ────────────────────────────────────────────────────────
// قائمة المرضى
// يستخدم PatientEntity من طبقة الدومين
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/utils/responsive_helper.dart';
import '../../../../../core/widgets/empty_state.dart';
import '../../../domain/entities/patient_entity.dart';
import 'patient_list_item.dart';

class PatientsList extends StatelessWidget {
  final List<PatientEntity> patients;
  final ValueChanged<PatientEntity> onItemTap;
  final ValueChanged<PatientEntity> onItemMore;

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

    final isMobile = ResponsiveHelper.isMobile(context);

    if (!isMobile) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: ResponsiveHelper.gridColumns(context),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          mainAxisExtent: 110,
        ),
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

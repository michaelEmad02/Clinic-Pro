// ────────────────────────────────────────────────────────
// شبكة العيادات — Grid متجاوب (1/2/3 أعمدة) بتصميم Bento
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../../core/utils/responsive_helper.dart';
import '../../../../../core/widgets/empty_state.dart';
import '../../manager/clinics_state.dart';
import 'clinic_card.dart';

class ClinicsList extends StatelessWidget {
  final List<ClinicItem> clinics;
  final ValueChanged<ClinicItem> onItemTap;
  final ValueChanged<ClinicItem> onItemEdit;
  final ValueChanged<ClinicItem> onItemToggleActive;
  final ValueChanged<ClinicItem> onItemDelete;

  const ClinicsList({
    super.key,
    required this.clinics,
    required this.onItemTap,
    required this.onItemEdit,
    required this.onItemToggleActive,
    required this.onItemDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (clinics.isEmpty) {
      return const EmptyState(
        title: 'لا توجد عيادات',
        subtitle: 'قم بإضافة أول عيادة لك الآن.',
        icon: Icons.local_hospital_outlined,
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = ResponsiveHelper.gridColumns(context);
          return GridView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.15,
            ),
            itemCount: clinics.length,
            itemBuilder: (context, index) {
              final clinic = clinics[index];
              return ClinicCard(
                clinic: clinic,
                onTap: () => onItemTap(clinic),
                onEdit: () => onItemEdit(clinic),
                onToggleActive: () => onItemToggleActive(clinic),
                onDelete: () => onItemDelete(clinic),
              );
            },
          );
        },
      ),
    );
  }
}

// ────────────────────────────────────────────────────────
// شبكة العيادات — Grid متجاوب (1/2/3 أعمدة) بتصميم Bento
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/utils/responsive_helper.dart';
import '../../../../../core/widgets/empty_state.dart';
import '../../../domain/entities/clinic_entity.dart';
import 'clinic_card.dart';

class ClinicsList extends StatelessWidget {
  final List<ClinicEntity> clinics;
  final ValueChanged<ClinicEntity> onItemTap;
  final ValueChanged<ClinicEntity> onItemEdit;
  final ValueChanged<ClinicEntity> onItemToggleActive;
  final ValueChanged<ClinicEntity> onItemDelete;

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
      return EmptyState(
        title: AppStrings.noClinics,
        subtitle: AppStrings.addFirstClinic,
        icon: Icons.local_hospital_outlined,
      );
    }

    return Padding(
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = ResponsiveHelper.isMobile(context);
          final crossAxisCount = ResponsiveHelper.gridColumns(context);
          return GridView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: AppConstants.spaceSm + AppConstants.spaceXs,
              mainAxisSpacing: AppConstants.spaceSm + AppConstants.spaceXs,
              childAspectRatio: isMobile ? 1.5 : 1.6,
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

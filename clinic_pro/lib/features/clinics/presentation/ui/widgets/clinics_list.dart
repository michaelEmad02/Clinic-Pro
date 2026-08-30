// ────────────────────────────────────────────────────────
// شبكة العيادات — Grid متجاوب (1/2/3 أعمدة) بتصميم Bento
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/strings/app_strings.dart';
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
          final width = constraints.maxWidth;
          // حساب عدد الأعمدة بناءً على المساحة المتاحة للحاوية
          final int crossAxisCount = width >= 900
              ? 3
              : (width >= 600 ? 2 : 1);

          // ضبط الـ Aspect Ratio ليكون الكارت ملموماً وارتفاعه أنيقاً
          final double childAspectRatio = crossAxisCount == 1
              ? (width < 380 ? 2.3 : 2.7)
              : (width >= 1100 ? 2.0 : 1.85);

          return GridView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: AppConstants.spaceSm + 4,
              mainAxisSpacing: AppConstants.spaceSm + 4,
              childAspectRatio: childAspectRatio,
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

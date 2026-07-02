import 'package:flutter/material.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../manager/clinics_state.dart';
import 'clinic_card_header.dart';
import 'clinic_card_stats.dart';

class ClinicCard extends StatelessWidget {
  final ClinicItem clinic;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onToggleActive;
  final VoidCallback onDelete;

  const ClinicCard({
    super.key,
    required this.clinic,
    required this.onTap,
    required this.onEdit,
    required this.onToggleActive,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final opacity = clinic.isActive ? 1.0 : 0.5;

    return Opacity(
      opacity: opacity,
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusCard),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppConstants.radiusCard),
          child: Container(
            padding: const EdgeInsets.all(AppConstants.spaceMd),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppConstants.radiusCard),
              border: Border.all(
                color: clinic.isActive
                    ? AppColors.border
                    : AppColors.danger.withOpacity(0.3),
              ),
              boxShadow: AppConstants.cardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClinicCardHeader(
                  clinic: clinic,
                  onEdit: onEdit,
                  onToggleActive: onToggleActive,
                  onDelete: onDelete,
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: AppColors.border),
                const SizedBox(height: 12),
                ClinicCardStats(clinic: clinic),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────
// Bottom Sheet إجراءات العيادة (···)
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/widgets/app_bottom_sheet.dart';
import '../../manager/clinics_state.dart';

class ClinicActionSheet {
  static Future<void> show({
    required BuildContext context,
    required ClinicItem clinic,
    required VoidCallback onViewDetails,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    return AppBottomSheet.show(
      context: context,
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(
            AppConstants.spaceMd, 0, AppConstants.spaceMd, AppConstants.spaceLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              clinic.name,
              style: AppTextStyles.headlineSmall(context).copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            Text(
              clinic.address,
              style: AppTextStyles.bodyMedium(context).copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppConstants.spaceMd),
            _ActionTile(
              icon: Icons.info_outline,
              label: AppStrings.viewDetails,
              color: AppColors.primary,
              onTap: () {
                Navigator.pop(context);
                onViewDetails();
              },
            ),
            _ActionTile(
              icon: Icons.edit_document,
              label: AppStrings.editData,
              color: AppColors.primaryContainer,
              onTap: () {
                Navigator.pop(context);
                onEdit();
              },
            ),
            _ActionTile(
              icon: Icons.delete_outline,
              label: AppStrings.deleteClinic,
              color: AppColors.danger,
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(context, onDelete);
              },
            ),
          ],
        ),
      ),
    );
  }

  static void _confirmDelete(
      BuildContext context, VoidCallback onDelete) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.confirmDelete),
        content: const Text(AppStrings.confirmDeleteAction),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onDelete();
            },
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        label,
        style: AppTextStyles.bodyMedium(context).copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}

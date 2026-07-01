// ────────────────────────────────────────────────────────
// Bottom Sheet إجراءات المريض (···)
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/widgets/app_bottom_sheet.dart';
import '../../manager/patients_state.dart';

class PatientActionSheet {
  static Future<void> show({
    required BuildContext context,
    required PatientItem patient,
    required VoidCallback onViewDetails,
    required VoidCallback onEdit,
    required VoidCallback onBookAppointment,
    required VoidCallback onDeletePatient,
  }) {
    return AppBottomSheet.show(
      context: context,
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              patient.name,
              style: AppTextStyles.headlineSmall(context).copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            Text(
              patient.phone,
              style: AppTextStyles.bodyMedium(context).copyWith(
                color: AppColors.textSecondary,
              ),
              textDirection: TextDirection.ltr,
            ),
            const SizedBox(height: 16),
            _ActionTile(
              icon: Icons.person_outline,
              label: 'عرض الملف',
              color: AppColors.primary,
              onTap: () {
                Navigator.pop(context);
                onViewDetails();
              },
            ),
            _ActionTile(
              icon: Icons.edit_document,
              label: 'تعديل البيانات',
              color: AppColors.primaryContainer,
              onTap: () {
                Navigator.pop(context);
                onEdit();
              },
            ),
            _ActionTile(
              icon: Icons.calendar_today_outlined,
              label: 'حجز موعد',
              color: AppColors.accent,
              onTap: () {
                Navigator.pop(context);
                onBookAppointment();
              },
            ),
            _ActionTile(
              icon: Icons.delete,
              label: 'حذف المريض',
              color: Colors.red,
              onTap: () {
                Navigator.pop(context);
                onDeletePatient();
              },
            ),
          ],
        ),
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

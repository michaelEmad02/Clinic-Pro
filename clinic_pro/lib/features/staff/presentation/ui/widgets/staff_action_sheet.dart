// ────────────────────────────────────────────────────────
// Bottom Sheet إجراءات الموظف (···)
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/widgets/app_bottom_sheet.dart';
import '../../manager/staff_state.dart';

class StaffActionSheet {
  static Future<void> show({
    required BuildContext context,
    required StaffItem staff,
    required VoidCallback onEditRole,
    required VoidCallback onToggleSuspend,
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
              staff.name,
              style: AppTextStyles.headlineSmall(context).copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            Text(
              staff.roleLabel,
              style: AppTextStyles.bodyMedium(context).copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            _ActionTile(
              icon: Icons.swap_horiz,
              label: 'تغيير الدور',
              color: AppColors.primary,
              onTap: () {
                Navigator.pop(context);
                onEditRole();
              },
            ),
            _ActionTile(
              icon: staff.isActive
                  ? Icons.pause_circle_outline
                  : Icons.check_circle_outline,
              label: staff.isActive ? 'تعليق الحساب' : 'إعادة التفعيل',
              color: staff.isActive ? AppColors.danger : AppColors.accent,
              onTap: () {
                Navigator.pop(context);
                onToggleSuspend();
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

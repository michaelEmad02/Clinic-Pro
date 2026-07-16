// ────────────────────────────────────────────────────────
// Bottom Sheet إجراءات الموظف (···)
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/widgets/app_bottom_sheet.dart';
import 'package:clinic_pro/features/staff/domain/entities/staff_entity.dart';

class StaffActionSheet {
  static Future<void> show({
    required BuildContext context,
    required StaffEntity staff,
    required VoidCallback onEditRole,
    required VoidCallback onToggleSuspend,
    required VoidCallback onDelete,
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
                color: context.primary,
              ),
            ),
            Text(
              staff.role.label,
              style: AppTextStyles.bodyMedium(context).copyWith(
                color: context.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            _ActionTile(
              icon: Icons.swap_horiz,
              label: AppStrings.changeRole,
              color: context.primary,
              onTap: () {
                Navigator.pop(context);
                onEditRole();
              },
            ),
            _ActionTile(
              icon: staff.isActive
                  ? Icons.pause_circle_outline
                  : Icons.check_circle_outline,
              label: staff.isActive
                  ? AppStrings.suspendAccount
                  : AppStrings.reactivateAccount,
              color: staff.isActive ? context.danger : context.accent,
              onTap: () {
                Navigator.pop(context);
                onToggleSuspend();
              },
            ),
            _ActionTile(
              icon: Icons.delete_outline,
              label: AppStrings.isArabic ? 'حذف الموظف' : 'Delete Staff',
              color: context.danger,
              onTap: () async {
                Navigator.pop(context);
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(AppStrings.isArabic ? 'تأكيد الحذف' : 'Confirm Delete'),
                    content: Text(AppStrings.isArabic
                        ? 'هل أنت متأكد من حذف هذا الموظف؟ لا يمكن التراجع عن هذا الإجراء.'
                        : 'Are you sure you want to delete this staff member? This action cannot be undone.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: Text(AppStrings.isArabic ? 'إلغاء' : 'Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: Text(
                          AppStrings.isArabic ? 'حذف' : 'Delete',
                          style: TextStyle(color: context.danger),
                        ),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  onDelete();
                }
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

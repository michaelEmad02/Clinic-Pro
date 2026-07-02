// ────────────────────────────────────────────────────────
// Bottom Sheet إجراءات الموعد (···)
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/widgets/app_bottom_sheet.dart';
import '../../manager/appointments_state.dart';

class AppointmentActionSheet {
  static Future<void> show({
    required BuildContext context,
    required AppointmentItem appointment,
    required VoidCallback? onConfirmArrival,
    required VoidCallback? onToggleUrgent,
    required VoidCallback? onCancel,
    required VoidCallback? onRegisterInvoice,
    required VoidCallback onViewDetails,
    VoidCallback? onEdit,
    VoidCallback? onDelete,
  }) {
    return AppBottomSheet.show(
      context: context,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              appointment.patientName,
              style: AppTextStyles.headlineSmall(context).copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            Text(
              '${appointment.typeName} • ${appointment.displayTime}',
              style: AppTextStyles.bodyMedium(context).copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            if (appointment.status == 'scheduled' && onConfirmArrival != null)
              _ActionTile(
                icon: Icons.check_circle_outline,
                label: 'تأكيد الحضور',
                color: AppColors.successText,
                onTap: () {
                  Navigator.pop(context);
                  onConfirmArrival();
                },
              ),
            // تعديل الموعد — فقط إذا لم يبدأ الكشف ولم ينتهِ بعد
            if (onEdit != null &&
                appointment.status != 'done' &&
                appointment.status != 'in_progress' &&
                appointment.status != 'cancelled')
              _ActionTile(
                icon: Icons.edit_outlined,
                label: 'تعديل الموعد',
                color: AppColors.primary,
                onTap: () {
                  Navigator.pop(context);
                  onEdit();
                },
              ),
            if (onToggleUrgent != null &&
                appointment.status != 'cancelled' &&
                appointment.status != 'done')
              _ActionTile(
                icon: Icons.priority_high,
                label: appointment.isUrgent ? 'إلغاء حالة الطوارئ' : 'تحديد كحالة طارئة',
                color: AppColors.warning,
                onTap: () {
                  Navigator.pop(context);
                  onToggleUrgent();
                },
              ),
            if (onRegisterInvoice != null &&
                appointment.status != 'cancelled' &&
                appointment.status != 'done')
              _ActionTile(
                icon: Icons.receipt_long_outlined,
                label: 'تسجيل فاتورة',
                color: AppColors.primaryContainer,
                onTap: () {
                  Navigator.pop(context);
                  onRegisterInvoice();
                },
              ),
            _ActionTile(
              icon: Icons.info_outline,
              label: 'عرض التفاصيل',
              color: AppColors.primary,
              onTap: () {
                Navigator.pop(context);
                onViewDetails();
              },
            ),
            if (appointment.status != 'done' &&
                appointment.status != 'cancelled' &&
                onCancel != null)
              _ActionTile(
                icon: Icons.cancel_outlined,
                label: 'إلغاء الموعد',
                color: AppColors.danger,
                onTap: () {
                  Navigator.pop(context);
                  onCancel();
                },
              ),
            if (appointment.status == 'cancelled' && onDelete != null)
              _ActionTile(
                icon: Icons.delete_outline,
                label: 'حذف الموعد نهائياً',
                color: AppColors.danger,
                onTap: () {
                  Navigator.pop(context);
                  onDelete();
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
        style: AppTextStyles.bodyMedium(context).copyWith(fontWeight: FontWeight.w600),
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}

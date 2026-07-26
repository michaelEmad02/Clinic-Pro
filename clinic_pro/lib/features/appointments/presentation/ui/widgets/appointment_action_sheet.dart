// ────────────────────────────────────────────────────────
// Bottom Sheet إجراءات الموعد (···)
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/constants/supabase_constants.dart';
import 'package:flutter/material.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/widgets/app_bottom_sheet.dart';
import '../../../domain/entities/appointment_entity.dart';

class AppointmentActionSheet {
  static Future<void> show({
    required BuildContext context,
    required AppointmentEntity appointment,
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
              appointment.patientName ?? AppStrings.patient,
              style: AppTextStyles.headlineSmall(context).copyWith(
                fontWeight: FontWeight.bold,
                color: context.primary,
              ),
            ),
            Text(
              '${appointment.typeName ?? AppStrings.normalCheckup} • ${appointment.displayTime ?? ''}',
              style: AppTextStyles.bodyMedium(context).copyWith(
                color: context.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            if (appointment.status == AppointmentStatus.scheduled &&
                onConfirmArrival != null)
              _ActionTile(
                icon: Icons.check_circle_outline,
                label: AppStrings.confirmArrivalAction,
                color: context.success,
                onTap: () {
                  Navigator.pop(context);
                  onConfirmArrival();
                },
              ),
            // تعديل الموعد — فقط إذا لم يبدأ الكشف ولم ينتهِ بعد
            if (onEdit != null &&
                appointment.status != AppointmentStatus.done &&
                appointment.status != AppointmentStatus.inProgress &&
                appointment.status != AppointmentStatus.cancelled)
              _ActionTile(
                icon: Icons.edit_outlined,
                label: '${AppStrings.edit} ${AppStrings.appointment}',
                color: context.primary,
                onTap: () {
                  Navigator.pop(context);
                  onEdit();
                },
              ),
            if (onToggleUrgent != null &&
                appointment.status != AppointmentStatus.cancelled &&
                appointment.status != AppointmentStatus.done)
              _ActionTile(
                icon: Icons.priority_high,
                label: appointment.isUrgent
                    ? AppStrings.cancelEmergencyStatus
                    : AppStrings.markAsUrgent,
                color: context.warning,
                onTap: () {
                  Navigator.pop(context);
                  onToggleUrgent();
                },
              ),
            if (onRegisterInvoice != null &&
                appointment.status != AppointmentStatus.cancelled &&
                appointment.status != AppointmentStatus.done)
              _ActionTile(
                icon: Icons.receipt_long_outlined,
                label: AppStrings.createInvoice,
                color: context.primary,
                onTap: () {
                  Navigator.pop(context);
                  onRegisterInvoice();
                },
              ),
            _ActionTile(
              icon: Icons.info_outline,
              label: AppStrings.viewDetails,
              color: context.primary,
              onTap: () {
                Navigator.pop(context);
                onViewDetails();
              },
            ),
            if (appointment.status != AppointmentStatus.done &&
                appointment.status != AppointmentStatus.cancelled &&
                onCancel != null)
              _ActionTile(
                icon: Icons.cancel_outlined,
                label: '${AppStrings.cancel} ${AppStrings.appointment}',
                color: context.danger,
                onTap: () {
                  Navigator.pop(context);
                  onCancel();
                },
              ),
            if (appointment.status == AppointmentStatus.cancelled &&
                onDelete != null)
              _ActionTile(
                icon: Icons.delete_outline,
                label: AppStrings.deletePermanentlyAction,
                color: context.danger,
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
        style: AppTextStyles.bodyMedium(context)
            .copyWith(fontWeight: FontWeight.w600),
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}

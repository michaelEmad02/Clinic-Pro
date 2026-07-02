// ────────────────────────────────────────────────────────
// عنصر موعد واحد في قائمة المواعيد
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/widgets/app_list_item.dart';
import '../../../../../core/widgets/status_badge.dart';
import '../../manager/appointments_state.dart';

class AppointmentListItem extends StatelessWidget {
  final AppointmentItem appointment;
  final VoidCallback onTap;
  final VoidCallback onMore;

  const AppointmentListItem({
    super.key,
    required this.appointment,
    required this.onTap,
    required this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppListItem(
        onTap: onTap,
        title: appointment.patientName,
        subtitle:
            '${appointment.doctorName} • ${appointment.typeName} • ${appointment.displayTime}',
        leading: CircleAvatar(
          backgroundColor: appointment.isUrgent
              ? AppColors.dangerBg
              : AppColors.primaryLight,
          child: Icon(
            appointment.isUrgent
                ? Icons.priority_high
                : Icons.calendar_today_outlined,
            color: appointment.isUrgent ? AppColors.danger : AppColors.primary,
            size: 18,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              children: [
                if (appointment.isUrgent) ...[
                  const StatusBadge(
                      text: '🚨',
                      status: BadgeStatus.error,
                      addBackgroundColor: false),
                  const SizedBox(width: 8),
                ],
                _buildStatusBadge(appointment.status),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
              onPressed: onMore,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    switch (status) {
      case 'scheduled':
        return const StatusBadge(text: 'مجدول', status: BadgeStatus.info);
      case 'confirmed':
        return const StatusBadge(text: 'مؤكد', status: BadgeStatus.success);
      case 'in_progress':
        return const StatusBadge(
            text: 'قيد الكشف', status: BadgeStatus.warning);
      case 'done':
        return const StatusBadge(text: 'منتهي', status: BadgeStatus.success);
      case 'cancelled':
        return const StatusBadge(text: 'ملغي', status: BadgeStatus.error);
      default:
        return const StatusBadge(text: '—', status: BadgeStatus.info);
    }
  }
}

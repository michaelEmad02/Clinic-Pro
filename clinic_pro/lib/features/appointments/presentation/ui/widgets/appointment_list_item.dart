// ────────────────────────────────────────────────────────
// عنصر موعد واحد في قائمة المواعيد
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/widgets/status_badge.dart';
import '../../manager/appointments_state.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/themes/app_text_styles.dart';

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
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusCard),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spaceMd,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: BorderRadius.circular(AppConstants.radiusCard),
            border: Border.all(color: context.borderColor),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: appointment.isUrgent
                    ? AppColors.dangerBg
                    : context.primaryLightColor,
                child: Icon(
                  appointment.isUrgent
                      ? Icons.priority_high
                      : Icons.calendar_today_outlined,
                  color: appointment.isUrgent ? AppColors.danger : AppColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: AppConstants.spaceMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.patientName,
                      style: AppTextStyles.headlineSmall(context).copyWith(
                        color: context.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      appointment.doctorName,
                      style: AppTextStyles.bodyMedium(context).copyWith(
                        color: context.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      appointment.typeName,
                      style: AppTextStyles.bodyMedium(context).copyWith(
                        color: context.textSecondary,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      appointment.displayTime,
                      style: AppTextStyles.bodyMedium(context).copyWith(
                        color: context.textSecondary,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppConstants.spaceMd),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    color: context.textSecondary,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: onMore,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (appointment.isUrgent) ...[
                        const StatusBadge(
                          text: '🚨',
                          status: BadgeStatus.error,
                          addBackgroundColor: false,
                        ),
                        const SizedBox(width: 4),
                      ],
                      _buildStatusBadge(appointment.status),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    switch (status) {
      case 'scheduled':
        return StatusBadge(text: AppStrings.scheduled, status: BadgeStatus.info);
      case 'confirmed':
        return StatusBadge(text: AppStrings.confirmed, status: BadgeStatus.success);
      case 'in_progress':
        return StatusBadge(
            text: AppStrings.inProgress, status: BadgeStatus.warning);
      case 'done':
        return StatusBadge(text: AppStrings.completed, status: BadgeStatus.success);
      case 'cancelled':
        return StatusBadge(text: AppStrings.cancelled, status: BadgeStatus.error);
      default:
        return const StatusBadge(text: '—', status: BadgeStatus.info);
    }
  }
}

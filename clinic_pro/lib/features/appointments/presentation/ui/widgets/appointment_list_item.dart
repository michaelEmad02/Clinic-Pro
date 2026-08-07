// ────────────────────────────────────────────────────────
// عنصر موعد واحد في قائمة المواعيد
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/widgets/status_badge.dart';
import '../../../domain/entities/appointment_entity.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/themes/app_text_styles.dart';

class AppointmentListItem extends StatelessWidget {
  final AppointmentEntity appointment;
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
      padding: const EdgeInsets.only(bottom: AppConstants.spaceSm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusCard),
        child: Container(
          padding: const EdgeInsets.all(AppConstants.spaceMd),
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
                    ? context.dangerBg
                    : context.primaryLightColor,
                child: Icon(
                  appointment.isUrgent
                      ? Icons.priority_high
                      : Icons.calendar_today_outlined,
                  color: appointment.isUrgent ? context.danger : context.primary,
                  size: AppConstants.iconSizeLg,
                ),
              ),
              const SizedBox(width: AppConstants.spaceMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.patientName ?? AppStrings.patient,
                      style: AppTextStyles.headlineSmall(context).copyWith(
                        color: context.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppConstants.spaceXs),
                    Text(
                      appointment.doctorName ?? AppStrings.generalPractitioner,
                      style: AppTextStyles.bodyMedium(context).copyWith(
                        color: context.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      appointment.typeName ?? AppStrings.normalCheckup,
                      style: AppTextStyles.caption(context).copyWith(
                        color: context.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      appointment.displayTime ?? '',
                      style: AppTextStyles.caption(context).copyWith(
                        color: context.textSecondary,
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
                  const SizedBox(height: AppConstants.spaceSm),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (appointment.isUrgent) ...[
                        const StatusBadge(
                          text: '🚨',
                          status: BadgeStatus.error,
                          addBackgroundColor: false,
                        ),
                        const SizedBox(width: AppConstants.spaceXs),
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
        return StatusBadge(text: AppStrings.inProgress, status: BadgeStatus.warning);
      case 'done':
        return StatusBadge(text: AppStrings.completed, status: BadgeStatus.success);
      case 'cancelled':
        return StatusBadge(text: AppStrings.cancelled, status: BadgeStatus.error);
      default:
        return const StatusBadge(text: '—', status: BadgeStatus.info);
    }
  }
}

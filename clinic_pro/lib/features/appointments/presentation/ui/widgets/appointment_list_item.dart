// ────────────────────────────────────────────────────────
// عنصر موعد واحد في قائمة المواعيد
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/widgets/status_badge.dart';
import '../../../domain/entities/appointment_entity.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/constants/supabase_constants.dart';
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
                    // const SizedBox(height: AppConstants.spaceXs),
                    // Text(
                    //   appointment.doctorName ?? AppStrings.generalPractitioner,
                    //   style: AppTextStyles.bodyMedium(context).copyWith(
                    //     color: context.textSecondary,
                    //     fontWeight: FontWeight.w500,
                    //   ),
                    //   maxLines: 1,
                    //   overflow: TextOverflow.ellipsis,
                    // ),
                    const SizedBox(height: 2),
                    Text(
                      appointment.typeName ?? AppStrings.normalCheckup,
                      style: AppTextStyles.caption(context).copyWith(
                        color: context.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        if (appointment.arrivedAt != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: context.primaryLightColor,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.access_time_rounded,
                                  size: 12,
                                  color: context.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _formatArrivalTime(appointment.arrivedAt, context),
                                  style: AppTextStyles.caption(context).copyWith(
                                    color: context.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (appointment.displayTime != null &&
                            appointment.displayTime!.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: context.background,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: context.borderColor),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.event_note_rounded,
                                  size: 12,
                                  color: context.textSecondary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${AppStrings.isArabic ? 'الحجز:' : 'Booked:'} ${_formatDate(appointment.date)} ${appointment.displayTime}',
                                  style: AppTextStyles.caption(context).copyWith(
                                    color: context.textSecondary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if ((appointment.status == AppointmentStatus.confirmed ||
                                appointment.status == 'confirmed') &&
                            appointment.arrivedAt != null &&
                            DateTime.now()
                                    .difference(appointment.arrivedAt!.toLocal())
                                    .inHours >=
                                4)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: context.warningBg,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: context.warningText.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  size: 12,
                                  color: context.warningText,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  AppStrings.isArabic
                                      ? 'منتظر منذ ${DateTime.now().difference(appointment.arrivedAt!.toLocal()).inHours} ساعات'
                                      : 'Waiting for ${DateTime.now().difference(appointment.arrivedAt!.toLocal()).inHours}h',
                                  style: AppTextStyles.caption(context).copyWith(
                                    color: context.warningText,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
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

  String _formatArrivalTime(DateTime? arrivedAt, BuildContext context) {
    if (arrivedAt == null) return '';
    final local = arrivedAt.toLocal();
    final hour = local.hour;
    final minute = local.minute.toString().padLeft(2, '0');
    final isAr = AppStrings.isArabic;
    final period = hour >= 12 ? (isAr ? 'م' : 'PM') : (isAr ? 'ص' : 'AM');
    final h12 = hour % 12 == 0 ? 12 : hour % 12;
    final timeStr = '$h12:$minute $period';
    final dateStr = '${local.day}/${local.month}';
    return isAr ? 'وصل $dateStr $timeStr' : 'Arrived $dateStr $timeStr';
  }

  String _formatDate(String date) {
    final parts = date.split('-');
    if (parts.length == 3) {
      return '${int.tryParse(parts[2]) ?? parts[2]}/${int.tryParse(parts[1]) ?? parts[1]}';
    }
    return date;
  }
}

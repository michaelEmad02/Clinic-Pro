// ────────────────────────────────────────────────────────
// خط زمني أفقي لحالات الموعد — مطابق لتصميم Stitch
// حُجز → وصل → داخل → منتهي
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../domain/entities/appointment_entity.dart';

class AppointmentStatusTimeline extends StatelessWidget {
  final AppointmentEntity appointment;

  const AppointmentStatusTimeline({super.key, required this.appointment});

  static final _steps = [
    ('scheduled', AppStrings.booked, Icons.event_available_outlined),
    ('confirmed', AppStrings.arrived, Icons.how_to_reg_outlined),
    ('in_progress', AppStrings.inside, Icons.login_outlined),
    ('done', AppStrings.completed, Icons.task_alt_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    if (appointment.status == 'cancelled') {
      return _buildCancelledBanner(context);
    }

    final statusOrder = ['scheduled', 'confirmed', 'in_progress', 'done'];
    final currentIndex = statusOrder.indexOf(appointment.status);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMd),
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusCard),
        border: Border.all(color: context.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: List.generate(_steps.length, (index) {
          final step = _steps[index];
          final isCompleted = index <= currentIndex;
          final isActive = index == currentIndex;
          final isLast = index == _steps.length - 1;

          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? context.primary
                              : context.surfaceContainerLow,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isActive
                                ? context.primary
                                : context.borderColor,
                            width: isActive ? 2 : 1,
                          ),
                        ),
                        child: Icon(
                          step.$3,
                          size: 18,
                          color: isCompleted
                              ? context.onPrimary
                              : context.textHint,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        step.$2,
                        style: AppTextStyles.caption(context).copyWith(
                          fontWeight:
                              isActive ? FontWeight.bold : FontWeight.normal,
                          color: isCompleted
                              ? context.textPrimary
                              : context.textHint,
                          fontSize: 11,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _stepTime(step.$1),
                        style: AppTextStyles.dataNumeric(context).copyWith(
                          fontSize: 10,
                          color: isCompleted
                              ? context.textSecondary
                              : context.textHint,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.only(bottom: 28),
                      color: index < currentIndex
                          ? context.primary
                          : context.borderColor,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  String _stepTime(String stepKey) {
    switch (stepKey) {
      case 'scheduled':
        return appointment.displayTime ?? '';
      case 'confirmed':
        return appointment.arrivedAt != null
            ? _formatTime(appointment.arrivedAt!)
            : '--:--';
      case 'in_progress':
        return appointment.calledAt != null
            ? _formatTime(appointment.calledAt!)
            : '--:--';
      case 'done':
        return appointment.status == 'done' ? '✓' : '--:--';
      default:
        return '--:--';
    }
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final period = dt.hour >= 12 ? (AppStrings.isArabic ? 'م' : 'PM') : (AppStrings.isArabic ? 'ص' : 'AM');
    return '$hour:${dt.minute.toString().padLeft(2, '0')} $period';
  }

  Widget _buildCancelledBanner(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMd),
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      decoration: BoxDecoration(
        color: context.dangerBg,
        borderRadius: BorderRadius.circular(AppConstants.radiusCard),
        border: Border.all(color: context.danger.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.cancel_outlined, color: context.danger),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              AppStrings.appointmentCancelled,
              style: AppTextStyles.bodyMedium(context).copyWith(
                color: context.dangerText,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

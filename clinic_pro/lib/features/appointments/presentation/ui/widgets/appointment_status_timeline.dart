// ────────────────────────────────────────────────────────
// خط زمني أفقي لحالات الموعد — مطابق لتصميم Stitch
// حُجز → وصل → داخل → منتهي
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../manager/appointments_state.dart';

class AppointmentStatusTimeline extends StatelessWidget {
  final AppointmentItem appointment;

  const AppointmentStatusTimeline({super.key, required this.appointment});

  static const _steps = [
    ('scheduled', 'حُجز', Icons.event_available_outlined),
    ('confirmed', 'وصل', Icons.how_to_reg_outlined),
    ('in_progress', 'داخل', Icons.login_outlined),
    ('done', 'منتهي', Icons.task_alt_outlined),
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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusCard),
        border: Border.all(color: AppColors.border),
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
                              ? AppColors.primary
                              : AppColors.surfaceContainerLow,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isActive
                                ? AppColors.primary
                                : AppColors.border,
                            width: isActive ? 2 : 1,
                          ),
                        ),
                        child: Icon(
                          step.$3,
                          size: 18,
                          color: isCompleted
                              ? Colors.white
                              : AppColors.textHint,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        step.$2,
                        style: AppTextStyles.caption(context).copyWith(
                          fontWeight:
                              isActive ? FontWeight.bold : FontWeight.normal,
                          color: isCompleted
                              ? AppColors.textPrimary
                              : AppColors.textHint,
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
                              ? AppColors.textSecondary
                              : AppColors.textHint,
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
                          ? AppColors.primary
                          : AppColors.border,
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
        return appointment.displayTime;
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
    final period = dt.hour >= 12 ? 'م' : 'ص';
    return '$hour:${dt.minute.toString().padLeft(2, '0')} $period';
  }

  Widget _buildCancelledBanner(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMd),
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.dangerBg,
        borderRadius: BorderRadius.circular(AppConstants.radiusCard),
        border: Border.all(color: AppColors.danger.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.cancel_outlined, color: AppColors.danger),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'تم إلغاء هذا الموعد',
              style: AppTextStyles.bodyMedium(context).copyWith(
                color: AppColors.dangerText,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

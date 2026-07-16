// ────────────────────────────────────────────────────────
// بطاقة بيانات المريض والتكلفة — مطابق لتصميم Stitch
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../manager/appointments_state.dart';

class AppointmentHeaderCard extends StatelessWidget {
  final AppointmentItem appointment;

  const AppointmentHeaderCard({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    final formattedDate = _formatDate(appointment.date);

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.person_outline,
                  color: AppColors.primaryContainer, size: 20),
              const SizedBox(width: 8),
              Text(
                AppStrings.patient,
                style: AppTextStyles.caption(context).copyWith(
                  color: context.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            appointment.patientName,
            style: AppTextStyles.headlineMedium(context).copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(height: 28),
          _infoRow(
            context,
            Icons.medical_services_outlined,
            AppStrings.doctorRoleLabel,
            appointment.doctorName,
          ),
          const SizedBox(height: 10),
          _infoRow(
            context,
            Icons.calendar_today_outlined,
            AppStrings.date,
            formattedDate,
          ),
          const SizedBox(height: 10),
          _infoRow(
            context,
            Icons.schedule_outlined,
            AppStrings.isArabic ? 'الوقت' : 'Time',
            appointment.displayTime,
          ),
          const SizedBox(height: 10),
          _infoRow(
            context,
            Icons.category_outlined,
            AppStrings.appointmentType,
            appointment.typeName,
          ),
          const Divider(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.cost,
                style: AppTextStyles.bodyMedium(context).copyWith(
                  color: context.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${appointment.price.toStringAsFixed(0)} ${AppStrings.sar}',
                style: AppTextStyles.dataNumeric(context).copyWith(
                  fontSize: 20,
                  color: context.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primaryContainer),
        const SizedBox(width: 8),
        Text(
          '$label ',
          style: AppTextStyles.bodyMedium(context).copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodyMedium(context).copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  String _formatDate(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate);
      return DateFormat('d MMM, yyyy', 'ar').format(dt);
    } catch (_) {
      return isoDate;
    }
  }
}

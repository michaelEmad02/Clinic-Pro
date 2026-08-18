import 'package:flutter/material.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../appointments/domain/entities/appointment_entity.dart';

class CurrentPatientCard extends StatelessWidget {
  final AppointmentEntity? patient;
  final VoidCallback onStartExamination;

  const CurrentPatientCard({
    super.key,
    required this.patient,
    required this.onStartExamination,
  });

  @override
  Widget build(BuildContext context) {
    if (patient == null) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.borderColor),
        ),
        child: Column(
          children: [
             Icon(Icons.person_off_outlined, size: 48, color: context.textHint),
            const SizedBox(height: 12),
            Text(
              AppStrings.isArabic ? 'لا يوجد مريض في غرفة الكشف حالياً' : 'No patient in the exam room',
              style: AppTextStyles.headlineSmall(context).copyWith(
                color: context.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              AppStrings.pressCallNext,
              style: AppTextStyles.caption(context).copyWith(
                color: context.textHint,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.primaryContainer, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: context.primaryContainer.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: context.primaryLightColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                     Icon(Icons.meeting_room_outlined, size: 14, color: context.primary),
                    const SizedBox(width: 4),
                    Text(
                      AppStrings.isArabic ? 'غرفة الكشف الحالية' : 'Current Exam Room',
                      style: AppTextStyles.labelChip(context).copyWith(
                        color: context.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: patient!.isUrgent ? context.dangerBg : context.successBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  patient!.isUrgent ? AppStrings.urgent : AppStrings.normalCheckup,
                  style: AppTextStyles.caption(context).copyWith(
                    color: patient!.isUrgent ? context.dangerText : context.successText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: context.primaryLightColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(Icons.person, color: context.primary, size: 24),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient!.patientName ?? AppStrings.patient,
                      style: AppTextStyles.headlineSmall(context).copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          patient!.patientPhone ?? '',
                          style: AppTextStyles.caption(context).copyWith(
                            color: context.textSecondary,
                            fontFamily: 'Inter',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(width: 1, height: 12, color: context.borderColor),
                        const SizedBox(width: 8),
                        Text(
                          patient!.displayTime ?? '',
                          style: AppTextStyles.caption(context).copyWith(
                            color: context.textSecondary,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.backgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.description_outlined, size: 16, color: context.textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    patient!.notes ?? (AppStrings.isArabic ? 'لا توجد ملاحظات إضافية للموعد' : 'No additional notes'),
                    style: AppTextStyles.bodyMedium(context).copyWith(
                      color: context.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onStartExamination,
            style: ElevatedButton.styleFrom(
              backgroundColor: context.primaryContainer,
              foregroundColor: context.onPrimary,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              minimumSize: const Size(double.infinity, 44),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.edit_note, size: 20),
                const SizedBox(width: 8),
                Text(
                  AppStrings.isArabic ? 'بدء الكشف وكتابة الروشتة' : 'Start Examination & Prescription',
                  style: AppTextStyles.headlineSmall(context).copyWith(
                    color: context.onPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../appointments/presentation/manager/appointments_state.dart';

class CurrentPatientCard extends StatelessWidget {
  final AppointmentItem? patient;
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
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            const Icon(Icons.person_off_outlined, size: 48, color: AppColors.textHint),
            const SizedBox(height: 12),
            Text(
              'لا يوجد مريض في غرفة الكشف حالياً',
              style: AppTextStyles.headlineSmall(context).copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'اضغط على "استدعاء التالي" للبدء',
              style: AppTextStyles.caption(context).copyWith(
                color: AppColors.textHint,
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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryContainer, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryContainer.withOpacity(0.08),
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
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.meeting_room_outlined, size: 14, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      'غرفة الكشف الحالية',
                      style: AppTextStyles.labelChip(context).copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: patient!.isUrgent ? AppColors.dangerBg : AppColors.successBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  patient!.isUrgent ? 'مستعجل' : 'كشف عادي',
                  style: AppTextStyles.caption(context).copyWith(
                    color: patient!.isUrgent ? AppColors.dangerText : AppColors.successText,
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
                decoration: const BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.person, color: AppColors.primary, size: 24),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient!.patientName,
                      style: AppTextStyles.headlineSmall(context).copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          patient!.patientPhone,
                          style: AppTextStyles.caption(context).copyWith(
                            color: AppColors.textSecondary,
                            fontFamily: 'Inter',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(width: 1, height: 12, color: AppColors.border),
                        const SizedBox(width: 8),
                        Text(
                          patient!.displayTime,
                          style: AppTextStyles.caption(context).copyWith(
                            color: AppColors.textSecondary,
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
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.description_outlined, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    patient!.notes ?? 'لا توجد ملاحظات إضافية للموعد',
                    style: AppTextStyles.bodyMedium(context).copyWith(
                      color: AppColors.onSurfaceVariant,
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
              backgroundColor: AppColors.primaryContainer,
              foregroundColor: AppColors.onPrimary,
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
                  'بدء الكشف وكتابة الروشتة',
                  style: AppTextStyles.headlineSmall(context).copyWith(
                    color: AppColors.onPrimary,
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

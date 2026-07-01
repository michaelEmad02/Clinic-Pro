// ────────────────────────────────────────────────────────
// تبويب الروشتات في تفاصيل المريض — مطابق لتصميم Stitch
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/constants/route_constants.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/widgets/empty_state.dart';
import '../../manager/patients_cubit.dart';

class PatientPrescriptionsTab extends StatelessWidget {
  final String patientId;

  const PatientPrescriptionsTab({super.key, required this.patientId});

  @override
  Widget build(BuildContext context) {
    final records = PatientsCubit.getPrescriptionsForPatient(patientId);

    if (records.isEmpty) {
      return const EmptyState(
        title: 'لا توجد روشتات',
        subtitle: 'لم تُصدر أي روشتة لهذا المريض بعد.',
        icon: Icons.medication_outlined,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(AppConstants.spaceMd),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppConstants.radiusCard),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.medication_outlined,
                      color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      record.title,
                      style: AppTextStyles.headlineSmall(context).copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${record.displayDate} • ${record.doctorName}',
                style: AppTextStyles.caption(context).copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      context.push(
                        RouteConstants.prescriptionEdit.replaceAll(
                          ':appointment_id',
                          'appt-1', // استخدام معرف موعد وهمي لتشغيل المحاكاة
                        ),
                      );
                    },
                    icon: const Icon(Icons.visibility_outlined, size: 16),
                    label: const Text('عرض'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.download_outlined, size: 16),
                    label: const Text('تحميل'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

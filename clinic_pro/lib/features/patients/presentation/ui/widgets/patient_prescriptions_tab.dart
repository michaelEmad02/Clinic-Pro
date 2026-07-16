// ────────────────────────────────────────────────────────
// تبويب الروشتات في تفاصيل المريض — مطابق لتصميم Stitch
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/constants/route_constants.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/widgets/empty_state.dart';
import '../../manager/patients_repository.dart';
import '../../manager/patients_state.dart';

class PatientPrescriptionsTab extends StatelessWidget {
  final String patientId;

  const PatientPrescriptionsTab({super.key, required this.patientId});

  @override
  Widget build(BuildContext context) {
    final repo = sl<PatientsRepository>();

    return FutureBuilder<List<PatientPrescriptionRecordItem>>(
      future: repo.getPrescriptionsForPatient(patientId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final records = snapshot.data ?? [];
        if (records.isEmpty) {
          return EmptyState(
            title: AppStrings.isArabic ? 'لا توجد روشتات' : 'No Prescriptions',
            subtitle: AppStrings.isArabic ? 'لم تُصدر أي روشتة لهذا المريض بعد.' : 'No prescriptions have been issued for this patient.',
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
                color: context.surface,
                borderRadius: BorderRadius.circular(AppConstants.radiusCard),
                border: Border.all(color: context.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.medication_outlined,
                          color: context.primary),
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
                      color: context.textSecondary,
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
                              'appt-1',
                            ),
                          );
                        },
                        icon: const Icon(Icons.visibility_outlined, size: 16),
                        label: Text(AppStrings.viewDetails),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: context.primary,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.download_outlined, size: 16),
                        label: Text(AppStrings.isArabic ? 'تحميل' : 'Download'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: context.primary,
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
      },
    );
  }
}

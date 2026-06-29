// ────────────────────────────────────────────────────────
// تبويب المعلومات في تفاصيل المريض — مطابق لتصميم Stitch
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../manager/patients_state.dart';
import 'add_edit_patient_sheet.dart';
import 'patient_allergy_banner.dart';

class PatientInfoTab extends StatelessWidget {
  final PatientItem patient;

  const PatientInfoTab({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      children: [
        PatientAllergyBanner(patient: patient),
        const SizedBox(height: 16),
        _sectionCard(
          context,
          title: 'بيانات التواصل',
          icon: Icons.contact_page_outlined,
          children: [
            if (patient.email != null)
              _infoRow(Icons.mail_outline, 'البريد الإلكتروني',
                  patient.email!, TextDirection.ltr),
            if (patient.address != null)
              _infoRow(Icons.location_on_outlined, 'العنوان السكني',
                  patient.address!),
            if (patient.emergencyContact != null)
              _infoRow(Icons.contact_emergency_outlined, 'جهة اتصال للطوارئ',
                  patient.emergencyContact!),
            _infoRow(Icons.phone_iphone_outlined, 'الهاتف', patient.phone,
                TextDirection.ltr),
            if (patient.birthDate != null)
              _infoRow(Icons.cake_outlined, 'تاريخ الميلاد', patient.birthDate!),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('سيتم تفعيل المراسلة لاحقاً')),
                  );
                },
                icon: const Icon(Icons.chat_outlined, size: 18),
                label: const Text('مراسلة'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  foregroundColor: AppColors.primary,
                  side: BorderSide(color: AppColors.primary.withOpacity(0.2)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () =>
                    AddEditPatientSheet.show(context, patient: patient),
                icon: const Icon(Icons.edit_document, size: 18),
                label: const Text('تعديل الملف'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimaryContainer,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _sectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
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
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTextStyles.headlineSmall(context).copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _infoRow(
    IconData icon,
    String label,
    String value, [
    TextDirection? textDirection,
  ]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primaryContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  textDirection: textDirection,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

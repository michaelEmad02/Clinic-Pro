// ────────────────────────────────────────────────────────
// تبويب المعلومات في تفاصيل المريض — مطابق لتصميم Stitch
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/strings/app_strings.dart';
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
          title: AppStrings.isArabic ? 'بيانات التواصل' : 'Contact Info',
          icon: Icons.contact_page_outlined,
          children: [
            if (patient.email != null)
              _infoRow(context, Icons.mail_outline, AppStrings.email,
                  patient.email!, TextDirection.ltr),
            if (patient.address != null)
              _infoRow(context, Icons.location_on_outlined, AppStrings.isArabic ? 'العنوان السكني' : 'Address',
                  patient.address!),
            if (patient.emergencyContact != null)
              _infoRow(context, Icons.contact_emergency_outlined, AppStrings.isArabic ? 'جهة اتصال للطوارئ' : 'Emergency Contact',
                  patient.emergencyContact!),
            _infoRow(context, Icons.phone_iphone_outlined, AppStrings.isArabic ? 'الهاتف' : 'Phone', patient.phone,
                TextDirection.ltr),
            if (patient.birthDate != null)
              _infoRow(context, Icons.cake_outlined, AppStrings.isArabic ? 'تاريخ الميلاد' : 'Birth Date', patient.birthDate!),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppStrings.isArabic ? 'سيتم تفعيل المراسلة لاحقاً' : 'Messaging will be available soon')),
                  );
                },
                icon: const Icon(Icons.chat_outlined, size: 18),
                label: Text(AppStrings.isArabic ? 'مراسلة' : 'Message'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  foregroundColor: context.primary,
                  side: BorderSide(color: context.primary.withOpacity(0.2)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () =>
                    AddEditPatientSheet.show(context, patient: patient),
                icon: const Icon(Icons.edit_document, size: 18),
                label: Text(AppStrings.isArabic ? 'تعديل الملف' : 'Edit Profile'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.primary,
                  foregroundColor: context.onPrimaryContainer,
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
        color: context.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusCard),
        border: Border.all(color: context.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: context.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTextStyles.headlineSmall(context).copyWith(
                  fontWeight: FontWeight.bold,
                   color: context.primary,
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
    BuildContext context,
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
          Icon(icon, size: 18, color: context.primaryContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    color: context.textSecondary,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: context.textPrimary,
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

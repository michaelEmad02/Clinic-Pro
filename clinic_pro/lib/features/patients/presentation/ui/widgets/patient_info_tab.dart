// ────────────────────────────────────────────────────────
// تبويب المعلومات في تفاصيل المريض — مطابق لتصميم Stitch
// بتصميم متجاوب محدد العرض بدقة (Responsive MaxWidth) لمنع التمدد المفرط
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/utils/responsive_helper.dart';
import 'package:clinic_pro/features/patients/domain/entities/patient_entity.dart';
import 'package:clinic_pro/features/patients/presentation/manager/patient_details_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import 'add_edit_patient_sheet.dart';
import 'patient_allergy_banner.dart';

class PatientInfoTab extends StatelessWidget {
  final PatientEntity patient;

  const PatientInfoTab({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    // تحديد عرض أقصى مريح جداً للعين لمنع تمدد الخانات على الشاشات الكبيرة
    return ResponsiveHelper.responsiveCenter(
      maxWidth: isMobile ? 550 : 680,
      child: ListView(
        padding: const EdgeInsets.all(AppConstants.spaceMd),
        children: [
          PatientAllergyBanner(patient: patient),
          const SizedBox(height: 16),
          _sectionCard(
            context,
            title: AppStrings.isArabic ? 'بيانات التواصل والشخصية' : 'Personal & Contact Info',
            icon: Icons.contact_page_outlined,
            children: [
              if (patient.phone != null && patient.phone!.isNotEmpty)
                _infoRow(context, Icons.phone_iphone_outlined, AppStrings.isArabic ? 'الهاتف' : 'Phone', patient.phone!,
                    TextDirection.ltr),
              if (patient.address != null && patient.address!.isNotEmpty)
                _infoRow(context, Icons.location_on_outlined, AppStrings.isArabic ? 'العنوان السكني' : 'Address',
                    patient.address!),
              if (patient.dateOfBirth != null && patient.dateOfBirth!.isNotEmpty)
                _infoRow(context, Icons.cake_outlined, AppStrings.isArabic ? 'تاريخ الميلاد' : 'Birth Date', patient.dateOfBirth!),
              _infoRow(context, Icons.wc_outlined, AppStrings.isArabic ? 'الجنس' : 'Gender',
                  patient.gender == 'male'
                      ? (AppStrings.isArabic ? 'ذكر' : 'Male')
                      : (AppStrings.isArabic ? 'أنثى' : 'Female')),
              if (patient.bloodType != null)
                _infoRow(context, Icons.bloodtype_outlined, AppStrings.isArabic ? 'فصيلة الدم' : 'Blood Type',
                    patient.bloodType!),
            ],
          ),
          const SizedBox(height: 20),

          // ─── أزرار التحكم الأنيقة بالمحاذاة المتناسبة ───
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppStrings.isArabic ? 'سيتم تفعيل المراسلة لاحقاً' : 'Messaging will be available soon',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.chat_outlined, size: 18),
                label: Text(AppStrings.isArabic ? 'مراسلة' : 'Message'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  foregroundColor: context.primary,
                  side: BorderSide(color: context.primary.withOpacity(0.2)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () async {
                  await AddEditPatientSheet.show(context, patient: patient);
                  if (context.mounted) {
                    context
                        .read<PatientDetailsCubit>()
                        .loadPatientDetails(patient.id);
                  }
                },
                icon: const Icon(Icons.edit_document, size: 18),
                label: Text(AppStrings.isArabic ? 'تعديل الملف' : 'Edit Profile'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.primary,
                  foregroundColor: context.onPrimaryContainer,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusButton),
        border: Border.all(color: context.outline.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Icon(icon, size: 20, color: context.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: AppTextStyles.bodyMedium(context).copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value, [
    TextDirection? valueDirection,
  ]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: context.textSecondary),
          const SizedBox(width: 10),
          Text(
            label,
            style: AppTextStyles.caption(context).copyWith(
              color: context.textSecondary,
            ),
          ),
          const Spacer(),
          Text(
            value,
            textDirection: valueDirection,
            style: AppTextStyles.bodyMedium(context).copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

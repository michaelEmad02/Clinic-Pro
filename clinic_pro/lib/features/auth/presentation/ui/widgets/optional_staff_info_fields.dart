// ────────────────────────────────────────────────────────
// ويدجت إدخال البيانات الشخصية الاختيارية للموظف المدعو
// (OptionalStaffInfoFields)
// يتيح إدخال: رقم الهاتف، العنوان، والتخصص (للأطباء فقط)
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';

class OptionalStaffInfoFields extends StatelessWidget {
  final TextEditingController phoneController;
  final TextEditingController addressController;
  final TextEditingController specialtyController;
  final bool isDoctor;

  const OptionalStaffInfoFields({
    super.key,
    required this.phoneController,
    required this.addressController,
    required this.specialtyController,
    required this.isDoctor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusCard),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.assignment_ind_outlined,
                size: 20,
                color: context.primary,
              ),
              const SizedBox(width: AppConstants.spaceSm),
              Text(
                AppStrings.isArabic
                    ? 'بيانات إضافية (اختياري)'
                    : 'Additional Info (Optional)',
                style: AppTextStyles.bodyMedium(context).copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spaceMd),

          // 1. حقل رقم الهاتف
          _buildInputField(
            context,
            controller: phoneController,
            label: AppStrings.isArabic ? 'رقم الهاتف' : 'Phone Number',
            hint: AppStrings.isArabic
                ? 'أدخل رقم الهاتف (اختياري)'
                : 'Enter phone (optional)',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: AppConstants.spaceSm),

          // 2. حقل العنوان
          _buildInputField(
            context,
            controller: addressController,
            label: AppStrings.isArabic ? 'العنوان' : 'Address',
            hint: AppStrings.isArabic
                ? 'المدينة أو عنوان السكن (اختياري)'
                : 'City or residential address (optional)',
            icon: Icons.location_on_outlined,
            keyboardType: TextInputType.streetAddress,
          ),

          // 3. حقل التخصص (يظهر للأطباء فقط)
          if (isDoctor) ...[
            const SizedBox(height: AppConstants.spaceSm),
            _buildInputField(
              context,
              controller: specialtyController,
              label: AppStrings.isArabic ? 'التخصص الطبي' : 'Medical Specialty',
              hint: AppStrings.isArabic
                  ? 'مثال: باطنة، جراحة عامة، أطفال'
                  : 'e.g. Cardiology, Pediatrics',
              icon: Icons.medical_services_outlined,
              keyboardType: TextInputType.text,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required TextInputType keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: AppTextStyles.bodyMedium(context),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20, color: context.textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusInput),
          borderSide: BorderSide(color: context.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusInput),
          borderSide: BorderSide(color: context.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusInput),
          borderSide: BorderSide(color: context.primary, width: 1.5),
        ),
        filled: true,
        fillColor: context.backgroundColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spaceMd,
          vertical: AppConstants.spaceSm,
        ),
      ),
    );
  }
}

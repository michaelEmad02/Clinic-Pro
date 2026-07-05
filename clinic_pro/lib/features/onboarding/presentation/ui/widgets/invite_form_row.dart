import 'package:flutter/material.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/constants/staff_roles.dart';

/// ويدجت نموذج إدخال بيانات الموظف (الاسم، البريد، الصلاحية، العيادة، والطبيب الاختياري)
class InviteFormRow extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final StaffRoles selectedRole;
  final ValueChanged<StaffRoles?> onRoleChanged;
  
  final List<Map<String, dynamic>> clinics;
  final String? selectedClinicId;
  final ValueChanged<String?> onClinicChanged;
  
  final List<Map<String, dynamic>> doctors;
  final String? selectedDoctorId;
  final ValueChanged<String?> onDoctorChanged;

  final VoidCallback onAdd;

  const InviteFormRow({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.selectedRole,
    required this.onRoleChanged,
    required this.clinics,
    required this.selectedClinicId,
    required this.onClinicChanged,
    required this.doctors,
    required this.selectedDoctorId,
    required this.onDoctorChanged,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    // تصفية الصلاحيات لعرض طبيب وسكرتير فقط
    final allowedRoles = StaffRoles.values
        .where((r) => r == StaffRoles.doctor || r == StaffRoles.secretary)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // اختيار العيادة
        if (clinics.isNotEmpty) ...[
          _buildDropdownField<String>(
            context: context,
            label: 'العيادة المرتبطة',
            value: selectedClinicId,
            items: clinics.map((c) {
              return DropdownMenuItem<String>(
                value: c['id'] as String,
                child: Text(c['name'] as String? ?? ''),
              );
            }).toList(),
            onChanged: onClinicChanged,
          ),
          const SizedBox(height: AppConstants.spaceSm),
        ],

        // حقل الاسم الكامل
        _buildTextField(
          context: context,
          label: 'الاسم الكامل للموظف',
          hint: 'مثال: أحمد محمد عبدالمجيد',
          controller: nameController,
          keyboardType: TextInputType.name,
        ),
        const SizedBox(height: AppConstants.spaceSm),

        // حقل البريد الإلكتروني
        _buildTextField(
          context: context,
          label: 'البريد الإلكتروني',
          hint: 'email@clinic.com',
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          isLtr: true,
        ),
        const SizedBox(height: AppConstants.spaceSm),

        // الصلاحية (الدور)
        _buildDropdownField<StaffRoles>(
          context: context,
          label: 'الصلاحية (الدور)',
          value: selectedRole,
          items: allowedRoles.map((role) {
            return DropdownMenuItem<StaffRoles>(
              value: role,
              child: Text(role.label),
            );
          }).toList(),
          onChanged: onRoleChanged,
        ),
        const SizedBox(height: AppConstants.spaceSm),

        // حقل اختيار الطبيب (يظهر فقط إذا كان الدور سكرتير)
        if (selectedRole == StaffRoles.secretary && doctors.isNotEmpty) ...[
          _buildDropdownField<String>(
            context: context,
            label: 'الطبيب المسؤول عنه (اختياري)',
            value: selectedDoctorId,
            items: doctors.map((d) {
              return DropdownMenuItem<String>(
                value: d['id'] as String,
                child: Text(d['name'] as String? ?? ''),
              );
            }).toList(),
            onChanged: onDoctorChanged,
          ),
          const SizedBox(height: AppConstants.spaceSm),
        ],

        const SizedBox(height: AppConstants.spaceMd),

        // زر الإضافة إلى قائمة المدعوين
        ElevatedButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add, size: 20),
          label: Text(
            'إضافة إلى قائمة المدعوين',
            style: AppTextStyles.bodyMedium(context).copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryLight,
            foregroundColor: AppColors.primary,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusButton),
              side: const BorderSide(color: AppColors.primary, width: 1),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType? keyboardType,
    bool isLtr = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption(context).copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppConstants.spaceXs),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppConstants.radiusInput),
            border: Border.all(color: AppColors.border),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            textDirection: isLtr ? TextDirection.ltr : null,
            textAlign: isLtr ? TextAlign.left : TextAlign.right,
            style: TextStyle(
              fontFamily: isLtr ? 'Inter' : 'Cairo',
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                fontFamily: isLtr ? 'Inter' : 'Cairo',
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: AppColors.textHint,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField<T>({
    required BuildContext context,
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption(context).copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppConstants.spaceXs),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppConstants.radiusInput),
            border: Border.all(color: AppColors.border),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.expand_more,
                  color: AppColors.textSecondary, size: 20),
              style: AppTextStyles.bodyMedium(context).copyWith(
                color: AppColors.textPrimary,
              ),
              items: items,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

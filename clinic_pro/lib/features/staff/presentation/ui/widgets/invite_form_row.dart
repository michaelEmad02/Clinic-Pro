import 'package:flutter/material.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/constants/staff_roles.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../clinics/domain/entities/clinic_entity.dart';
import '../../../domain/entities/staff_entity.dart';

class InviteFormRow extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final StaffRoles selectedRole;
  final ValueChanged<StaffRoles?> onRoleChanged;

  final List<ClinicEntity> clinics;
  final String? selectedClinicId;
  final ValueChanged<String?> onClinicChanged;

  final List<StaffEntity> doctors;
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
    final allowedRoles = StaffRoles.values
        .where((r) => r == StaffRoles.doctor || r == StaffRoles.secretary)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (clinics.isNotEmpty) ...[
          _buildDropdownField<String>(
            context: context,
            label: AppStrings.associatedClinic,
            value: selectedClinicId,
            items: clinics.map((c) {
              return DropdownMenuItem<String>(
                value: c.id,
                child: Text(c.name),
              );
            }).toList(),
            onChanged: onClinicChanged,
          ),
          const SizedBox(height: AppConstants.spaceSm),
        ],

        _buildTextField(
          context: context,
          label: AppStrings.employeeFullName,
          hint: 'مثال: أحمد محمد عبدالمجيد',
          controller: nameController,
          keyboardType: TextInputType.name,
        ),
        const SizedBox(height: AppConstants.spaceSm),

        _buildTextField(
          context: context,
          label: AppStrings.email,
          hint: 'email@clinic.com',
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          isLtr: true,
        ),
        const SizedBox(height: AppConstants.spaceSm),

        _buildDropdownField<StaffRoles>(
          context: context,
          label: AppStrings.rolePermission,
          value: selectedRole,
          items: allowedRoles.map((role) {
            return DropdownMenuItem<StaffRoles>(
              value: role,
              child: Text(role.label),
            );
          }).toList(),
          onChanged: onRoleChanged,
        ),

        if (selectedRole == StaffRoles.secretary && doctors.isNotEmpty) ...[
          const SizedBox(height: AppConstants.spaceSm),
          _buildDropdownField<String>(
            context: context,
            label: AppStrings.isArabic ? 'الطبيب المسؤول' : 'Responsible Doctor',
            value: selectedDoctorId,
            items: doctors.map((doc) {
              return DropdownMenuItem<String>(
                value: doc.id,
                child: Text(doc.name),
              );
            }).toList(),
            onChanged: onDoctorChanged,
          ),
        ],
        const SizedBox(height: AppConstants.spaceLg),

        ElevatedButton.icon(
          onPressed: onAdd,
          style: ElevatedButton.styleFrom(
            backgroundColor: context.primaryLightColor,
            foregroundColor: context.primary,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusButton),
              side: BorderSide(color: context.primary.withOpacity(0.2)),
            ),
            elevation: 0,
          ),
          icon: const Icon(Icons.add, size: 20),
          label: Text(
            AppStrings.isArabic ? 'إضافة موظف' : 'Add Employee',
            style: AppTextStyles.bodyMedium(context).copyWith(
              fontWeight: FontWeight.bold,
              color: context.primary,
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
    TextInputType keyboardType = TextInputType.text,
    bool isLtr = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6, right: 4, left: 4),
          child: Text(
            label,
            style: AppTextStyles.caption(context).copyWith(
              color: context.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          textDirection: isLtr ? TextDirection.ltr : null,
          style: AppTextStyles.bodyMedium(context).copyWith(
            color: context.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.caption(context).copyWith(
              color: context.textHint,
            ),
            filled: true,
            fillColor: context.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusInput),
              borderSide: BorderSide(color: context.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusInput),
              borderSide: BorderSide(color: context.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusInput),
              borderSide: BorderSide(color: context.primary, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spaceMd,
              vertical: 12,
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
        Padding(
          padding: const EdgeInsets.only(bottom: 6, right: 4, left: 4),
          child: Text(
            label,
            style: AppTextStyles.caption(context).copyWith(
              color: context.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        DropdownButtonFormField<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          style: AppTextStyles.bodyMedium(context).copyWith(
            color: context.textPrimary,
          ),
          icon: Icon(Icons.arrow_drop_down, color: context.textSecondary),
          decoration: InputDecoration(
            filled: true,
            fillColor: context.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusInput),
              borderSide: BorderSide(color: context.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusInput),
              borderSide: BorderSide(color: context.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusInput),
              borderSide: BorderSide(color: context.primary, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spaceMd,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}

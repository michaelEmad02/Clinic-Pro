import 'package:flutter/material.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/constants/staff_roles.dart';

/// ويدجت صف إدخال البريد الإلكتروني واختيار الصلاحية وزر الإضافة
/// يستخدم في شاشة دعوة الموظفين
class InviteFormRow extends StatelessWidget {
  final TextEditingController emailController;
  final StaffRoles selectedRole;
  final ValueChanged<StaffRoles?> onRoleChanged;
  final VoidCallback onAdd;

  const InviteFormRow({
    super.key,
    required this.emailController,
    required this.selectedRole,
    required this.onRoleChanged,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // حقل البريد الإلكتروني
        _buildEmailField(context),
        const SizedBox(height: AppConstants.spaceSm),

        // صف الصلاحية + زر الإضافة
        Row(
          children: [
            // قائمة اختيار الصلاحية
            Expanded(child: _buildRoleDropdown(context)),
            const SizedBox(width: AppConstants.spaceSm),

            // زر الإضافة
            _buildAddButton(),
          ],
        ),
      ],
    );
  }

  /// بناء حقل إدخال البريد الإلكتروني
  Widget _buildEmailField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'البريد الإلكتروني',
          style: AppTextStyles.caption(context).copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppConstants.spaceXs),
        Container(
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppConstants.radiusInput),
            border: Border.all(color: AppColors.border),
          ),
          child: TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.left,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
            decoration: const InputDecoration(
              hintText: 'email@clinic.com',
              hintStyle: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: AppColors.textHint,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 12),
            ),
          ),
        ),
      ],
    );
  }

  /// بناء قائمة اختيار الصلاحية (Dropdown)
  Widget _buildRoleDropdown(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الصلاحية',
          style: AppTextStyles.caption(context).copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppConstants.spaceXs),
        Container(
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppConstants.radiusInput),
            border: Border.all(color: AppColors.border),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<StaffRoles>(
              value: selectedRole,
              isExpanded: true,
              icon: const Icon(Icons.expand_more,
                  color: AppColors.textSecondary, size: 20),
              style: AppTextStyles.bodyMedium(context).copyWith(
                color: AppColors.textPrimary,
              ),
              items: StaffRoles.values.map((role) {
                return DropdownMenuItem<StaffRoles>(
                  value: role,
                  child: Text(role.label),
                );
              }).toList(),
              onChanged: onRoleChanged,
            ),
          ),
        ),
      ],
    );
  }

  /// بناء زر الإضافة (+)
  Widget _buildAddButton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // فراغ لمحاذاة الزر مع الحقول (بسبب وجود label فوقها)
        const SizedBox(height: 20),
        Material(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(AppConstants.radiusInput),
          child: InkWell(
            onTap: onAdd,
            borderRadius: BorderRadius.circular(AppConstants.radiusInput),
            child: const SizedBox(
              width: 44,
              height: 44,
              child: Icon(
                Icons.add,
                color: AppColors.primary,
                size: 24,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

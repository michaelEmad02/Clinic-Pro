// ────────────────────────────────────────────────────────
// Bottom Sheet دعوة موظف جديد — البريد الإلكتروني + الاسم + الدور
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/widgets/app_bottom_sheet.dart';
import '../../manager/staff_cubit.dart';

class InviteStaffSheet {
  static Future<void> show(BuildContext context) {
    return AppBottomSheet.show(
      context: context,
      child: const _InviteStaffForm(),
    );
  }
}

class _InviteStaffForm extends StatefulWidget {
  const _InviteStaffForm();

  @override
  State<_InviteStaffForm> createState() => _InviteStaffFormState();
}

class _InviteStaffFormState extends State<_InviteStaffForm> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  String _role = 'doctor';

  static const _roles = [
    ('doctor', 'طبيب'),
    ('nurse', 'تمريض'),
    ('secretary', 'سكرتير'),
    ('accountant', 'محاسب'),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى ملء جميع الحقول المطلوبة')),
      );
      return;
    }

    context.read<StaffCubit>().inviteStaff(
          email: _emailController.text.trim(),
          name: _nameController.text.trim(),
          role: _role,
        );

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('تم إرسال دعوة إلى ${_emailController.text.trim()}'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'دعوة موظف جديد',
                  style: AppTextStyles.headlineSmall(context).copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close,
                    color: AppColors.textSecondary),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildField(
            label: 'الاسم الكامل *',
            icon: Icons.person_outline,
            controller: _nameController,
          ),
          const SizedBox(height: 12),
          _buildField(
            label: 'البريد الإلكتروني *',
            icon: Icons.email_outlined,
            controller: _emailController,
            textDirection: TextDirection.ltr,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'الدور *',
              prefixIcon: const Icon(Icons.badge_outlined),
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(AppConstants.radiusInput),
              ),
            ),
            value: _role,
            items: _roles
                .map((r) => DropdownMenuItem(
                    value: r.$1, child: Text(r.$2)))
                .toList(),
            onChanged: (v) => setState(() => _role = v!),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _submit,
            icon: const Icon(Icons.send_outlined),
            label: const Text('إرسال الدعوة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimaryContainer,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppConstants.radiusButton),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    TextDirection? textDirection,
  }) {
    return TextField(
      controller: controller,
      textDirection: textDirection,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(AppConstants.radiusInput),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spaceMd,
          vertical: 13,
        ),
      ),
    );
  }
}

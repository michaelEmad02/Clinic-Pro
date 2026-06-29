// ────────────────────────────────────────────────────────
// Bottom Sheet إضافة/تعديل عيادة
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/widgets/app_bottom_sheet.dart';
import '../../manager/clinics_cubit.dart';
import '../../manager/clinics_state.dart';

class AddEditClinicSheet {
  static Future<void> show(
    BuildContext context, {
    ClinicItem? clinic,
  }) {
    return AppBottomSheet.show(
      context: context,
      child: _AddEditClinicForm(clinic: clinic),
    );
  }
}

class _AddEditClinicForm extends StatefulWidget {
  final ClinicItem? clinic;

  const _AddEditClinicForm({this.clinic});

  @override
  State<_AddEditClinicForm> createState() => _AddEditClinicFormState();
}

class _AddEditClinicFormState extends State<_AddEditClinicForm> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isEdit = false;

  @override
  void initState() {
    super.initState();
    _isEdit = widget.clinic != null;
    if (_isEdit) {
      final c = widget.clinic!;
      _nameController.text = c.name;
      _phoneController.text = c.phone;
      _addressController.text = c.address;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال اسم العيادة')),
      );
      return;
    }

    final cubit = context.read<ClinicsCubit>();

    if (_isEdit) {
      cubit.updateClinic(widget.clinic!.copyWith(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
      ));
    } else {
      cubit.addClinic(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
      );
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            _isEdit ? 'تم تحديث بيانات العيادة' : 'تم إضافة العيادة'),
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
                  _isEdit ? 'تعديل بيانات العيادة' : 'إضافة عيادة جديدة',
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
            label: 'اسم العيادة *',
            icon: Icons.local_hospital_outlined,
            controller: _nameController,
          ),
          const SizedBox(height: 12),
          _buildField(
            label: 'رقم الهاتف',
            icon: Icons.call_outlined,
            controller: _phoneController,
            textDirection: TextDirection.ltr,
          ),
          const SizedBox(height: 12),
          _buildField(
            label: 'العنوان',
            icon: Icons.location_on_outlined,
            controller: _addressController,
            maxLines: 2,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _submit,
            icon: const Icon(Icons.save_outlined),
            label: const Text('حفظ'),
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
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
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

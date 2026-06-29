// ────────────────────────────────────────────────────────
// Bottom Sheet إضافة/تعديل مريض — مطابق لتصميم Stitch
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/widgets/app_bottom_sheet.dart';
import '../../manager/patients_cubit.dart';
import '../../manager/patients_state.dart';

class AddEditPatientSheet {
  static Future<void> show(
    BuildContext context, {
    PatientItem? patient,
  }) {
    return AppBottomSheet.show(
      context: context,
      child: _AddEditPatientForm(patient: patient),
    );
  }
}

class _AddEditPatientForm extends StatefulWidget {
  final PatientItem? patient;

  const _AddEditPatientForm({this.patient});

  @override
  State<_AddEditPatientForm> createState() => _AddEditPatientFormState();
}

class _AddEditPatientFormState extends State<_AddEditPatientForm> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _chronicController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _addressController = TextEditingController();
  String? _gender;
  String? _bloodType;
  DateTime? _birthDate;
  bool _isEdit = false;

  static const _bloodTypes = [
    'A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-',
  ];

  @override
  void initState() {
    super.initState();
    _isEdit = widget.patient != null;
    if (_isEdit) {
      final p = widget.patient!;
      _nameController.text = p.name;
      _phoneController.text = p.phone;
      _gender = p.gender;
      _bloodType = p.bloodType;
      _chronicController.text =
          p.chronicConditions == 'لا يوجد' ? '' : p.chronicConditions;
      _allergiesController.text =
          p.allergies == 'لا يوجد' ? '' : p.allergies;
      _addressController.text = p.address ?? '';
      if (p.birthDate != null) {
        _birthDate = DateTime.tryParse(p.birthDate!);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _chronicController.dispose();
    _allergiesController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      locale: const Locale('ar'),
      initialDate: _birthDate ?? DateTime(1990),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  void _submit() {
    if (_nameController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _gender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى ملء الحقول المطلوبة')),
      );
      return;
    }

    final cubit = context.read<PatientsCubit>();
    final birthStr = _birthDate?.toIso8601String().substring(0, 10);

    if (_isEdit) {
      cubit.updatePatient(widget.patient!.copyWith(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        gender: _gender!,
        birthDate: birthStr,
        bloodType: _bloodType,
        chronicConditions: _chronicController.text.isEmpty
            ? 'لا يوجد'
            : _chronicController.text.trim(),
        allergies: _allergiesController.text.isEmpty
            ? 'لا يوجد'
            : _allergiesController.text.trim(),
        address: _addressController.text.isEmpty
            ? null
            : _addressController.text.trim(),
        isChronic: _chronicController.text.isNotEmpty,
      ));
    } else {
      cubit.addPatient(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        gender: _gender!,
        birthDate: birthStr,
        bloodType: _bloodType,
        chronicConditions: _chronicController.text.isEmpty
            ? null
            : _chronicController.text.trim(),
        allergies: _allergiesController.text.isEmpty
            ? null
            : _allergiesController.text.trim(),
        address: _addressController.text.isEmpty
            ? null
            : _addressController.text.trim(),
      );
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isEdit ? 'تم تحديث بيانات المريض' : 'تم إضافة المريض'),
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
                  _isEdit ? 'تعديل بيانات المريض' : 'إضافة مريض جديد',
                  style: AppTextStyles.headlineSmall(context).copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.textSecondary),
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
            label: 'رقم الهاتف *',
            icon: Icons.call_outlined,
            controller: _phoneController,
            textDirection: TextDirection.ltr,
          ),
          const SizedBox(height: 12),
          Text(
            'تاريخ الميلاد',
            style: AppTextStyles.caption(context).copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _pickBirthDate,
            icon: const Icon(Icons.calendar_month_outlined, size: 18),
            label: Text(
              _birthDate != null
                  ? '${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}'
                  : 'اختر التاريخ',
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 13),
              side: BorderSide(color: AppColors.primary.withOpacity(0.2)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusButton),
              ),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'الجنس *',
              prefixIcon: const Icon(Icons.wc_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusInput),
              ),
            ),
            value: _gender,
            items: const [
              DropdownMenuItem(value: 'male', child: Text('ذكر')),
              DropdownMenuItem(value: 'female', child: Text('أنثى')),
            ],
            onChanged: (v) => setState(() => _gender = v),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'فصيلة الدم',
              prefixIcon: const Icon(Icons.bloodtype_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusInput),
              ),
            ),
            value: _bloodType,
            items: _bloodTypes
                .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                .toList(),
            onChanged: (v) => setState(() => _bloodType = v),
          ),
          const SizedBox(height: 12),
          _buildField(
            label: 'الأمراض المزمنة',
            icon: Icons.medical_information_outlined,
            controller: _chronicController,
            maxLines: 2,
          ),
          const SizedBox(height: 12),
          _buildField(
            label: 'حساسية الأدوية',
            icon: Icons.medication_liquid_outlined,
            controller: _allergiesController,
            maxLines: 2,
          ),
          const SizedBox(height: 12),
          _buildField(
            label: 'العنوان',
            icon: Icons.location_on_outlined,
            controller: _addressController,
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
                borderRadius: BorderRadius.circular(AppConstants.radiusButton),
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
          borderRadius: BorderRadius.circular(AppConstants.radiusInput),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spaceMd,
          vertical: 13,
        ),
      ),
    );
  }
}

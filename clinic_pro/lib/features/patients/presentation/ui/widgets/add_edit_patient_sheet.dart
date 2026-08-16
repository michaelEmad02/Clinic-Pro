// ────────────────────────────────────────────────────────
// Bottom Sheet إضافة/تعديل مريض — مطابق لتصميم Stitch وتوثيق UI
// يستخدم PatientEntity من طبقة الدومين
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/constants/supabase_constants.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/utils/responsive_helper.dart';
import '../../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../settings/presentation/manager/settings_cubit.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../domain/entities/patient_entity.dart';
import '../../manager/patients_cubit.dart';
import 'patient_form_fields.dart';

class AddEditPatientSheet {
  static Future<void> show(
    BuildContext context, {
    PatientEntity? patient,
  }) {
    PatientsCubit cubit;
    try {
      cubit = context.read<PatientsCubit>();
    } catch (_) {
      cubit = sl<PatientsCubit>();
    }

    return AppBottomSheet.show(
      context: context,
      child: BlocProvider.value(
        value: cubit,
        child: ResponsiveHelper.responsiveCenter(
          maxWidth: 560,
          child: _AddEditPatientForm(patient: patient),
        ),
      ),
    );
  }
}

class _AddEditPatientForm extends StatefulWidget {
  final PatientEntity? patient;

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

  String _gender = Gender.male;
  String? _bloodType;
  DateTime? _birthDate;
  bool _isEdit = false;

  @override
  void initState() {
    super.initState();
    _isEdit = widget.patient != null;
    if (_isEdit) {
      final p = widget.patient!;
      _nameController.text = p.name;
      _phoneController.text = p.phone ?? '';
      _gender = p.gender.isNotEmpty ? p.gender : Gender.male;
      _bloodType =
          (p.bloodType != null && BloodType.values.contains(p.bloodType))
              ? p.bloodType
              : null;
      _chronicController.text = p.chronicConditions ?? '';
      _allergiesController.text = p.allergies ?? '';
      _addressController.text = p.address ?? '';
      if (p.dateOfBirth != null && p.dateOfBirth!.isNotEmpty) {
        _birthDate = DateTime.tryParse(p.dateOfBirth!);
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
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppStrings.isArabic
                ? 'يرجى إدخال اسم المريض'
                : 'Please enter patient name',
          ),
        ),
      );
      return;
    }

    final cubit = context.read<PatientsCubit>();
    final birthStr = _birthDate?.toIso8601String().substring(0, 10);
    final activeClinicId =
        context.read<SettingsCubit>().state.clinicEntity?.id ?? '';

    if (_isEdit) {
      cubit.updatePatient(widget.patient!.copyWith(
        name: _nameController.text.trim(),
        phone: () => _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        gender: _gender,
        dateOfBirth: () => birthStr,
        bloodType: () => _bloodType,
        chronicConditions: () => _chronicController.text.trim().isEmpty
            ? null
            : _chronicController.text.trim(),
        allergies: () => _allergiesController.text.trim().isEmpty
            ? null
            : _allergiesController.text.trim(),
        address: () => _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
      ));
    } else {
      cubit.addPatient(PatientEntity(
        id: '',
        clinicId: activeClinicId,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        gender: _gender,
        dateOfBirth: birthStr,
        bloodType: _bloodType,
        chronicConditions: _chronicController.text.trim().isEmpty
            ? null
            : _chronicController.text.trim(),
        allergies: _allergiesController.text.trim().isEmpty
            ? null
            : _allergiesController.text.trim(),
        address: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
      ));
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppStrings.operationSuccessful)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(16, 0, 16, 24 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _isEdit ? AppStrings.editPatient : AppStrings.addPatient,
                    style: AppTextStyles.headlineSmall(context).copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.primary,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: context.textSecondary),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // اسم المريض
            PatientInputField(
              label: AppStrings.patientName,
              icon: Icons.person_outline,
              controller: _nameController,
            ),
            const SizedBox(height: 12),

            // رقم الهاتف
            PatientInputField(
              label: AppStrings.phoneNumber,
              icon: Icons.call_outlined,
              controller: _phoneController,
              textDirection: TextDirection.ltr,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),

            // اختيار الجنس (ChoiceChips: ذكر / أنثى)
            Text(
              AppStrings.patientGender,
              style: AppTextStyles.caption(context).copyWith(
                color: context.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: GenderChip(
                    label: AppStrings.male,
                    icon: Icons.male,
                    isSelected: _gender == Gender.male,
                    onTap: () => setState(() => _gender = Gender.male),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GenderChip(
                    label: AppStrings.female,
                    icon: Icons.female,
                    isSelected: _gender == Gender.female,
                    onTap: () => setState(() => _gender = Gender.female),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // تاريخ الميلاد
            Text(
              AppStrings.isArabic ? 'تاريخ الميلاد' : 'Birth Date',
              style: AppTextStyles.caption(context).copyWith(
                color: context.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            OutlinedButton.icon(
              onPressed: _pickBirthDate,
              icon: const Icon(Icons.calendar_month_outlined, size: 18),
              label: Text(
                _birthDate != null
                    ? '${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}'
                    : AppStrings.isArabic
                        ? 'اختر التاريخ'
                        : 'Select Date',
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 13),
                side: BorderSide(color: context.primary.withOpacity(0.2)),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusButton),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // فصيلة الدم
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: AppStrings.isArabic ? 'فصيلة الدم' : 'Blood Type',
                prefixIcon: const Icon(Icons.bloodtype_outlined),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusInput),
                  borderSide: BorderSide(color: context.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusInput),
                  borderSide: BorderSide(color: context.primary, width: 1.5),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusInput),
                ),
              ),
              value: _bloodType,
              items: BloodType.values
                  .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                  .toList(),
              onChanged: (v) => setState(() => _bloodType = v),
            ),
            const SizedBox(height: 12),

            // الأمراض المزمنة
            PatientInputField(
              label: AppStrings.medicalHistory,
              icon: Icons.medical_information_outlined,
              controller: _chronicController,
              maxLines: 2,
            ),
            const SizedBox(height: 12),

            // الحساسية
            PatientInputField(
              label: AppStrings.allergies,
              icon: Icons.medication_liquid_outlined,
              controller: _allergiesController,
              maxLines: 2,
            ),
            const SizedBox(height: 12),

            // العنوان
            PatientInputField(
              label: AppStrings.isArabic ? 'العنوان' : 'Address',
              icon: Icons.location_on_outlined,
              controller: _addressController,
            ),
            const SizedBox(height: 24),

            // زر الحفظ
            ElevatedButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.save_outlined),
              label: Text(AppStrings.save),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.primary,
                foregroundColor: context.onPrimaryContainer,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusButton),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

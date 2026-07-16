// ────────────────────────────────────────────────────────
// Bottom Sheet إضافة/تعديل مريض — مطابق لتصميم Stitch
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../../core/constants/staff_roles.dart';
import '../../../../auth/presentation/manager/auth_cubit.dart';
import '../../../../auth/presentation/manager/auth_state.dart';
import '../../manager/patients_cubit.dart';
import '../../manager/patients_state.dart';

class AddEditPatientSheet {
  static Future<void> show(
    BuildContext context, {
    PatientItem? patient,
  }) {
    final cubit = context.read<PatientsCubit>();
    return AppBottomSheet.show(
      context: context,
      child: BlocProvider.value(
        value: cubit,
        child: _AddEditPatientForm(patient: patient),
      ),
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
  String? _selectedDoctorId;
  bool _isEdit = false;

  static const _bloodTypes = [
    'A+',
    'A-',
    'B+',
    'B-',
    'O+',
    'O-',
    'AB+',
    'AB-',
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
      _selectedDoctorId = p.doctorId;
      _chronicController.text =
          p.chronicConditions == AppStrings.none ? '' : p.chronicConditions;
      _allergiesController.text =
          p.allergies == AppStrings.none ? '' : p.allergies;
      _addressController.text = p.address ?? '';
      if (p.birthDate != null) {
        _birthDate = DateTime.tryParse(p.birthDate!);
      }
    } else {
      final authState = context.read<AuthCubit>().state;
      if (authState is AuthAuthenticated) {
        final user = authState.user;
        if (user.role == StaffRoles.doctor) {
          _selectedDoctorId = user.id;
        }
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
        SnackBar(content: Text(AppStrings.isArabic ? 'يرجى ملء الحقول المطلوبة' : 'Please fill in the required fields')),
      );
      return;
    }

    final cubit = context.read<PatientsCubit>();
    final birthStr = _birthDate?.toIso8601String().substring(0, 10);

    if (_isEdit) {
      cubit.updatePatient(widget.patient!.copyWith(
        doctorId: _selectedDoctorId,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        gender: _gender!,
        birthDate: birthStr,
        bloodType: _bloodType,
        chronicConditions: _chronicController.text.isEmpty
            ? AppStrings.none
            : _chronicController.text.trim(),
        allergies: _allergiesController.text.isEmpty
            ? AppStrings.none
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
        doctorId: _selectedDoctorId,
      );
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppStrings.operationSuccessful),
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
          _buildField(
            label: AppStrings.patientName,
            icon: Icons.person_outline,
            controller: _nameController,
          ),
          const SizedBox(height: 12),
          _buildField(
            label: AppStrings.phoneNumber,
            icon: Icons.call_outlined,
            controller: _phoneController,
            textDirection: TextDirection.ltr,
          ),
          const SizedBox(height: 12),
          Text(
            AppStrings.isArabic ? 'تاريخ الميلاد' : 'Birth Date',
            style: AppTextStyles.caption(context).copyWith(
              color: context.textSecondary,
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
                  : AppStrings.isArabic ? 'اختر التاريخ' : 'Select Date',
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 13),
              side: BorderSide(color: context.primary.withOpacity(0.2)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusButton),
              ),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: AppStrings.patientGender,
              prefixIcon: const Icon(Icons.wc_outlined),
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
            value: _gender,
            items: [
              DropdownMenuItem(value: 'male', child: Text(AppStrings.male)),
              DropdownMenuItem(value: 'female', child: Text(AppStrings.female)),
            ],
            onChanged: (v) => setState(() => _gender = v),
          ),
          ..._buildDoctorSelector(),
          const SizedBox(height: 12),
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
            items: _bloodTypes
                .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                .toList(),
            onChanged: (v) => setState(() => _bloodType = v),
          ),
          const SizedBox(height: 12),
          _buildField(
            label: AppStrings.medicalHistory,
            icon: Icons.medical_information_outlined,
            controller: _chronicController,
            maxLines: 2,
          ),
          const SizedBox(height: 12),
          _buildField(
            label: AppStrings.allergies,
            icon: Icons.medication_liquid_outlined,
            controller: _allergiesController,
            maxLines: 2,
          ),
          const SizedBox(height: 12),
          _buildField(
            label: AppStrings.isArabic ? 'العنوان' : 'Address',
            icon: Icons.location_on_outlined,
            controller: _addressController,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _submit,
            icon: const Icon(Icons.save_outlined),
            label: Text(AppStrings.save),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.primary,
              foregroundColor: context.onPrimaryContainer,
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spaceMd,
          vertical: 13,
        ),
      ),
    );
  }

  List<Widget> _buildDoctorSelector() {
    final authState = context.read<AuthCubit>().state;
    final patientsState = context.read<PatientsCubit>().state;

    bool isDoctor = false;
    if (authState is AuthAuthenticated) {
      isDoctor = authState.user.role == StaffRoles.doctor;
    }

    if (isDoctor) return [];

    List<Map<String, dynamic>> doctors = [];
    if (patientsState is PatientsLoaded) {
      doctors = patientsState.doctors;
    }

    if (doctors.isEmpty) return [];

    return [
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: AppStrings.isArabic ? 'الطبيب المعالج' : 'Treating Doctor',
          prefixIcon: const Icon(Icons.person_outline),
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
        value: _selectedDoctorId,
        items: doctors.map((doc) {
          return DropdownMenuItem<String>(
            value: doc['id'] as String,
            child: Text(doc['name'] as String),
          );
        }).toList(),
        onChanged: (v) => setState(() => _selectedDoctorId = v),
      ),
    ];
  }
}

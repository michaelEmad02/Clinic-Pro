import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../domain/entities/clinic_entity.dart';

class ClinicForm extends StatefulWidget {
  final void Function({
    required String name,
    required String phone,
    required String address,
    String? logoUrl,
  }) onSubmit;
  final VoidCallback onBack;
  final ClinicEntity? clinic;
  final bool isOnboarding;

  const ClinicForm({
    super.key,
    required this.onSubmit,
    required this.onBack,
    this.clinic,
    this.isOnboarding = true,
  });

  @override
  State<ClinicForm> createState() => _ClinicFormState();
}

class _ClinicFormState extends State<ClinicForm> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _selectedSpecialty;
  bool _isDoctor = true;

  /// الصورة المختارة من المعرض
  File? _selectedImage;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.clinic != null) {
      _nameController.text = widget.clinic!.name;
      _addressController.text = widget.clinic!.address;
      _phoneController.text = widget.clinic!.phone1;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() {
    widget.onSubmit(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
    );
  }

  /// فتح المعرض لاختيار صورة شعار العيادة
  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      // التعامل مع خطأ اختيار الصورة
      debugPrint('خطأ في اختيار الصورة: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Logo Upload
        Center(
          child: Column(
            children: [
              InkWell(
                onTap: _pickImage,
                borderRadius: BorderRadius.circular(48),
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: context.surfaceContainerLow,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _selectedImage != null
                          ? context.primary
                          : context.outline,
                    ),
                  ),
                  child: _selectedImage != null
                      // عرض الصورة المختارة داخل دائرة
                      ? ClipOval(
                          child: Image.file(
                            _selectedImage!,
                            width: 96,
                            height: 96,
                            fit: BoxFit.cover,
                          ),
                        )
                      // عرض أيقونة الكاميرا كحالة افتراضية
                      : Center(
                          child: Icon(
                            Icons.photo_camera,
                            size: 32,
                            color: context.outline,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppStrings.logoOptional,
                style: AppTextStyles.caption(context).copyWith(
                  color: context.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Fields
        _buildTextField(
          label: AppStrings.clinicName,
          hint: AppStrings.enterClinicNameHint,
          controller: _nameController,
        ),
        const SizedBox(height: 16),

        // Specialty
        Text(
          AppStrings.specialty,
          style: AppTextStyles.bodyMedium(context).copyWith(
            color: context.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: context.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: context.border),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedSpecialty,
              hint: Text(AppStrings.selectSpecialty,
                  style: TextStyle(color: context.textHint)),
              isExpanded: true,
              icon: Icon(Icons.expand_more, color: context.textSecondary),
              items: [
                DropdownMenuItem(
                    value: 'general', child: Text(AppStrings.generalMedicine)),
                DropdownMenuItem(
                    value: 'dental', child: Text(AppStrings.dentalMedicine)),
                DropdownMenuItem(
                    value: 'pediatrics', child: Text(AppStrings.pediatrics)),
                DropdownMenuItem(
                    value: 'cardiology', child: Text(AppStrings.cardiology)),
              ],
              onChanged: (val) {
                setState(() {
                  _selectedSpecialty = val;
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 16),

        _buildTextField(
          label: AppStrings.address,
          hint: AppStrings.addressHint,
          controller: _addressController,
        ),
        const SizedBox(height: 16),

        // Phone
        Text(
          AppStrings.phoneNumber,
          style: AppTextStyles.bodyMedium(context).copyWith(
            color: context.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: context.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: context.border),
          ),
          child: TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,

            textAlign: TextAlign
                .right, // Because RTL parent but text needs right alignment in LTR direction?
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              color: context.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: '+966 5X XXX XXXX',
              hintStyle: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                color: context.textHint,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
        ),

        const SizedBox(height: 16),
        Divider(color: context.border),
        const SizedBox(height: 16),

        // Toggle Card (only for onboarding)
        if (widget.isOnboarding) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.primaryLightColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: context.primary.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.areYouDoctor,
                        style: AppTextStyles.headlineSmall(context).copyWith(
                          color: context.primary,
                        ),
                      ),
                      Text(
                        AppStrings.autoAddAsDoctor,
                        style: AppTextStyles.caption(context).copyWith(
                          color: context.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _isDoctor,
                  onChanged: (val) {
                    setState(() {
                      _isDoctor = val;
                    });
                  },
                  activeColor: context.surface,
                  activeTrackColor: context.primary,
                  inactiveThumbColor: context.surface,
                  inactiveTrackColor: context.surfaceContainerLow,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],

        // Action Buttons
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: context.primaryContainer,
            foregroundColor: context.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.clinic != null
                    ? AppStrings.saveChanges
                    : AppStrings.createClinicAndContinue,
                style: AppTextStyles.headlineSmall(context).copyWith(
                  color: context.onPrimary,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_back),
            ],
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: widget.onBack,
          style: TextButton.styleFrom(
            foregroundColor: context.textSecondary,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            widget.isOnboarding ? AppStrings.backToPrevious : AppStrings.cancel,
            style: AppTextStyles.bodyMedium(context),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium(context).copyWith(
            color: context.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: context.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: context.border),
          ),
          child: TextField(
            controller: controller,
            style: AppTextStyles.bodyMedium(context),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: context.textHint),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
        ),
      ],
    );
  }
}

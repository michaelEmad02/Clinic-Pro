import 'package:flutter/material.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';

class ClinicForm extends StatefulWidget {
  final VoidCallback onSubmit;
  final VoidCallback onBack;

  const ClinicForm({
    super.key,
    required this.onSubmit,
    required this.onBack,
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

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() {
    // Note: Add validation later if needed. For Mock UI, just submit.
    widget.onSubmit();
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
                onTap: () {
                  // Pick image
                },
                borderRadius: BorderRadius.circular(48),
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.outline,
                      style: BorderStyle.solid, // Flutter doesn't have dashed border easily built-in without a package, using solid for now
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.photo_camera,
                      size: 32,
                      color: AppColors.outline,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'صورة الشعار (اختياري)',
                style: AppTextStyles.caption(context).copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        
        // Fields
        _buildTextField(
          label: 'اسم العيادة',
          hint: 'أدخل اسم العيادة',
          controller: _nameController,
        ),
        const SizedBox(height: 16),
        
        // Specialty
        Text(
          'التخصص',
          style: AppTextStyles.bodyMedium(context).copyWith(
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedSpecialty,
              hint: const Text('اختر التخصص', style: TextStyle(color: AppColors.textHint)),
              isExpanded: true,
              icon: const Icon(Icons.expand_more, color: AppColors.textSecondary),
              items: const [
                DropdownMenuItem(value: 'general', child: Text('طب عام')),
                DropdownMenuItem(value: 'dental', child: Text('طب أسنان')),
                DropdownMenuItem(value: 'pediatrics', child: Text('طب أطفال')),
                DropdownMenuItem(value: 'cardiology', child: Text('قلبية')),
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
          label: 'العنوان',
          hint: 'المدينة، الحي، الشارع',
          controller: _addressController,
        ),
        const SizedBox(height: 16),
        
        // Phone
        Text(
          'رقم الهاتف',
          style: AppTextStyles.bodyMedium(context).copyWith(
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.right, // Because RTL parent but text needs right alignment in LTR direction?
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            decoration: const InputDecoration(
              hintText: '+966 5X XXX XXXX',
              hintStyle: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                color: AppColors.textHint,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        const Divider(color: AppColors.border),
        const SizedBox(height: 16),
        
        // Toggle Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'هل أنت طبيب في هذه العيادة؟',
                      style: AppTextStyles.headlineSmall(context).copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      'سيتم إضافتك كطبيب تلقائياً',
                      style: AppTextStyles.caption(context).copyWith(
                        color: AppColors.textSecondary,
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
                activeColor: AppColors.surface,
                activeTrackColor: AppColors.primary,
                inactiveThumbColor: AppColors.surface,
                inactiveTrackColor: AppColors.surfaceContainerHigh,
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Action Buttons
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1A6B8A), // AppColors.primaryContainer
            foregroundColor: AppColors.onPrimary,
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
                'إنشاء العيادة والمتابعة',
                style: AppTextStyles.headlineSmall(context).copyWith(
                  color: AppColors.onPrimary,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_back), // Arrow points left
            ],
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: widget.onBack,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textSecondary,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'العودة للسابق',
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
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: TextField(
            controller: controller,
            style: AppTextStyles.bodyMedium(context),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: AppColors.textHint),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
        ),
      ],
    );
  }
}

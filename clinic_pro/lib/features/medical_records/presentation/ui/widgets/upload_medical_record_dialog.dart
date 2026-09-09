// ────────────────────────────────────────────────────────
// حوار ورقة رفع فحص طبي جديد (UploadMedicalRecordDialog)
// يتكيف تلقائياً بين شاشات المحمول (BottomSheet) والدسكتوب/التابلت (Dialog)
// ────────────────────────────────────────────────────────

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:clinic_pro/core/constants/app_constants.dart';
import 'package:clinic_pro/core/constants/supabase_constants.dart';
import 'package:clinic_pro/core/strings/app_strings.dart';
import 'package:clinic_pro/core/themes/app_colors.dart';
import 'package:clinic_pro/core/themes/app_text_styles.dart';
import 'package:clinic_pro/core/utils/responsive_helper.dart';
import 'package:clinic_pro/core/widgets/app_loading.dart';
import 'package:clinic_pro/core/widgets/app_snackbar.dart';
import 'upload_dialog/upload_image_picker_area.dart';
import 'upload_dialog/upload_record_form_fields.dart';
import 'upload_dialog/upload_type_selector.dart';

class UploadMedicalRecordDialog extends StatefulWidget {
  final String clinicId;
  final String patientId;
  final String? doctorId;
  final String? appointmentId;
  final String? prescriptionId;
  final String initialType;
  final Future<bool> Function({
    required String clinicId,
    required String patientId,
    String? doctorId,
    String? appointmentId,
    String? prescriptionId,
    required String type,
    required String title,
    required File imageFile,
    required String recordDate,
    String? notes,
  }) onUpload;

  const UploadMedicalRecordDialog({
    super.key,
    required this.clinicId,
    required this.patientId,
    this.doctorId,
    this.appointmentId,
    this.prescriptionId,
    this.initialType = MedicalRecordType.labTest,
    required this.onUpload,
  });

  /// عرض النافذة كـ BottomSheet للهاتف وكـ Dialog متمركز للشاشات الكبيرة
  static Future<bool?> show(
    BuildContext context, {
    required String clinicId,
    required String patientId,
    String? doctorId,
    String? appointmentId,
    String? prescriptionId,
    String initialType = MedicalRecordType.labTest,
    required Future<bool> Function({
      required String clinicId,
      required String patientId,
      String? doctorId,
      String? appointmentId,
      String? prescriptionId,
      required String type,
      required String title,
      required File imageFile,
      required String recordDate,
      String? notes,
    }) onUpload,
  }) {
    final isMobile = ResponsiveHelper.isMobile(context);

    if (isMobile) {
      return showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: UploadMedicalRecordDialog(
            clinicId: clinicId,
            patientId: patientId,
            doctorId: doctorId,
            appointmentId: appointmentId,
            prescriptionId: prescriptionId,
            initialType: initialType,
            onUpload: onUpload,
          ),
        ),
      );
    } else {
      return showDialog<bool>(
        context: context,
        builder: (ctx) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: UploadMedicalRecordDialog(
              clinicId: clinicId,
              patientId: patientId,
              doctorId: doctorId,
              appointmentId: appointmentId,
              prescriptionId: prescriptionId,
              initialType: initialType,
              onUpload: onUpload,
            ),
          ),
        ),
      );
    }
  }

  @override
  State<UploadMedicalRecordDialog> createState() =>
      _UploadMedicalRecordDialogState();
}

class _UploadMedicalRecordDialogState
    extends State<UploadMedicalRecordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  final _imagePicker = ImagePicker();

  late String _selectedType;
  late DateTime _selectedDate;
  File? _selectedImage;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
    _selectedDate = DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _imagePicker.pickImage(
        source: source,
        maxWidth: 2400,
        maxHeight: 2400,
        imageQuality: 95,
      );
      if (picked != null) {
        setState(() {
          _selectedImage = File(picked.path);
        });
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.error(context,
            message: '${AppStrings.pickImageError}: $e');
      }
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      locale: Locale(AppStrings.isArabic ? 'ar' : 'en'),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedImage == null) {
      AppSnackbar.warning(context, message: AppStrings.selectImageRequired);
      return;
    }

    setState(() => _isUploading = true);

    final formattedDate =
        '${_selectedDate.year.toString().padLeft(4, '0')}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';

    final success = await widget.onUpload(
      clinicId: widget.clinicId,
      patientId: widget.patientId,
      doctorId: widget.doctorId,
      appointmentId: widget.appointmentId,
      prescriptionId: widget.prescriptionId,
      type: _selectedType,
      title: _titleController.text.trim(),
      imageFile: _selectedImage!,
      recordDate: formattedDate,
      notes: _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : null,
    );

    if (mounted) {
      setState(() => _isUploading = false);
      if (success) {
        Navigator.of(context).pop(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final suggestions = _selectedType == MedicalRecordType.labTest
        ? AppStrings.labSuggestions
        : AppStrings.radiologySuggestions;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: isMobile
            ? const BorderRadius.vertical(top: Radius.circular(24))
            : BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // مقبض السحب للموبايل
          if (isMobile)
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: context.borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

          // ترويسة الحوار
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Container(
                    key: ValueKey(_selectedType),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: context.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _selectedType == MedicalRecordType.labTest
                          ? Icons.science_rounded
                          : Icons.camera_alt_rounded,
                      color: context.primary,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    AppStrings.uploadMedicalRecord,
                    style: AppTextStyles.headlineSmall(context).copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: AppStrings.close,
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // نموذج إدخال البيانات
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.spaceLg),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // محدد نوع الفحص
                    UploadTypeSelector(
                      selectedType: _selectedType,
                      onTypeChanged: (val) {
                        setState(() => _selectedType = val);
                      },
                    ),
                    const SizedBox(height: AppConstants.spaceMd),

                    // اختيار ومعاينة الصورة
                    UploadImagePickerArea(
                      selectedImage: _selectedImage,
                      onPickImage: _pickImage,
                      onClearImage: () => setState(() => _selectedImage = null),
                    ),
                    const SizedBox(height: AppConstants.spaceMd),

                    // حقول البيانات واقتراحات الأسماء
                    UploadRecordFormFields(
                      titleController: _titleController,
                      notesController: _notesController,
                      selectedDate: _selectedDate,
                      suggestions: suggestions,
                      onSelectDate: _selectDate,
                      onSelectSuggestion: (s) {
                        _titleController.text = s;
                      },
                    ),
                    const SizedBox(height: AppConstants.spaceLg),

                    // زر الرفع والحفظ بأشكال انيميشن
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isUploading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.primary,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppConstants.radiusButton),
                          ),
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: _isUploading
                              ? AppLoadingWidget(
                                  size: AppLoadingSize.small,
                                  color: context.onPrimary,
                                )
                              : Text(
                                  AppStrings.uploadAndSave,
                                  style: AppTextStyles.bodyMedium(context).copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';

// ────────────────────────────────────────────────────────
// شاشة إضافة/تعديل دواء في قاعدة البيانات
// الحقول تتطابق مع جدول drugs في الـ schema:
// trade_name, generic_name, category
// ────────────────────────────────────────────────────────

class AddEditDrugSheet extends StatefulWidget {
  final Map<String, dynamic>? drug;
  final Function({
    required String tradeName,
    required String genericName,
    required String category,
  }) onSave;

  const AddEditDrugSheet({
    super.key,
    this.drug,
    required this.onSave,
  });

  @override
  State<AddEditDrugSheet> createState() => _AddEditDrugSheetState();
}

class _AddEditDrugSheetState extends State<AddEditDrugSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _tradeNameController;
  late TextEditingController _genericNameController;
  late TextEditingController _categoryController;

  @override
  void initState() {
    super.initState();
    _tradeNameController = TextEditingController(text: widget.drug?['trade_name'] ?? '');
    _genericNameController = TextEditingController(text: widget.drug?['generic_name'] ?? '');
    _categoryController = TextEditingController(text: widget.drug?['category'] ?? '');
  }

  @override
  void dispose() {
    _tradeNameController.dispose();
    _genericNameController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.drug != null;

    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              isEditing ? 'تعديل بيانات الدواء' : 'إضافة دواء جديد',
              style: AppTextStyles.headlineMedium(context).copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // الاسم التجاري
            TextFormField(
              controller: _tradeNameController,
              decoration: const InputDecoration(
                labelText: 'الاسم التجاري للدواء',
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.isEmpty) ? 'الرجاء إدخال الاسم التجاري' : null,
            ),
            const SizedBox(height: 12),

            // الاسم العلمي
            TextFormField(
              controller: _genericNameController,
              decoration: const InputDecoration(
                labelText: 'الاسم العلمي / المادة الفعالة',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            // التصنيف
            TextFormField(
              controller: _categoryController,
              decoration: const InputDecoration(
                labelText: 'تصنيف الدواء (مثال: مضاد حيوي، مسكن)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // زر الحفظ
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  widget.onSave(
                    tradeName: _tradeNameController.text,
                    genericName: _genericNameController.text,
                    category: _categoryController.text,
                  );
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                isEditing ? 'حفظ التعديلات' : 'إضافة إلى القائمة',
                style: AppTextStyles.headlineSmall(context).copyWith(
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

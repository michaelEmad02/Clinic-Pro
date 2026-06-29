import 'package:flutter/material.dart';
import '../../../../../core/mocks/mock_data.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';

// ────────────────────────────────────────────────────────
// شاشة إنشاء/تعديل قالب روشتة جديد
// ────────────────────────────────────────────────────────

class AddEditTemplateSheet extends StatefulWidget {
  final Function(String title, String category, List<Map<String, dynamic>> drugs) onSave;

  const AddEditTemplateSheet({super.key, required this.onSave});

  @override
  State<AddEditTemplateSheet> createState() => _AddEditTemplateSheetState();
}

class _AddEditTemplateSheetState extends State<AddEditTemplateSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _categoryController = TextEditingController(text: 'حالات حادة');

  final List<Map<String, dynamic>> _allDrugs = MockData.drugs;
  final List<String> _selectedDrugIds = [];

  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'إنشاء قالب روشتة جديد',
              style: AppTextStyles.headlineMedium(context).copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'اسم القالب (مثال: قالب التهاب اللوزتين للأطفال)',
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.isEmpty) ? 'الرجاء إدخال اسم القالب' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _categoryController,
              decoration: const InputDecoration(
                labelText: 'تصنيف القالب (مثال: حالات حادة، أمراض مزمنة)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'اختر الأدوية المشمولة في هذا القالب:',
              style: AppTextStyles.bodyMedium(context).copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _allDrugs.length,
                itemBuilder: (context, index) {
                  final drug = _allDrugs[index];
                  final drugId = drug['id'] as String;
                  final isChecked = _selectedDrugIds.contains(drugId);

                  return CheckboxListTile(
                    title: Text(
                      drug['trade_name'] ?? '',
                      style: AppTextStyles.bodyMedium(context),
                    ),
                    subtitle: Text(
                      drug['generic_name'] ?? '',
                      style: AppTextStyles.caption(context),
                    ),
                    value: isChecked,
                    onChanged: (checked) {
                      setState(() {
                        if (checked == true) {
                          _selectedDrugIds.add(drugId);
                        } else {
                          _selectedDrugIds.remove(drugId);
                        }
                      });
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final selectedDrugs = _selectedDrugIds.map((id) {
                    return {'drug_id': id};
                  }).toList();
                  widget.onSave(
                    _titleController.text,
                    _categoryController.text,
                    selectedDrugs,
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
              child: const Text(
                'حفظ القالب',
                style: TextStyle(fontFamily: 'Cairo', fontSize: 16),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

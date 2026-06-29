import 'package:flutter/material.dart';
import '../../../../../core/mocks/mock_data.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';

// ────────────────────────────────────────────────────────
// شاشة البحث عن الأدوية وإضافتها للروشتة (BottomSheet)
// ────────────────────────────────────────────────────────

class AddDrugSearchSheet extends StatefulWidget {
  final Function(Map<String, dynamic> drug) onDrugSelected;

  const AddDrugSearchSheet({super.key, required this.onDrugSelected});

  @override
  State<AddDrugSearchSheet> createState() => _AddDrugSearchSheetState();
}

class _AddDrugSearchSheetState extends State<AddDrugSearchSheet> {
  final List<Map<String, dynamic>> _allDrugs = MockData.drugs;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    // تصفية الأدوية حسب البحث
    final filteredDrugs = _allDrugs.where((drug) {
      final tradeName = (drug['trade_name'] as String? ?? '').toLowerCase();
      final genericName = (drug['generic_name'] as String? ?? '').toLowerCase();
      final query = _searchQuery.toLowerCase();
      return tradeName.contains(query) || genericName.contains(query);
    }).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // مقبض السحب
          Center(
            child: Container(
              width: 32,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'إضافة دواء للوصفة',
                style: AppTextStyles.headlineMedium(context).copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // حقل البحث
          TextField(
            onChanged: (val) {
              setState(() {
                _searchQuery = val;
              });
            },
            decoration: InputDecoration(
              hintText: 'ابحث عن دواء باسمه العلمي أو التجاري...',
              hintStyle: AppTextStyles.bodyMedium(context).copyWith(
                color: AppColors.textHint,
              ),
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // قائمة الأدوية المصفاة
          Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.4,
            ),
            child: filteredDrugs.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: Text('لا توجد أدوية مطابقة للبحث')),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: filteredDrugs.length,
                    itemBuilder: (context, index) {
                      final drug = filteredDrugs[index];
                      return ListTile(
                        leading: const Icon(Icons.medication, color: AppColors.primary),
                        title: Text(
                          drug['trade_name'] ?? '',
                          style: AppTextStyles.bodyMedium(context).copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          drug['generic_name'] ?? '',
                          style: AppTextStyles.caption(context).copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        trailing: ElevatedButton(
                          onPressed: () {
                            widget.onDrugSelected(drug);
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryLight,
                            foregroundColor: AppColors.primary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('إضافة'),
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

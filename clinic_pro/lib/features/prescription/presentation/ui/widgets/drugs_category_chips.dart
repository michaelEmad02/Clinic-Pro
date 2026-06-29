import 'package:flutter/material.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';

// ────────────────────────────────────────────────────────
// رقاقات تصنيفات الأدوية (أفقية قابلة للتمرير)
// ────────────────────────────────────────────────────────

class DrugsCategoryChips extends StatelessWidget {
  final String? selectedCategory;
  final ValueChanged<String?> onCategorySelected;

  const DrugsCategoryChips({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  static const List<Map<String, String>> _categories = [
    {'label': 'الكل', 'value': 'all'},
    {'label': 'مضاد حيوي', 'value': 'مضاد حيوي'},
    {'label': 'خافض حرارة', 'value': 'خافض حرارة'},
    {'label': 'أمراض صدر', 'value': 'أمراض صدر'},
    {'label': 'أدوية مزمنة', 'value': 'أدوية مزمنة'},
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = (selectedCategory == null && cat['value'] == 'all') ||
              (selectedCategory == cat['value']);

          return Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: ChoiceChip(
              label: Text(
                cat['label']!,
                style: AppTextStyles.labelChip(context).copyWith(
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (cat['value'] == 'all') {
                  onCategorySelected(null);
                } else {
                  onCategorySelected(cat['value']);
                }
              },
              selectedColor: AppColors.primaryLight,
              backgroundColor: AppColors.surfaceAlt,
              checkmarkColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? AppColors.primary.withOpacity(0.3) : Colors.transparent,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../../core/strings/app_strings.dart';
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

  static List<Map<String, String>> get _categories => [
        {'label': AppStrings.all, 'value': 'all'},
        {'label': AppStrings.antibiotic, 'value': AppStrings.antibiotic},
        {'label': AppStrings.antipyretic, 'value': AppStrings.antipyretic},
        {'label': AppStrings.respiratory, 'value': AppStrings.respiratory},
        {'label': AppStrings.chronic, 'value': AppStrings.chronic},
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
          final isSelected =
              (selectedCategory == null && cat['value'] == 'all') ||
                  (selectedCategory == cat['value']);

          return Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: ChoiceChip(
              label: Text(
                cat['label']!,
                style: AppTextStyles.labelChip(context).copyWith(
                  color: isSelected ? context.primary : context.textSecondary,
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
              selectedColor: context.primaryFixedDim,
              backgroundColor: context.primary,
              checkmarkColor: context.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected
                      ? context.primary.withOpacity(0.3)
                      : Colors.transparent,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

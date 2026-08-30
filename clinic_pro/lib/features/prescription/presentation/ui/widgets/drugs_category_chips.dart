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
  final List<String> categories;

  const DrugsCategoryChips({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.categories,
  });

  List<Map<String, String>> get _categoriesList => [
        {'label': AppStrings.all, 'value': 'all'},
        ...categories.map((c) => {'label': c, 'value': c}),
      ];

  @override
  Widget build(BuildContext context) {
    final list = _categoriesList;
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final cat = list[index];
          final isSelected =
              (selectedCategory == null && cat['value'] == 'all') ||
                  (selectedCategory == cat['value']);

          return Padding(
            padding: const EdgeInsetsDirectional.only(end: 8.0),
            child: ChoiceChip(
              label: Text(
                cat['label']!,
                style: AppTextStyles.labelChip(context).copyWith(
                  color: isSelected ? context.primary : context.textSecondary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
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
              selectedColor: context.primaryLightColor,
              backgroundColor: context.surface,
              showCheckmark: false,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected
                      ? context.primary
                      : context.border,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

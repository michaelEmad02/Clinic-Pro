// ────────────────────────────────────────────────────────
// فلاتر فئات المصروفات — الكل، إيجار، كهرباء، لوازم، إلخ
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../../core/themes/app_colors.dart';

class ExpensesCategoryChips extends StatelessWidget {
  final List<Map<String, dynamic>> categories;
  final String? activeCategoryId;
  final ValueChanged<String?> onChanged;

  const ExpensesCategoryChips({
    super.key,
    required this.categories,
    required this.activeCategoryId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 8),
            child: ChoiceChip(
              label: Text(
                'الكل',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12,
                  color: activeCategoryId == null
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  fontWeight: activeCategoryId == null
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
              selected: activeCategoryId == null,
              onSelected: (_) => onChanged(null),
              selectedColor: AppColors.primaryLight,
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: activeCategoryId == null
                      ? AppColors.primary
                      : AppColors.border,
                ),
              ),
              showCheckmark: false,
            ),
          ),
          ...categories.map((cat) {
            final catId = cat['id'] as String;
            final label = cat['label'] as String;
            final isSelected = activeCategoryId == catId;

            return Padding(
              padding: const EdgeInsetsDirectional.only(start: 8),
              child: ChoiceChip(
                label: Text(label),
                selected: isSelected,
                onSelected: (_) => onChanged(isSelected ? null : catId),
                selectedColor: AppColors.primaryLight,
                backgroundColor: AppColors.surface,
                labelStyle: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected ? AppColors.primary : AppColors.border,
                  ),
                ),
                showCheckmark: false,
              ),
            );
          }),
        ],
      ),
    );
  }
}

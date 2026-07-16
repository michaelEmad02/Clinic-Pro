// ────────────────────────────────────────────────────────
// فلاتر فئات المصروفات — الكل، إيجار، كهرباء، لوازم، إلخ
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../manager/expenses_state.dart';

class ExpensesCategoryChips extends StatelessWidget {
  final List<ExpenseCategory> categories;
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
                AppStrings.all,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12,
                  color: activeCategoryId == null
                      ? context.primary
                      : context.textSecondary,
                  fontWeight: activeCategoryId == null
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
              selected: activeCategoryId == null,
              onSelected: (_) => onChanged(null),
              selectedColor: context.primaryLightColor,
              backgroundColor: context.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: activeCategoryId == null
                      ? context.primary
                      : context.border,
                ),
              ),
              showCheckmark: false,
            ),
          ),
          ...categories.map((cat) {
            final isSelected = activeCategoryId == cat.id;

            return Padding(
              padding: const EdgeInsetsDirectional.only(start: 8),
              child: ChoiceChip(
                label: Text(cat.name),
                selected: isSelected,
                onSelected: (_) => onChanged(isSelected ? null : cat.id),
                selectedColor: context.primaryLightColor,
                backgroundColor: context.surface,
                labelStyle: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12,
                  color: isSelected ? context.primary : context.textSecondary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected ? context.primary : context.border,
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

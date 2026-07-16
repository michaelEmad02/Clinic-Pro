import 'package:flutter/material.dart';
import '../themes/app_colors.dart';
import '../themes/app_text_styles.dart';
import '../constants/app_constants.dart';

class DoseChipSelector extends StatelessWidget {
  final List<String> options;
  final String? selectedOption;
  final ValueChanged<String> onSelected;

  const DoseChipSelector({
    super.key,
    required this.options,
    required this.selectedOption,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppConstants.spaceSm,
      runSpacing: AppConstants.spaceSm,
      children: options.map((option) {
        final isSelected = option == selectedOption;
        return ChoiceChip(
          label: Text(option),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              onSelected(option);
            }
          },
          labelStyle: AppTextStyles.bodyMedium(context).copyWith(
            color: isSelected ? context.textPrimary: context.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          selectedColor: context.primary,
          backgroundColor: context.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusChip),
            side: BorderSide(
              color: isSelected ? context.primary : context.border,
            ),
          ),
        );
      }).toList(),
    );
  }
}

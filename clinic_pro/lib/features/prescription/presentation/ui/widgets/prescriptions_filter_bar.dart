import 'package:flutter/material.dart';
import 'package:clinic_pro/core/constants/app_constants.dart';
import 'package:clinic_pro/core/strings/app_strings.dart';
import 'package:clinic_pro/core/themes/app_colors.dart';
import 'package:clinic_pro/core/themes/app_text_styles.dart';
import 'package:clinic_pro/features/prescription/presentation/manager/all_prescriptions_state.dart';

class PrescriptionsFilterBar extends StatelessWidget {
  final PrescriptionDateFilter selectedFilter;
  final ValueChanged<PrescriptionDateFilter> onFilterSelected;

  const PrescriptionsFilterBar({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    final filters = [
      (PrescriptionDateFilter.all, AppStrings.filterAll),
      (PrescriptionDateFilter.today, AppStrings.filterToday),
      (PrescriptionDateFilter.thisWeek, AppStrings.filterThisWeek),
      (PrescriptionDateFilter.thisMonth, AppStrings.filterThisMonth),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) {
          final isSelected = selectedFilter == f.$1;
          return Padding(
            padding: const EdgeInsetsDirectional.only(end: 8),
            child: ChoiceChip(
              label: Text(f.$2),
              selected: isSelected,
              onSelected: (_) => onFilterSelected(f.$1),
              selectedColor: context.primary,
              backgroundColor: context.surface,
              labelStyle: AppTextStyles.caption(context).copyWith(
                color: isSelected ? Colors.white : context.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              side: BorderSide(
                color: isSelected
                    ? context.primary
                    : context.outline.withOpacity(0.5),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusChip),
              ),
              showCheckmark: false,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            ),
          );
        }).toList(),
      ),
    );
  }
}

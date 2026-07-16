import 'package:flutter/material.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../manager/staff_state.dart';

class StaffFilterChips extends StatelessWidget {
  final StaffFilter activeFilter;
  final ValueChanged<StaffFilter> onChanged;

  const StaffFilterChips({
    super.key,
    required this.activeFilter,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // بناء قائمة الفلاتر ديناميكياً بناءً على الأدوار الحقيقية للنظام
    final filters = [
      (StaffFilter.all, AppStrings.all),
      (StaffFilter.doctor, AppStrings.roleLabel('doctor')),
      (StaffFilter.secretary, AppStrings.roleLabel('secretary')),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: filters.map((f) {
          final isSelected = activeFilter == f.$1;
          return Padding(
            padding: const EdgeInsetsDirectional.only(start: 8),
            child: ChoiceChip(
              label: Text(f.$2),
              selected: isSelected,
              onSelected: (_) => onChanged(f.$1),
              selectedColor: context.primary,
              backgroundColor: context.surface,
              labelStyle: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                color: isSelected ? context.textPrimary : context.textSecondary,
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
        }).toList(),
      ),
    );
  }
}

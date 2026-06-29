// ────────────────────────────────────────────────────────
// فلاتر الطاقم الطبي — الكل، أطباء، تمريض، إدارة
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
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

  static const _filters = [
    (StaffFilter.all, 'الكل'),
    (StaffFilter.doctors, 'أطباء'),
    (StaffFilter.nursing, 'تمريض'),
    (StaffFilter.admin, 'إدارة'),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: _filters.map((f) {
          final isSelected = activeFilter == f.$1;
          return Padding(
            padding: const EdgeInsetsDirectional.only(start: 8),
            child: ChoiceChip(
              label: Text(f.$2),
              selected: isSelected,
              onSelected: (_) => onChanged(f.$1),
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.surface,
              labelStyle: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
        }).toList(),
      ),
    );
  }
}

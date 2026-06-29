// ────────────────────────────────────────────────────────
// فلاتر قائمة المرضى — مطابق لتصميم Stitch
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../manager/patients_state.dart';

class PatientsFilterChips extends StatelessWidget {
  final PatientsFilter activeFilter;
  final ValueChanged<PatientsFilter> onChanged;

  const PatientsFilterChips({
    super.key,
    required this.activeFilter,
    required this.onChanged,
  });

  static const _filters = [
    (PatientsFilter.all, 'الكل'),
    (PatientsFilter.today, 'اليوم'),
    (PatientsFilter.thisWeek, 'هذا الأسبوع'),
    (PatientsFilter.chronic, 'مزمن'),
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

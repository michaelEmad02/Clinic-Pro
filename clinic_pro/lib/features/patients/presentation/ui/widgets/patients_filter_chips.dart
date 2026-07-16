// ────────────────────────────────────────────────────────
// فلاتر قائمة المرضى — مطابق لتصميم Stitch
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../../core/strings/app_strings.dart';
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

  static final _filters = [
    (PatientsFilter.all, AppStrings.all),
    (PatientsFilter.today, AppStrings.today),
    (PatientsFilter.thisWeek, AppStrings.weekly),
    (PatientsFilter.chronic, AppStrings.isArabic ? 'مزمن' : 'Chronic'),
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
              selectedColor: context.primary,
              backgroundColor: context.surface,
              labelStyle: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                color: isSelected ? context.onPrimary : context.textSecondary,
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

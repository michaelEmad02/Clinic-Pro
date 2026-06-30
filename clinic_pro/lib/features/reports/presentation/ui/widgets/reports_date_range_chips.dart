// ────────────────────────────────────────────────────────
// فلاتر النطاق الزمني للتقارير — أسبوع، شهر، 3 أشهر، مخصص
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../manager/reports_state.dart';

class ReportsDateRangeChips extends StatelessWidget {
  final ReportsDateRange activeRange;
  final ValueChanged<ReportsDateRange> onChanged;

  const ReportsDateRangeChips({
    super.key,
    required this.activeRange,
    required this.onChanged,
  });

  static const _ranges = [
    (ReportsDateRange.thisWeek, 'هذا الأسبوع'),
    (ReportsDateRange.thisMonth, 'هذا الشهر'),
    (ReportsDateRange.threeMonths, '3 أشهر'),
    (ReportsDateRange.custom, 'مخصص'),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: _ranges.map((r) {
          final isSelected = activeRange == r.$1;
          return Padding(
            padding: const EdgeInsetsDirectional.only(start: 8),
            child: ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (r.$1 == ReportsDateRange.custom) ...[
                    const Icon(Icons.calendar_month, size: 14),
                    const SizedBox(width: 4),
                  ],
                  Text(r.$2),
                ],
              ),
              selected: isSelected,
              onSelected: (_) => onChanged(r.$1),
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
                  color:
                      isSelected ? AppColors.primary : AppColors.outline,
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

// ────────────────────────────────────────────────────────
// فلاتر النطاق الزمني للتقارير — أسبوع، شهر، 3 أشهر، مخصص
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../../core/strings/app_strings.dart';
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

  static List<(ReportsDateRange, String)> get _ranges => [
        (
          ReportsDateRange.thisWeek,
          AppStrings.isArabic ? 'هذا الأسبوع' : 'This Week'
        ),
        (
          ReportsDateRange.thisMonth,
          AppStrings.isArabic ? 'هذا الشهر' : 'This Month'
        ),
        (
          ReportsDateRange.threeMonths,
          AppStrings.isArabic ? '3 أشهر' : '3 Months'
        ),
        (ReportsDateRange.custom, AppStrings.customRange),
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
                  color: isSelected ? context.primary : context.outline,
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

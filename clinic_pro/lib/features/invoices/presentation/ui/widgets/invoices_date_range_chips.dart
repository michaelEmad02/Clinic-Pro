import 'package:flutter/material.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../manager/invoices_state.dart';

class InvoicesDateRangeChips extends StatelessWidget {
  final InvoicesDateRange activeRange;
  final ValueChanged<InvoicesDateRange> onChanged;

  const InvoicesDateRangeChips({
    super.key,
    required this.activeRange,
    required this.onChanged,
  });

  List<(InvoicesDateRange, String)> get _ranges => [
    (InvoicesDateRange.today, AppStrings.isArabic ? 'اليوم' : 'Today'),
    (InvoicesDateRange.thisWeek, AppStrings.isArabic ? 'هذا الأسبوع' : 'This Week'),
    (InvoicesDateRange.thisMonth, AppStrings.isArabic ? 'هذا الشهر' : 'This Month'),
    (InvoicesDateRange.threeMonths, AppStrings.isArabic ? '3 أشهر' : '3 Months'),
    (InvoicesDateRange.all, AppStrings.isArabic ? 'الكل' : 'All'),
    (InvoicesDateRange.custom, AppStrings.isArabic ? 'مخصص' : 'Custom'),
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
            padding: const EdgeInsetsDirectional.only(end: 8),
            child: ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (r.$1 == InvoicesDateRange.custom) ...[
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
                color: isSelected
                    ? context.primary
                    : context.textSecondary,
                fontWeight:
                    isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color:
                      isSelected ? context.primary : context.outline,
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

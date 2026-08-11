import 'package:flutter/material.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../manager/invoices_state.dart';

class InvoicesDateRangeChips extends StatelessWidget {
  final InvoicesDateRange activeDateRange;
  final String activeStatusFilter;
  final ValueChanged<InvoicesDateRange> onDateRangeChanged;
  final ValueChanged<String> onStatusFilterChanged;

  const InvoicesDateRangeChips({
    super.key,
    required this.activeDateRange,
    required this.activeStatusFilter,
    required this.onDateRangeChanged,
    required this.onStatusFilterChanged,
  });

  List<(InvoicesDateRange, String)> get _dateRanges => [
        (InvoicesDateRange.all, AppStrings.isArabic ? 'الكل' : 'All'),
        (InvoicesDateRange.today, AppStrings.isArabic ? 'اليوم' : 'Today'),
        (InvoicesDateRange.thisWeek, AppStrings.isArabic ? 'هذا الأسبوع' : 'This Week'),
        (InvoicesDateRange.thisMonth, AppStrings.isArabic ? 'هذا الشهر' : 'This Month'),
        (InvoicesDateRange.threeMonths, AppStrings.isArabic ? '3 أشهر' : '3 Months'),
        (InvoicesDateRange.custom, AppStrings.isArabic ? 'مخصص' : 'Custom'),
      ];

  List<String> get _statusFilters => ['الكل', 'جزئي', 'مدفوع'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // فلتر نطاق التاريخ
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: _dateRanges.map((r) {
              final isSelected = activeDateRange == r.$1;
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
                  onSelected: (_) => onDateRangeChanged(r.$1),
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
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
        // فلتر حالة الفاتورة
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: _statusFilters.map((f) {
              final isSelected = activeStatusFilter == f;
              return Padding(
                padding: const EdgeInsetsDirectional.only(end: 8),
                child: ChoiceChip(
                  label: Text(_getLocalStatusText(f)),
                  selected: isSelected,
                  onSelected: (_) => onStatusFilterChanged(f),
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
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  String _getLocalStatusText(String status) {
    if (AppStrings.isArabic) return status;
    switch (status) {
      case 'الكل':
        return 'All';
      case 'جزئي':
        return 'Partial';
      case 'مدفوع':
        return 'Paid';
      default:
        return status;
    }
  }
}

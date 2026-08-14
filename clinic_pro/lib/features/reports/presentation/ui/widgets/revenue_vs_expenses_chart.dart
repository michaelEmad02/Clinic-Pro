// ────────────────────────────────────────────────────────
// رسم بياني: الإيرادات المحجوزة vs المحصل vs المصروفات (fl_chart)
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/utils/responsive_helper.dart';
import '../../manager/reports_state.dart';

class RevenueVsExpensesChart extends StatelessWidget {
  final List<WeeklyData> data;

  const RevenueVsExpensesChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const SizedBox.shrink();
    }

    final maxVal = data.fold<double>(
      0,
      (max, d) => [max, d.revenue, d.collected, d.expenses].reduce((a, b) => a > b ? a : b),
    );

    final maxY = maxVal > 0 ? (maxVal * 1.25) : 100.0;
    final currencyFormat = NumberFormat.compact();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.outline),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 3,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStrings.isArabic ? 'المقارنة المالية' : 'Financial Comparison',
                  style: AppTextStyles.headlineSmall(context).copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: ResponsiveHelper.isMobile(context) ? 220 : 300,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxY,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final item = data[group.x.toInt()];
                        String title;
                        double val;
                        if (rodIndex == 0) {
                          title = AppStrings.isArabic ? 'الإيراد المتوقع' : 'Expected Revenue';
                          val = item.revenue;
                        } else if (rodIndex == 1) {
                          title = AppStrings.isArabic ? 'المُحصل الفعلي' : 'Collected';
                          val = item.collected;
                        } else {
                          title = AppStrings.expenses;
                          val = item.expenses;
                        }
                        return BarTooltipItem(
                          '$title (${item.week})\n',
                          TextStyle(
                            color: context.surface,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          children: [
                            TextSpan(
                              text: '${val.toStringAsFixed(0)} ${AppStrings.isArabic ? 'ج.م' : 'EGP'}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 42,
                        getTitlesWidget: (value, meta) {
                          if (value == meta.max) {
                            return const SizedBox.shrink();
                          }
                          return Text(
                            currencyFormat.format(value),
                            style: TextStyle(
                              fontSize: 10,
                              color: context.textHint,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= data.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              data[idx].week,
                              style: AppTextStyles.caption(context).copyWith(
                                fontSize: 10,
                                color: context.textSecondary,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: context.outline.withOpacity(0.4),
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: data.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final item = entry.value;
                    return BarChartGroupData(
                      x: idx,
                      barRods: [
                        BarChartRodData(
                          toY: item.revenue,
                          color: context.primary,
                          width: 10,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        ),
                        BarChartRodData(
                          toY: item.collected,
                          color: context.successText,
                          width: 10,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        ),
                        BarChartRodData(
                          toY: item.expenses,
                          color: context.dangerBg,
                          width: 10,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // وسيلة الإيضاح (3 عناصر)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _LegendItem(
                  color: context.primary,
                  label: AppStrings.isArabic ? 'الإيراد المتوقع' : 'Expected',
                ),
                _LegendItem(
                  color: context.successText,
                  label: AppStrings.isArabic ? 'المُحصل الفعلي' : 'Collected',
                ),
                _LegendItem(
                  color: context.dangerBg,
                  label: AppStrings.expenses,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: AppTextStyles.caption(context).copyWith(
            color: context.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

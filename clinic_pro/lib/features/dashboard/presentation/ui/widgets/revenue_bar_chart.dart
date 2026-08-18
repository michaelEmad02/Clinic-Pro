// ─────────────────────────────────────────
// مخطط الإيرادات الأسبوعية المتجاوب (Responsive Bar Chart)
// ─────────────────────────────────────────

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:clinic_pro/core/utils/responsive_helper.dart';
import 'package:clinic_pro/core/strings/app_strings.dart';
import 'package:clinic_pro/core/themes/app_colors.dart';
import 'package:clinic_pro/core/themes/app_text_styles.dart';

class RevenueBarChart extends StatelessWidget {
  final List<double> weeklyRevenue;

  const RevenueBarChart({
    super.key,
    required this.weeklyRevenue,
  });

  @override
  Widget build(BuildContext context) {
    final weekdays = AppStrings.dayNames;
    final isMobile = ResponsiveHelper.isMobile(context);

    // حساب القيمة العظمى ديناميكياً لتجنب طفح الأعمدة البيانية
    final maxVal = weeklyRevenue.fold<double>(0.0, (m, e) => e > m ? e : m);
    final computedMaxY = maxVal > 0 ? (maxVal * 1.25) : 1000.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.isArabic ? 'الإيرادات الأسبوعية' : 'Weekly Revenue',
            style: AppTextStyles.headlineSmall(context).copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          AspectRatio(
            aspectRatio: isMobile ? 1.6 : 2.5,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: computedMaxY,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => AppColors.primary,
                    tooltipPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    tooltipMargin: 4,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '\$${rod.toY.toInt()}',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter',
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        final idx = value.toInt();
                        if (idx >= 0 && idx < weekdays.length) {
                          final dayName = weekdays[idx];
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                dayName,
                                style: AppTextStyles.caption(context).copyWith(
                                  fontSize: 10,
                                  color: context.textSecondary,
                                ),
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        if (value > 0) {
                          final valStr = value >= 1000 ? '${(value / 1000).toStringAsFixed(1)}k' : '${value.toInt()}';
                          return Text(
                            valStr,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 10,
                              color: context.textSecondary,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: context.borderColor,
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(weeklyRevenue.length, (index) {
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: weeklyRevenue[index],
                        color: AppColors.primaryContainer,
                        width: isMobile ? 14 : 20,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: computedMaxY,
                          color: context.isDarkMode ? AppColors.darkBackground : AppColors.surfaceContainerLow,
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

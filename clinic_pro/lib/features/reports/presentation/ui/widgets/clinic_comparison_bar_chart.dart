import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:clinic_pro/core/strings/app_strings.dart';
import 'package:clinic_pro/core/themes/app_colors.dart';
import 'package:clinic_pro/core/themes/app_text_styles.dart';
import 'package:clinic_pro/features/reports/domain/entities/clinic_report_entity.dart';

class ClinicComparisonBarChart extends StatelessWidget {
  final List<ClinicComparisonItem> clinics;

  const ClinicComparisonBarChart({super.key, required this.clinics});

  @override
  Widget build(BuildContext context) {
    if (clinics.isEmpty) return const SizedBox.shrink();

    double maxVal = 0.0;
    for (final c in clinics) {
      if (c.expectedRevenue > maxVal) maxVal = c.expectedRevenue;
      if (c.collectedAmount > maxVal) maxVal = c.collectedAmount;
    }
    final maxY = maxVal > 0 ? (maxVal * 1.25) : 100.0;
    final currencyFormat = NumberFormat.compact();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.borderColor, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.isArabic ? 'مقارنة إيرادات الفروع (المتوقع vs المحصل)' : 'Revenue Comparison per Clinic',
              style: AppTextStyles.headlineSmall(context).copyWith(
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            // Legend
            Row(
              children: [
                Container(width: 12, height: 12, color: Colors.orange),
                const SizedBox(width: 4),
                Text(
                  AppStrings.isArabic ? 'متوقع (Appointments)' : 'Expected',
                  style: AppTextStyles.caption(context).copyWith(color: context.textSecondary),
                ),
                const SizedBox(width: 16),
                Container(width: 12, height: 12, color: context.primary),
                const SizedBox(width: 4),
                Text(
                  AppStrings.isArabic ? 'محصل فعلي (Invoices)' : 'Collected',
                  style: AppTextStyles.caption(context).copyWith(color: context.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxY,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final clinic = clinics[groupIndex];
                        final isExpected = rodIndex == 0;
                        final label = isExpected
                            ? '${AppStrings.isArabic ? "متوقع" : "Expected"}: ${clinic.expectedRevenue.toStringAsFixed(0)} ${AppStrings.egp}'
                            : '${AppStrings.isArabic ? "محصل" : "Collected"}: ${clinic.collectedAmount.toStringAsFixed(0)} ${AppStrings.egp}';
                        return BarTooltipItem(
                          '${clinic.clinicName}\n$label',
                          AppTextStyles.caption(context).copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
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
                          return Text(
                            currencyFormat.format(value),
                            style: AppTextStyles.caption(context).copyWith(
                              color: context.textSecondary,
                              fontSize: 10,
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
                          if (idx >= 0 && idx < clinics.length) {
                            final name = clinics[idx].clinicName;
                            final shortName = name.length > 8 ? '${name.substring(0, 8)}...' : name;
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                shortName,
                                style: AppTextStyles.caption(context).copyWith(
                                  color: context.textSecondary,
                                  fontSize: 10,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: maxY / 4,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: context.borderColor.withOpacity(0.5),
                      strokeWidth: 0.5,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: clinics.asMap().entries.map((entry) {
                    final index = entry.key;
                    final clinic = entry.value;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: clinic.expectedRevenue,
                          color: Colors.orange,
                          width: 12,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                        BarChartRodData(
                          toY: clinic.collectedAmount,
                          color: context.primary,
                          width: 12,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

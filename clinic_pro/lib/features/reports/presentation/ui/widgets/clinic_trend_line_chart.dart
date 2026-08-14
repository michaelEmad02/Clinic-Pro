import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:clinic_pro/core/strings/app_strings.dart';
import 'package:clinic_pro/core/themes/app_colors.dart';
import 'package:clinic_pro/core/themes/app_text_styles.dart';
import 'package:clinic_pro/features/reports/domain/entities/clinic_report_entity.dart';

class ClinicTrendLineChart extends StatelessWidget {
  final List<ClinicComparisonItem> clinics;

  const ClinicTrendLineChart({super.key, required this.clinics});

  @override
  Widget build(BuildContext context) {
    if (clinics.isEmpty) return const SizedBox.shrink();

    final colors = [
      context.primary,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
      if (context.isDarkMode) Colors.pinkAccent else Colors.pink,
    ];

    final monthsCount = clinics.first.monthlyPerformance.length; // 5 months
    if (monthsCount == 0) return const SizedBox.shrink();

    double maxY = 0;
    for (final c in clinics) {
      for (final p in c.monthlyPerformance) {
        if (p.amount > maxY) maxY = p.amount;
      }
      for (final p in c.monthlyExpectedPerformance) {
        if (p.amount > maxY) maxY = p.amount;
      }
    }
    maxY = maxY > 0 ? (maxY * 1.25) : 100.0;

    final currencyFormat = NumberFormat.compact();
    final monthFormat = DateFormat('MMM', AppStrings.isArabic ? 'ar' : 'en');

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
              AppStrings.isArabic
                  ? 'اتجاه الإيرادات الشهرية (المتوقع vs المحصل) لآخر 5 أشهر'
                  : 'Monthly Revenue Trend (Expected vs Collected)',
              style: AppTextStyles.headlineSmall(context).copyWith(
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            // Legend indicators
            Row(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 16, height: 3, color: Colors.orange),
                    const SizedBox(width: 4),
                    Text(
                      AppStrings.isArabic ? 'متوقع (Appointments)' : 'Expected (Appointments)',
                      style: AppTextStyles.caption(context).copyWith(
                        color: context.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 16, height: 3, color: context.primary),
                    const SizedBox(width: 4),
                    Text(
                      AppStrings.isArabic ? 'محصل فعلي (Invoices)' : 'Collected (Invoices)',
                      style: AppTextStyles.caption(context).copyWith(
                        color: context.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Clinics color legend
            Wrap(
              spacing: 12,
              runSpacing: 6,
              children: clinics.asMap().entries.map((entry) {
                final idx = entry.key;
                final clinic = entry.value;
                final color = colors[idx % colors.length];

                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      clinic.clinicName,
                      style: AppTextStyles.caption(context).copyWith(
                        color: context.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            SizedBox(
              height: 230,
              child: LineChart(
                LineChartData(
                  maxY: maxY,
                  minY: 0,
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final barIdx = spot.barIndex;
                          final isExpected = barIdx.isOdd;
                          final clinicIdx = barIdx ~/ 2;
                          if (clinicIdx >= clinics.length) return null;
                          final clinic = clinics[clinicIdx];
                          final labelType = isExpected
                              ? (AppStrings.isArabic ? 'متوقع' : 'Expected')
                              : (AppStrings.isArabic ? 'محصل' : 'Collected');
                          final color = isExpected ? Colors.orange : colors[clinicIdx % colors.length];

                          return LineTooltipItem(
                            '${clinic.clinicName} ($labelType): ${spot.y.toStringAsFixed(0)} ${AppStrings.egp}',
                            TextStyle(
                              color: color,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          );
                        }).toList();
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
                          final reversedIdx = (monthsCount - 1) - value.toInt();
                          if (reversedIdx >= 0 &&
                              reversedIdx < clinics.first.monthlyPerformance.length) {
                            final date = clinics.first.monthlyPerformance[reversedIdx].month;
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                monthFormat.format(date),
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
                  lineBarsData: clinics.asMap().entries.expand((entry) {
                    final idx = entry.key;
                    final clinic = entry.value;
                    final clinicColor = colors[idx % colors.length];

                    // 1. Collected line (Solid)
                    final collectedSpots = clinic.monthlyPerformance.asMap().entries.map((pEntry) {
                      final pIdx = pEntry.key;
                      final pValue = pEntry.value;
                      final x = (monthsCount - 1 - pIdx).toDouble();
                      return FlSpot(x, pValue.amount);
                    }).toList();

                    final collectedLine = LineChartBarData(
                      spots: collectedSpots,
                      isCurved: true,
                      color: clinicColor,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: true),
                    );

                    // 2. Expected line (Dashed / Orange tinted)
                    final expectedSpots = clinic.monthlyExpectedPerformance.asMap().entries.map((pEntry) {
                      final pIdx = pEntry.key;
                      final pValue = pEntry.value;
                      final x = (monthsCount - 1 - pIdx).toDouble();
                      return FlSpot(x, pValue.amount);
                    }).toList();

                    final expectedLine = LineChartBarData(
                      spots: expectedSpots,
                      isCurved: true,
                      color: Colors.orange,
                      dashArray: [6, 4],
                      barWidth: 2,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: true),
                    );

                    return [collectedLine, expectedLine];
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

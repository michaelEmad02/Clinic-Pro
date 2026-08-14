import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:clinic_pro/core/constants/app_constants.dart';
import 'package:clinic_pro/core/themes/app_colors.dart';
import 'package:clinic_pro/core/themes/app_text_styles.dart';
import 'package:clinic_pro/core/utils/responsive_helper.dart';
import 'package:clinic_pro/features/reports/domain/entities/reports_entities.dart';

class PrescriptionTrendChartWidget extends StatelessWidget {
  final List<MonthlyPrescriptionTrendEntity> trend;

  const PrescriptionTrendChartWidget({super.key, required this.trend});

  @override
  Widget build(BuildContext context) {
    if (trend.isEmpty) return const SizedBox.shrink();

    final maxRxCount = trend.fold<int>(0, (max, item) => item.count > max ? item.count : max);
    final maxY = maxRxCount > 0 ? (maxRxCount * 1.2).ceilToDouble() : 10.0;

    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusCard),
        border: Border.all(color: context.borderColor, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'اتجاه الروشتات الشهري',
                style: AppTextStyles.headlineSmall(context).copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
              Row(
                children: [
                  Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF1A6B8A), shape: BoxShape.circle)),
                  const SizedBox(width: 4),
                  Text('الروشتات', style: AppTextStyles.caption(context)),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spaceLg),
          SizedBox(
            height: ResponsiveHelper.isMobile(context) ? 180 : 260,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(color: context.borderColor.withOpacity(0.5), strokeWidth: 0.5),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (val, meta) => Text(
                        val.toInt().toString(),
                        style: AppTextStyles.caption(context).copyWith(fontSize: 10),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (val, meta) {
                        final idx = val.toInt();
                        if (idx >= 0 && idx < trend.length) {
                          final parts = trend[idx].month.split('-');
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              '${parts.last}/${parts.first.substring(2)}',
                              style: AppTextStyles.caption(context).copyWith(fontSize: 10),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minY: 0,
                maxY: maxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: trend.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.count.toDouble())).toList(),
                    isCurved: true,
                    color: const Color(0xFF1A6B8A),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFF1A6B8A).withOpacity(0.12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

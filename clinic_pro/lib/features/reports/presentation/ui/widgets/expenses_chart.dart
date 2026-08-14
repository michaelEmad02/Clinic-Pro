import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:clinic_pro/core/themes/app_colors.dart';
import 'package:clinic_pro/core/themes/app_text_styles.dart';
import 'package:clinic_pro/core/constants/app_constants.dart';
import 'package:clinic_pro/core/strings/app_strings.dart';

class ExpensesDonutChart extends StatelessWidget {
  final List<Map<String, dynamic>> categories;

  const ExpensesDonutChart({super.key, required this.categories});

  static const List<Color> chartColors = [
    Color(0xFF1A6B8A), // primary
    Color(0xFFF5A623), // warning
    Color(0xFF2ECC9A), // accent
    Color(0xFF9B59B6),
    Color(0xFFE84C4C), // danger
    Color(0xFF3498DB),
    Color(0xFF1ABC9C),
    Color(0xFFF39C12),
    Color(0xFF95A5A6),
    Color(0xFFE74C3C),
  ];

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();

    final totalAmount = categories.fold<double>(
      0.0,
      (sum, item) => sum + ((item['amount'] ?? 0.0) as num).toDouble(),
    );

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
          Text(
            AppStrings.isArabic ? 'تفاصيل المصروفات' : 'Expenses Breakdown',
            style: AppTextStyles.headlineSmall(context).copyWith(
              fontWeight: FontWeight.bold,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: AppConstants.spaceMd),
          SizedBox(
            height: 200,
            child: Stack(
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 60,
                    startDegreeOffset: -90,
                    sections: List.generate(categories.length, (index) {
                      final cat = categories[index];
                      final amount = ((cat['amount'] ?? 0.0) as num).toDouble();
                      final color = chartColors[index % chartColors.length];
                      return PieChartSectionData(
                        color: color,
                        value: amount,
                        title: '',
                        radius: 20,
                      );
                    }),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppStrings.isArabic ? 'الإجمالي' : 'Total',
                        style: AppTextStyles.caption(context).copyWith(
                          color: context.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${totalAmount.toStringAsFixed(0)} ${AppStrings.egp}',
                        style: AppTextStyles.headlineSmall(context).copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.spaceMd),
          Column(
            children: List.generate(categories.length, (index) {
              final cat = categories[index];
              final name = cat['category'] as String? ?? '';
              final amount = ((cat['amount'] ?? 0.0) as num).toDouble();
              final pct = ((cat['percentage'] ?? 0.0) as num).toDouble();
              final color = chartColors[index % chartColors.length];

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            name,
                            style: AppTextStyles.bodyMedium(context),
                          ),
                        ),
                        Text(
                          '${pct.toStringAsFixed(1)}%',
                          style: AppTextStyles.caption(context).copyWith(
                            color: context.textSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${amount.toStringAsFixed(0)} ${AppStrings.egp}',
                          style: AppTextStyles.bodyMedium(context).copyWith(
                            fontWeight: FontWeight.bold,
                            color: context.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: (pct / 100).clamp(0.0, 1.0),
                        backgroundColor: context.borderColor,
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                        minHeight: 4,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

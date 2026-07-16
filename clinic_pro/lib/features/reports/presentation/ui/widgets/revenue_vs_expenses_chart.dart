// ────────────────────────────────────────────────────────
// رسم بياني: الإيرادات مقابل المصروفات (محاكاة بـ Container)
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../manager/reports_state.dart';

class RevenueVsExpensesChart extends StatelessWidget {
  final List<WeeklyData> data;

  const RevenueVsExpensesChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final maxValue = data.fold<double>(
        0,
        (max, d) =>
            [max, d.revenue, d.expenses].reduce((a, b) => a > b ? a : b));

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
                  AppStrings.revenueVsExpenses,
                  style: AppTextStyles.headlineSmall(context).copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(Icons.more_vert, size: 18, color: context.textSecondary),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Stack(
                children: [
                  // خطوط Y
                  Positioned.fill(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _yAxisLine(context, '50k'),
                        _yAxisLine(context, '30k'),
                        _yAxisLine(context, '10k'),
                        Container(
                          width: double.infinity,
                          height: 0,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: context.textSecondary,
                                width: 1,
                              ),
                            ),
                          ),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text('0',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 10,
                                  color: context.textHint,
                                )),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // الأعمدة
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: data.map((week) {
                          final revenueHeight =
                              maxValue > 0 ? week.revenue / maxValue : 0.0;
                          final expensesHeight =
                              maxValue > 0 ? week.expenses / maxValue : 0.0;

                          return Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                SizedBox(
                                  height: 120,
                                  child: Center(
                                    child: SizedBox(
                                      width: 32,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Expanded(
                                            child: Container(
                                              height: (revenueHeight * 100)
                                                  .clamp(0, 120),
                                              decoration: BoxDecoration(
                                                color: context.primary,
                                                borderRadius:
                                                    const BorderRadius.vertical(
                                                  top: Radius.circular(4),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Container(
                                              height: (expensesHeight * 100)
                                                  .clamp(0, 120),
                                              decoration: BoxDecoration(
                                                color: context.dangerBg,
                                                borderRadius:
                                                    const BorderRadius.vertical(
                                                  top: Radius.circular(4),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  week.week,
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 10,
                                    color: context.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // وسيلة الإيضاح
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _LegendItem(color: context.primary, label: AppStrings.revenue),
                const SizedBox(width: 16),
                _LegendItem(
                    color: context.dangerBg, label: AppStrings.expenses),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _yAxisLine(BuildContext context, String label) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: context.outline, width: 0.5),
        ),
      ),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 10,
              color: context.textHint,
            )),
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
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: AppTextStyles.caption(context)
                .copyWith(color: context.textSecondary)),
      ],
    );
  }
}

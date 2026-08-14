import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:clinic_pro/core/themes/app_colors.dart';
import 'package:clinic_pro/core/themes/app_text_styles.dart';
import 'package:clinic_pro/core/constants/app_constants.dart';
import 'package:clinic_pro/core/strings/app_strings.dart';
import 'package:clinic_pro/core/utils/responsive_helper.dart';
import 'package:clinic_pro/features/reports/domain/entities/reports_entities.dart';

class DrugStatsSectionWidget extends StatefulWidget {
  final DrugStatsEntity stats;

  const DrugStatsSectionWidget({super.key, required this.stats});

  static const List<Color> colors = [
    Color(0xFF1A6B8A),
    Color(0xFF2ECC9A),
    Color(0xFFF5A623),
    Color(0xFF9B59B6),
    Color(0xFF3498DB),
    Color(0xFFE84C4C),
  ];

  @override
  State<DrugStatsSectionWidget> createState() => _DrugStatsSectionWidgetState();
}

class _DrugStatsSectionWidgetState extends State<DrugStatsSectionWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final top10 = widget.stats.topDrugs.take(10).toList();
    final visibleDrugs = _isExpanded ? top10 : top10.take(5).toList();
    final canExpand = top10.length > 5;
    final isWide = !ResponsiveHelper.isMobile(context);

    Widget buildCategoriesBreakdown() {
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
              AppStrings.isArabic ? 'توزيع الفئات الدوائية' : 'Drug Categories Breakdown',
              style: AppTextStyles.headlineSmall(context).copyWith(
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: AppConstants.spaceMd),
            SizedBox(
              height: isWide ? 220 : 180,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: isWide ? 65 : 50,
                  sections: List.generate(widget.stats.byCategory.length, (index) {
                    final item = widget.stats.byCategory[index];
                    return PieChartSectionData(
                      color: DrugStatsSectionWidget.colors[index % DrugStatsSectionWidget.colors.length],
                      value: item.count.toDouble(),
                      title: '${item.percentage.toStringAsFixed(0)}%',
                      radius: 24,
                      titleStyle: AppTextStyles.caption(context).copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: AppConstants.spaceMd),
            ...widget.stats.byCategory.asMap().entries.map((entry) {
              final index = entry.key;
              final cat = entry.value;
              final color = DrugStatsSectionWidget.colors[index % DrugStatsSectionWidget.colors.length];

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(cat.category, style: AppTextStyles.bodyMedium(context)),
                    ),
                    Text(
                      '${cat.count} ${AppStrings.isArabic ? 'وصفة' : 'prescriptions'}',
                      style: AppTextStyles.bodyMedium(context).copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      );
    }

    Widget buildTopDrugsList() {
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
                  AppStrings.isArabic
                      ? 'الأدوية الأكثر وصفاً بالعيادة'
                      : 'Top Prescribed Drugs',
                  style: AppTextStyles.headlineSmall(context).copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                  ),
                ),
                if (canExpand)
                  InkWell(
                    onTap: () => setState(() => _isExpanded = !_isExpanded),
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _isExpanded ? 'عرض أقل' : 'عرض الكل (${top10.length})',
                            style: AppTextStyles.caption(context).copyWith(
                              color: context.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Icon(
                            _isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                            color: context.primary,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppConstants.spaceMd),
            ...visibleDrugs.asMap().entries.map((entry) {
              final rank = entry.key + 1;
              final drug = entry.value;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: rank <= 3
                                ? context.primaryLightColor
                                : context.borderColor.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '$rank',
                              style: AppTextStyles.caption(context).copyWith(
                                fontWeight: FontWeight.bold,
                                color: rank <= 3 ? context.primary : context.textSecondary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            drug.name,
                            style: AppTextStyles.bodyMedium(context).copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          '${drug.count} (${drug.percentage.toStringAsFixed(1)}%)',
                          style: AppTextStyles.caption(context).copyWith(
                            color: context.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: (drug.percentage / 30).clamp(0.0, 1.0),
                        backgroundColor: context.borderColor,
                        valueColor: AlwaysStoppedAnimation<Color>(context.primary),
                        minHeight: 4,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      );
    }

    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: buildCategoriesBreakdown()),
          const SizedBox(width: AppConstants.spaceMd),
          Expanded(child: buildTopDrugsList()),
        ],
      );
    }

    return Column(
      children: [
        buildCategoriesBreakdown(),
        const SizedBox(height: AppConstants.spaceMd),
        buildTopDrugsList(),
      ],
    );
  }
}

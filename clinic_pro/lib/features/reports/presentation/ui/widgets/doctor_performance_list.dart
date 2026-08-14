// ────────────────────────────────────────────────────────
// أداء الأطباء — تصميم عصري جذاب مع رسم بياني وإحصائيات شاطة
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../manager/reports_state.dart';

class DoctorPerformanceList extends StatelessWidget {
  final List<DoctorPerformanceItem> doctors;

  const DoctorPerformanceList({super.key, required this.doctors});

  @override
  Widget build(BuildContext context) {
    if (doctors.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: context.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.outline),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.person_off_rounded, size: 48, color: context.textSecondary),
              const SizedBox(height: 12),
              Text(
                AppStrings.isArabic ? 'لا توجد بيانات أداء للأطباء حالياً' : 'No doctor performance data available',
                style: AppTextStyles.bodyMedium(context).copyWith(color: context.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    final currencyFormat = NumberFormat.currency(
      symbol: AppStrings.isArabic ? 'ج.م ' : 'EGP ',
      decimalDigits: 0,
    );

    final totalRevenue = doctors.fold<double>(0, (sum, d) => sum + d.revenue);
    final totalVisits = doctors.fold<int>(0, (sum, d) => sum + d.visitCount);
    final maxRevenue = doctors.fold<double>(0, (max, d) => d.revenue > max ? d.revenue : max);

    // Sort doctors by revenue descending for ranking
    final sortedDoctors = List<DoctorPerformanceItem>.from(doctors)
      ..sort((a, b) => b.revenue.compareTo(a.revenue));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. KPI Cards Header
        Row(
          children: [
            Expanded(
              child: _KpiCard(
                title: AppStrings.isArabic ? 'إجمالي الأطباء' : 'Total Doctors',
                value: '${doctors.length}',
                icon: Icons.badge_rounded,
                color: context.primary,
                bgColor: context.primaryLightColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _KpiCard(
                title: AppStrings.isArabic ? 'إجمالي الزيارات' : 'Total Visits',
                value: '$totalVisits',
                icon: Icons.calendar_month_rounded,
                color: context.successText,
                bgColor: context.successBg,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _KpiCard(
                title: AppStrings.isArabic ? 'إجمالي الإيرادات' : 'Total Revenue',
                value: currencyFormat.format(totalRevenue),
                icon: Icons.payments_rounded,
                color: const Color(0xFF0284C7),
                bgColor: const Color(0xFFE0F2FE),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // 2. Performance Comparison Chart Card
        if (doctors.length >= 2) ...[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: context.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.outline),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x08000000),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: context.primaryLightColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.bar_chart_rounded, color: context.primary, size: 20),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          AppStrings.isArabic ? 'مقارنة إيرادات الأطباء' : 'Doctor Revenue Comparison',
                          style: AppTextStyles.headlineSmall(context).copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      AppStrings.isArabic ? 'أعلى أداء' : 'Top Performing',
                      style: AppTextStyles.caption(context).copyWith(
                        color: context.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 200,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: (maxRevenue * 1.25).clamp(100.0, double.infinity),
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            final doc = sortedDoctors[group.x.toInt()];
                            return BarTooltipItem(
                              '${doc.doctorName}\n',
                              TextStyle(
                                color: context.surface,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                              children: [
                                TextSpan(
                                  text: currencyFormat.format(doc.revenue),
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
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index < 0 || index >= sortedDoctors.length) {
                                return const SizedBox.shrink();
                              }
                              final name = sortedDoctors[index].doctorName;
                              final shortName = name.startsWith('د.') || name.startsWith('د/')
                                  ? name.substring(2).trim()
                                  : name;
                              final displayName = shortName.split(' ').first;

                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  displayName,
                                  style: AppTextStyles.caption(context).copyWith(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      gridData: const FlGridData(show: false),
                      barGroups: sortedDoctors.asMap().entries.map((entry) {
                        final index = entry.key;
                        final doc = entry.value;
                        final isTop = index == 0;

                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: doc.revenue == 0 ? maxRevenue * 0.03 : doc.revenue,
                              gradient: LinearGradient(
                                colors: isTop
                                    ? [const Color(0xFF6366F1), context.primary]
                                    : [context.primary.withOpacity(0.6), context.primary.withOpacity(0.3)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              width: 18,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
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
          const SizedBox(height: 20),
        ],

        // 3. Detailed Doctor List Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: context.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.outline),
            boxShadow: const [
              BoxShadow(
                color: Color(0x08000000),
                blurRadius: 6,
                offset: Offset(0, 2),
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
                    AppStrings.doctorPerformance,
                    style: AppTextStyles.headlineSmall(context).copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: context.primaryLightColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${sortedDoctors.length} ${AppStrings.isArabic ? 'أطباء' : 'Doctors'}',
                      style: AppTextStyles.caption(context).copyWith(
                        color: context.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sortedDoctors.length,
                separatorBuilder: (_, __) => Divider(height: 24, color: context.outline.withOpacity(0.5)),
                itemBuilder: (context, index) {
                  final doctor = sortedDoctors[index];
                  return _DoctorCardRow(
                    doctor: doctor,
                    rank: index + 1,
                    maxRevenue: maxRevenue,
                    currencyFormat: currencyFormat,
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Color bgColor;

  const _KpiCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: AppTextStyles.headlineSmall(context).copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: AppTextStyles.caption(context).copyWith(
              color: context.textSecondary,
              fontSize: 11,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _DoctorCardRow extends StatelessWidget {
  final DoctorPerformanceItem doctor;
  final int rank;
  final double maxRevenue;
  final NumberFormat currencyFormat;

  const _DoctorCardRow({
    required this.doctor,
    required this.rank,
    required this.maxRevenue,
    required this.currencyFormat,
  });

  @override
  Widget build(BuildContext context) {
    final revenuePercentage = maxRevenue > 0 ? (doctor.revenue / maxRevenue).clamp(0.0, 1.0) : 0.0;

    Color rankColor;
    IconData? rankIcon;
    if (rank == 1) {
      rankColor = const Color(0xFFEAB308); // Gold
      rankIcon = Icons.workspace_premium;
    } else if (rank == 2) {
      rankColor = const Color(0xFF94A3B8); // Silver
      rankIcon = Icons.military_tech;
    } else if (rank == 3) {
      rankColor = const Color(0xFFD97706); // Bronze
      rankIcon = Icons.military_tech_outlined;
    } else {
      rankColor = context.textSecondary;
    }

    return Column(
      children: [
        Row(
          children: [
            // Rank Badge
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: rank <= 3 ? rankColor.withOpacity(0.15) : context.borderColor.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: rankIcon != null
                    ? Icon(rankIcon, color: rankColor, size: 18)
                    : Text(
                        '#$rank',
                        style: AppTextStyles.caption(context).copyWith(
                          fontWeight: FontWeight.bold,
                          color: rankColor,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),

            // Avatar
            CircleAvatar(
              radius: 20,
              backgroundColor: context.primaryLightColor,
              backgroundImage: doctor.avatarUrl != null && doctor.avatarUrl!.isNotEmpty
                  ? NetworkImage(doctor.avatarUrl!)
                  : null,
              child: doctor.avatarUrl == null || doctor.avatarUrl!.isEmpty
                  ? Text(
                      doctor.doctorName.isNotEmpty ? doctor.doctorName.substring(0, 1) : 'د',
                      style: TextStyle(
                        color: context.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),

            // Doctor Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctor.doctorName,
                    style: AppTextStyles.bodyMedium(context).copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.people_alt_rounded, size: 13, color: context.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        '${doctor.visitCount} ${AppStrings.isArabic ? 'زيارة' : 'visits'}',
                        style: AppTextStyles.caption(context).copyWith(
                          color: context.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.pie_chart_rounded, size: 13, color: context.primary),
                      const SizedBox(width: 2),
                      Text(
                        '${doctor.rating}% ${AppStrings.isArabic ? 'من الإيراد' : 'share'}',
                        style: AppTextStyles.caption(context).copyWith(
                          color: context.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Revenue & Trend Column
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  currencyFormat.format(doctor.revenue),
                  style: AppTextStyles.headlineSmall(context).copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: context.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: doctor.trend == 'up'
                        ? context.successBg
                        : doctor.trend == 'down'
                            ? context.dangerBg
                            : context.borderColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        doctor.trend == 'up'
                            ? Icons.trending_up_rounded
                            : doctor.trend == 'down'
                                ? Icons.trending_down_rounded
                                : Icons.trending_flat_rounded,
                        size: 13,
                        color: doctor.trend == 'up'
                            ? context.successText
                            : doctor.trend == 'down'
                                ? context.dangerText
                                : context.textSecondary,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        doctor.trend == 'up'
                            ? (AppStrings.isArabic ? 'صاعد' : 'Up')
                            : doctor.trend == 'down'
                                ? (AppStrings.isArabic ? 'هابط' : 'Down')
                                : (AppStrings.isArabic ? 'مستقر' : 'Stable'),
                        style: AppTextStyles.caption(context).copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: doctor.trend == 'up'
                              ? context.successText
                              : doctor.trend == 'down'
                                  ? context.dangerText
                                  : context.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Progress Bar relative to max revenue
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: revenuePercentage,
            backgroundColor: context.borderColor.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(
              rank == 1 ? const Color(0xFF6366F1) : context.primary,
            ),
            minHeight: 5,
          ),
        ),
      ],
    );
  }
}

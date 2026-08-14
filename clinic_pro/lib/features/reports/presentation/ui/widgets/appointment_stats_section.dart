import 'package:flutter/material.dart';
import 'package:clinic_pro/core/themes/app_colors.dart';
import 'package:clinic_pro/core/themes/app_text_styles.dart';
import 'package:clinic_pro/core/constants/app_constants.dart';
import 'package:clinic_pro/core/strings/app_strings.dart';
import 'package:clinic_pro/features/reports/domain/entities/reports_entities.dart';

class AppointmentStatsSectionWidget extends StatelessWidget {
  final AppointmentStatsEntity stats;

  const AppointmentStatsSectionWidget({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final rateColor = stats.attendanceRate >= 70
        ? context.successText
        : (stats.attendanceRate >= 50 ? context.warningText : context.dangerText);

    return Column(
      children: [
        // Summary Cards Row 1
        Row(
          children: [
            Expanded(
              child: _StatMiniCard(
                label: AppStrings.isArabic ? 'إجمالي المواعيد' : 'Total',
                value: '${stats.totalAppointments}',
                color: context.primary,
                icon: Icons.event,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatMiniCard(
                label: AppStrings.isArabic ? 'المكتملة' : 'Completed',
                value: '${stats.completedAppointments}',
                color: context.successText,
                icon: Icons.check_circle_outline,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatMiniCard(
                label: AppStrings.isArabic ? 'الملغاة' : 'Cancelled',
                value: '${stats.cancelledAppointments}',
                color: context.dangerText,
                icon: Icons.cancel_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Summary Cards Row 2 (Wait Time, Urgent, No-Show)
        Row(
          children: [
            Expanded(
              child: _StatMiniCard(
                label: AppStrings.isArabic ? 'متوسط الانتظار' : 'Avg Wait',
                value: '${stats.avgWaitTimeMinutes} ${AppStrings.isArabic ? 'د' : 'm'}',
                color: context.warningText,
                icon: Icons.access_time_rounded,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatMiniCard(
                label: AppStrings.isArabic ? 'حالات طارئة' : 'Urgent',
                value: '${stats.urgentCount} (${stats.urgentPercentage.toStringAsFixed(0)}%)',
                color: Colors.orange.shade700,
                icon: Icons.warning_amber_rounded,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatMiniCard(
                label: AppStrings.isArabic ? 'عدم الحضور' : 'No-Show',
                value: '${stats.noShowCount} (${stats.noShowRate.toStringAsFixed(0)}%)',
                color: Colors.purple,
                icon: Icons.person_off_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spaceMd),

        // Attendance Rate Card
        Container(
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
                    AppStrings.isArabic ? 'معدل حضور المرضى' : 'Attendance Rate',
                    style: AppTextStyles.headlineSmall(context).copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.textPrimary,
                    ),
                  ),
                  Text(
                    '${stats.attendanceRate.toStringAsFixed(0)}%',
                    style: AppTextStyles.headlineMedium(context).copyWith(
                      fontWeight: FontWeight.bold,
                      color: rateColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spaceSm),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (stats.attendanceRate / 100).clamp(0.0, 1.0),
                  backgroundColor: context.borderColor,
                  valueColor: AlwaysStoppedAnimation<Color>(rateColor),
                  minHeight: 8,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppConstants.spaceMd),

        // Status Breakdown Section
        if (stats.statusBreakdown.isNotEmpty) ...[
          Container(
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
                  AppStrings.isArabic ? 'توزيع حالات المواعيد' : 'Status Breakdown',
                  style: AppTextStyles.headlineSmall(context).copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: AppConstants.spaceMd),
                _StatusRow(
                  label: AppStrings.isArabic ? 'مجدول' : 'Scheduled',
                  count: stats.statusBreakdown['scheduled'] ?? 0,
                  total: stats.totalAppointments,
                  color: context.primary,
                ),
                _StatusRow(
                  label: AppStrings.isArabic ? 'مؤكد / بالانتظار' : 'Confirmed / Waiting',
                  count: stats.statusBreakdown['confirmed'] ?? 0,
                  total: stats.totalAppointments,
                  color: context.warningText,
                ),
                _StatusRow(
                  label: AppStrings.isArabic ? 'جاري الكشف' : 'In Progress',
                  count: stats.statusBreakdown['in_progress'] ?? 0,
                  total: stats.totalAppointments,
                  color: Colors.blue.shade700,
                ),
                _StatusRow(
                  label: AppStrings.isArabic ? 'مكتمل' : 'Completed',
                  count: stats.statusBreakdown['done'] ?? 0,
                  total: stats.totalAppointments,
                  color: context.successText,
                ),
                _StatusRow(
                  label: AppStrings.isArabic ? 'ملغى' : 'Cancelled',
                  count: stats.statusBreakdown['cancelled'] ?? 0,
                  total: stats.totalAppointments,
                  color: context.dangerText,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.spaceMd),
        ],

        // Busiest Days Section
        if(stats.peakDays.isNotEmpty)
        Container(
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
                AppStrings.isArabic ? 'أكثر الأيام ازدحاماً' : 'Busiest Days',
                style: AppTextStyles.headlineSmall(context).copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
              const SizedBox(height: AppConstants.spaceMd),
              ...stats.peakDays.map((day) {
                final maxCount = stats.peakDays
                    .fold<int>(1, (max, d) => d.count > max ? d.count : max);
                final pct = day.count / maxCount;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            day.dayName,
                            style: AppTextStyles.bodyMedium(context),
                          ),
                          Text(
                            '${day.count} ${AppStrings.isArabic ? 'موعد' : 'appts'}',
                            style: AppTextStyles.bodyMedium(context).copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: pct.clamp(0.0, 1.0),
                          backgroundColor: context.borderColor,
                          valueColor: AlwaysStoppedAnimation<Color>(context.primary),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: AppConstants.spaceMd),

        // Visit Types Breakdown
        if(stats.byType.isNotEmpty)
        Container(
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
                AppStrings.isArabic ? 'أنواع الزيارات' : 'Visit Types',
                style: AppTextStyles.headlineSmall(context).copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
              const SizedBox(height: AppConstants.spaceMd),
              ...stats.byType.map((type) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Icon(Icons.circle, size: 8, color: context.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          type.name,
                          style: AppTextStyles.bodyMedium(context),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: context.primaryLightColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${type.count}',
                          style: AppTextStyles.caption(context).copyWith(
                            fontWeight: FontWeight.bold,
                            color: context.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatMiniCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _StatMiniCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceSm),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusCard),
        border: Border.all(color: context.borderColor, width: 0.5),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.headlineMedium(context).copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.caption(context).copyWith(
              color: context.textSecondary,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final String label;
  final int count;
  final int total;
  final Color color;

  const _StatusRow({
    required this.label,
    required this.count,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? (count / total) : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.circle, size: 8, color: color),
                  const SizedBox(width: 8),
                  Text(label, style: AppTextStyles.bodyMedium(context)),
                ],
              ),
              Text(
                '$count (${(pct * 100).toStringAsFixed(0)}%)',
                style: AppTextStyles.bodyMedium(context).copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: pct.clamp(0.0, 1.0),
              backgroundColor: context.borderColor,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}

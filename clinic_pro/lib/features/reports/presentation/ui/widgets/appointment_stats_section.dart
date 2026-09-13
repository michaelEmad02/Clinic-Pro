import 'package:flutter/material.dart';
import 'package:clinic_pro/core/themes/app_colors.dart';
import 'package:clinic_pro/core/themes/app_text_styles.dart';
import 'package:clinic_pro/core/strings/app_strings.dart';
import 'package:clinic_pro/core/utils/responsive_helper.dart';
import 'package:clinic_pro/features/reports/domain/entities/reports_entities.dart';

class AppointmentStatsSectionWidget extends StatelessWidget {
  final AppointmentStatsEntity stats;

  const AppointmentStatsSectionWidget({super.key, required this.stats});

  String _formatDayName(String rawDay) {
    if (!AppStrings.isArabic) return rawDay;
    final clean = rawDay.trim().toLowerCase();
    switch (clean) {
      case 'saturday':
        return 'السبت';
      case 'sunday':
        return 'الأحد';
      case 'monday':
        return 'الإثنين';
      case 'tuesday':
        return 'الثلاثاء';
      case 'wednesday':
        return 'الأربعاء';
      case 'thursday':
        return 'الخميس';
      case 'friday':
        return 'الجمعة';
      default:
        return rawDay;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final isTablet = ResponsiveHelper.isTablet(context);

    final rateColor = stats.attendanceRate >= 80
        ? context.successText
        : (stats.attendanceRate >= 50 ? context.warningText : context.dangerText);

    final kpiCards = [
      _StatMiniCard(
        label: AppStrings.isArabic ? 'إجمالي المواعيد' : 'Total Appointments',
        value: '${stats.totalAppointments}',
        color: context.primary,
        icon: Icons.calendar_month_rounded,
      ),
      _StatMiniCard(
        label: AppStrings.isArabic ? 'المكتملة' : 'Completed',
        value: '${stats.completedAppointments}',
        color: context.successText,
        icon: Icons.check_circle_rounded,
      ),
      _StatMiniCard(
        label: AppStrings.isArabic ? 'الملغاة' : 'Cancelled',
        value: '${stats.cancelledAppointments}',
        color: context.dangerText,
        icon: Icons.cancel_rounded,
      ),
      _StatMiniCard(
        label: AppStrings.isArabic ? 'متوسط الانتظار' : 'Avg Wait',
        value: '${stats.avgWaitTimeMinutes} ${AppStrings.isArabic ? 'دقيقة' : 'm'}',
        color: const Color(0xFFD97706),
        icon: Icons.timer_outlined,
      ),
      _StatMiniCard(
        label: AppStrings.isArabic ? 'حالات طارئة' : 'Urgent',
        value: '${stats.urgentCount}',
        percentage: '${stats.urgentPercentage.toStringAsFixed(0)}%',
        color: Colors.deepOrange,
        icon: Icons.warning_amber_rounded,
      ),
      _StatMiniCard(
        label: AppStrings.isArabic ? 'عدم الحضور' : 'No-Show',
        value: '${stats.noShowCount}',
        percentage: '${stats.noShowRate.toStringAsFixed(0)}%',
        color: Colors.purple,
        icon: Icons.person_off_rounded,
      ),
    ];

    final int kpiCrossAxisCount = isDesktop ? 6 : (isTablet ? 3 : 2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. KPI Cards Grid with fixed mainAxisExtent to eliminate any overflow
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: kpiCrossAxisCount,
            crossAxisSpacing: isDesktop ? 12 : 8,
            mainAxisSpacing: isDesktop ? 12 : 8,
            mainAxisExtent: isDesktop ? 128 : (isTablet ? 120 : 112),
          ),
          itemCount: kpiCards.length,
          itemBuilder: (context, index) => kpiCards[index],
        ),
        const SizedBox(height: 16),

        // 2. Attendance Rate Card
        _buildAttendanceCard(context, rateColor, isDesktop),
        const SizedBox(height: 16),

        // 3. Middle Section: Status Breakdown + Peak Days (Side-by-side on desktop)
        if (isDesktop) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (stats.statusBreakdown.isNotEmpty)
                Expanded(
                  flex: 1,
                  child: _buildStatusBreakdown(context, isDesktop),
                ),
              if (stats.statusBreakdown.isNotEmpty && stats.peakDays.isNotEmpty)
                const SizedBox(width: 16),
              if (stats.peakDays.isNotEmpty)
                Expanded(
                  flex: 1,
                  child: _buildPeakDays(context, isDesktop),
                ),
            ],
          ),
          const SizedBox(height: 16),
        ] else ...[
          if (stats.statusBreakdown.isNotEmpty) ...[
            _buildStatusBreakdown(context, isDesktop),
            const SizedBox(height: 16),
          ],
          if (stats.peakDays.isNotEmpty) ...[
            _buildPeakDays(context, isDesktop),
            const SizedBox(height: 16),
          ],
        ],

        // 4. Visit Types Breakdown
        if (stats.byType.isNotEmpty) ...[
          _buildVisitTypes(context, isDesktop),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildAttendanceCard(BuildContext context, Color rateColor, bool isDesktop) {
    final rate = stats.attendanceRate;
    final rateBadgeText = rate >= 85
        ? (AppStrings.isArabic ? 'ممتاز' : 'Excellent')
        : (rate >= 70
            ? (AppStrings.isArabic ? 'جيد جداً' : 'Very Good')
            : (rate >= 50
                ? (AppStrings.isArabic ? 'متوسط' : 'Moderate')
                : (AppStrings.isArabic ? 'منخفض' : 'Low')));

    return Container(
      padding: EdgeInsets.all(isDesktop ? 20 : 16),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor, width: 0.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
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
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: rateColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.how_to_reg_rounded, color: rateColor, size: isDesktop ? 22 : 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.isArabic ? 'معدل حضور المرضى' : 'Attendance Rate',
                            style: AppTextStyles.headlineSmall(context).copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: isDesktop ? 16.5 : 15,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            AppStrings.isArabic
                                ? 'نسبة الالتزام بالمواعيد والحضور في الوقت المحدد'
                                : 'Patient attendance and appointment adherence',
                            style: AppTextStyles.caption(context).copyWith(
                              color: context.textSecondary,
                              fontSize: isDesktop ? 12.5 : 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 10 : 8,
                      vertical: isDesktop ? 4 : 2,
                    ),
                    decoration: BoxDecoration(
                      color: rateColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      rateBadgeText,
                      style: AppTextStyles.caption(context).copyWith(
                        color: rateColor,
                        fontWeight: FontWeight.bold,
                        fontSize: isDesktop ? 12 : 10.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${stats.attendanceRate.toStringAsFixed(0)}%',
                    style: AppTextStyles.headlineMedium(context).copyWith(
                      fontWeight: FontWeight.bold,
                      color: rateColor,
                      fontSize: isDesktop ? 26 : 22,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (stats.attendanceRate / 100).clamp(0.0, 1.0),
              backgroundColor: context.borderColor.withOpacity(0.4),
              valueColor: AlwaysStoppedAnimation<Color>(rateColor),
              minHeight: isDesktop ? 10 : 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBreakdown(BuildContext context, bool isDesktop) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 20 : 16),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor, width: 0.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: context.primaryLightColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.pie_chart_outline_rounded, color: context.primary, size: isDesktop ? 20 : 18),
              ),
              const SizedBox(width: 10),
              Text(
                AppStrings.isArabic ? 'توزيع حالات المواعيد' : 'Status Breakdown',
                style: AppTextStyles.headlineSmall(context).copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: isDesktop ? 16.5 : 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _StatusRow(
            label: AppStrings.isArabic ? 'مجدول' : 'Scheduled',
            count: stats.statusBreakdown['scheduled'] ?? 0,
            total: stats.totalAppointments,
            color: context.primary,
            isDesktop: isDesktop,
          ),
          _StatusRow(
            label: AppStrings.isArabic ? 'مؤكد / بالانتظار' : 'Confirmed / Waiting',
            count: stats.statusBreakdown['confirmed'] ?? 0,
            total: stats.totalAppointments,
            color: context.warningText,
            isDesktop: isDesktop,
          ),
          _StatusRow(
            label: AppStrings.isArabic ? 'جاري الكشف' : 'In Progress',
            count: stats.statusBreakdown['in_progress'] ?? 0,
            total: stats.totalAppointments,
            color: Colors.blue.shade700,
            isDesktop: isDesktop,
          ),
          _StatusRow(
            label: AppStrings.isArabic ? 'مكتمل' : 'Completed',
            count: stats.statusBreakdown['done'] ?? 0,
            total: stats.totalAppointments,
            color: context.successText,
            isDesktop: isDesktop,
          ),
          _StatusRow(
            label: AppStrings.isArabic ? 'ملغى' : 'Cancelled',
            count: stats.statusBreakdown['cancelled'] ?? 0,
            total: stats.totalAppointments,
            color: context.dangerText,
            isDesktop: isDesktop,
          ),
        ],
      ),
    );
  }

  Widget _buildPeakDays(BuildContext context, bool isDesktop) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 20 : 16),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor, width: 0.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: context.primaryLightColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.event_available_rounded, color: context.primary, size: isDesktop ? 20 : 18),
              ),
              const SizedBox(width: 10),
              Text(
                AppStrings.isArabic ? 'أكثر الأيام ازدحاماً' : 'Busiest Days',
                style: AppTextStyles.headlineSmall(context).copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: isDesktop ? 16.5 : 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...stats.peakDays.map((day) {
            final maxCount = stats.peakDays
                .fold<int>(1, (max, d) => d.count > max ? d.count : max);
            final pct = maxCount > 0 ? (day.count / maxCount) : 0.0;
            final translatedDay = _formatDayName(day.dayName);

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        translatedDay,
                        style: AppTextStyles.bodyMedium(context).copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: isDesktop ? 14 : 13,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isDesktop ? 10 : 8,
                          vertical: isDesktop ? 3 : 2,
                        ),
                        decoration: BoxDecoration(
                          color: context.primaryLightColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${day.count} ${AppStrings.isArabic ? 'موعد' : 'appts'}',
                          style: AppTextStyles.caption(context).copyWith(
                            fontWeight: FontWeight.bold,
                            color: context.primary,
                            fontSize: isDesktop ? 12.5 : 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pct.clamp(0.0, 1.0),
                      backgroundColor: context.borderColor.withOpacity(0.4),
                      valueColor: AlwaysStoppedAnimation<Color>(context.primary),
                      minHeight: isDesktop ? 8 : 6,
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

  Widget _buildVisitTypes(BuildContext context, bool isDesktop) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 20 : 16),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor, width: 0.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: context.primaryLightColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.medical_services_outlined, color: context.primary, size: isDesktop ? 20 : 18),
              ),
              const SizedBox(width: 10),
              Text(
                AppStrings.isArabic ? 'أنواع الزيارات' : 'Visit Types',
                style: AppTextStyles.headlineSmall(context).copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: isDesktop ? 16.5 : 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...stats.byType.map((type) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Icon(Icons.circle, size: 8, color: context.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      type.name,
                      style: AppTextStyles.bodyMedium(context).copyWith(
                        fontSize: isDesktop ? 14 : 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 12 : 10,
                      vertical: isDesktop ? 4 : 3,
                    ),
                    decoration: BoxDecoration(
                      color: context.primaryLightColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${type.count}',
                      style: AppTextStyles.caption(context).copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.primary,
                        fontSize: isDesktop ? 13 : 11.5,
                      ),
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
}

class _StatMiniCard extends StatelessWidget {
  final String label;
  final String value;
  final String? percentage;
  final Color color;
  final IconData icon;

  const _StatMiniCard({
    required this.label,
    required this.value,
    this.percentage,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 8 : 6,
        vertical: isDesktop ? 8 : 6,
      ),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.borderColor, width: 0.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: isDesktop ? 20 : 18),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: AppTextStyles.headlineSmall(context).copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: isDesktop ? 18 : 16,
                  ),
                ),
                if (percentage != null) ...[
                  const SizedBox(width: 4),
                  Text(
                    '($percentage)',
                    style: AppTextStyles.caption(context).copyWith(
                      fontWeight: FontWeight.w600,
                      color: color.withOpacity(0.8),
                      fontSize: isDesktop ? 11.5 : 10,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: AppTextStyles.caption(context).copyWith(
                color: context.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: isDesktop ? 12 : 11,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
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
  final bool isDesktop;

  const _StatusRow({
    required this.label,
    required this.count,
    required this.total,
    required this.color,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? (count / total) : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    label,
                    style: AppTextStyles.bodyMedium(context).copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: isDesktop ? 14 : 13,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 10 : 8,
                  vertical: isDesktop ? 3 : 2,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$count (${(pct * 100).toStringAsFixed(0)}%)',
                  style: AppTextStyles.caption(context).copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: isDesktop ? 12.5 : 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct.clamp(0.0, 1.0),
              backgroundColor: context.borderColor.withOpacity(0.4),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: isDesktop ? 8 : 6,
            ),
          ),
        ],
      ),
    );
  }
}

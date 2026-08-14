import 'package:flutter/material.dart';
import 'package:clinic_pro/core/themes/app_colors.dart';
import 'package:clinic_pro/core/themes/app_text_styles.dart';
import 'package:clinic_pro/core/constants/app_constants.dart';
import 'package:clinic_pro/core/strings/app_strings.dart';
import 'package:clinic_pro/features/reports/domain/entities/reports_entities.dart';

class PatientStatsSectionWidget extends StatelessWidget {
  final PatientStatsEntity stats;

  const PatientStatsSectionWidget({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Summary Row 1: Key Numbers
        Row(
          children: [
            Expanded(
              child: _PatientStatCard(
                label: AppStrings.isArabic ? 'إجمالي المرضى' : 'Total Patients',
                value: '${stats.totalPatients}',
                color: context.primary,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _PatientStatCard(
                label: AppStrings.isArabic ? 'مرضى جدد' : 'New Patients',
                value: '${stats.newPatients}',
                color: context.successText,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _PatientStatCard(
                label: AppStrings.isArabic ? 'معدل العودة' : 'Return Rate',
                value: '${stats.returnRate.toStringAsFixed(0)}%',
                color: context.warningText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Summary Row 2: Advanced Patient Metrics (Avg Visits & Avg Revenue)
        Row(
          children: [
            Expanded(
              child: _PatientStatCard(
                label: AppStrings.isArabic ? 'متوسط الزيارات / مريض' : 'Avg Visits/Patient',
                value: '${stats.avgVisitsPerPatient.toStringAsFixed(1)} ${AppStrings.isArabic ? 'زيارة' : 'vis'}',
                color: Colors.deepOrange,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _PatientStatCard(
                label: AppStrings.isArabic ? 'متوسط إنفاق المريض' : 'Avg Revenue/Patient',
                value: '${stats.avgRevenuePerPatient.toStringAsFixed(0)} ${AppStrings.isArabic ? 'ج.م' : 'EGP'}',
                color: Colors.teal,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spaceMd),

        // New vs Returning Patient Ratio Card
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
                    AppStrings.isArabic
                        ? 'مقارنة المرضى الجدد والمنتظمين'
                        : 'New vs. Returning Patients',
                    style: AppTextStyles.headlineSmall(context).copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.textPrimary,
                    ),
                  ),
                  Icon(Icons.pie_chart_outline_rounded,
                      size: 20, color: context.primary),
                ],
              ),
              const SizedBox(height: AppConstants.spaceMd),
              Row(
                children: [
                  Expanded(
                    child: _GenderBar(
                      label: AppStrings.isArabic ? 'جدد 🆕' : 'New 🆕',
                      count: stats.newPatients,
                      total: stats.totalPatients,
                      color: context.successText,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _GenderBar(
                      label: AppStrings.isArabic ? 'منتظمون 🔄' : 'Returning 🔄',
                      count: stats.returningPatients,
                      total: stats.totalPatients,
                      color: context.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppConstants.spaceMd),

        // Gender Distribution Card
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
                AppStrings.isArabic ? 'توزيع الجنس' : 'Gender Distribution',
                style: AppTextStyles.headlineSmall(context).copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
              const SizedBox(height: AppConstants.spaceMd),
              Row(
                children: [
                  Expanded(
                    child: _GenderBar(
                      label: AppStrings.isArabic ? 'ذكور' : 'Male',
                      count: stats.byGender['male'] ?? 0,
                      total: stats.totalPatients,
                      color: context.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _GenderBar(
                      label: AppStrings.isArabic ? 'إناث' : 'Female',
                      count: stats.byGender['female'] ?? 0,
                      total: stats.totalPatients,
                      color: Colors.pink,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppConstants.spaceMd),

        // Age Groups Card
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
                AppStrings.isArabic ? 'الفئات العمرية' : 'Age Groups',
                style: AppTextStyles.headlineSmall(context).copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
              const SizedBox(height: AppConstants.spaceMd),
              ...stats.byAgeGroup.entries.map((entry) {
                final pct = (entry.value / stats.totalPatients * 100);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${entry.key} ${AppStrings.isArabic ? 'سنة' : 'yrs'}',
                              style: AppTextStyles.bodyMedium(context)),
                          Text('${entry.value} (${pct.toStringAsFixed(0)}%)',
                              style: AppTextStyles.bodyMedium(context)
                                  .copyWith(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: (pct / 100).clamp(0.0, 1.0),
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

        // Inactive Patients List Card
        if (stats.inactivePatients.isNotEmpty)
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
                  children: [
                    Text(
                      AppStrings.isArabic
                          ? 'مرضى لم يزوروا العيادة مؤخراً'
                          : 'Inactive Patients',
                      style: AppTextStyles.headlineSmall(context).copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: context.warningBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        AppStrings.isArabic ? 'يحتاج تذكير' : 'Needs Reminder',
                        style: AppTextStyles.caption(context).copyWith(
                          color: context.warningText,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spaceMd),
                ...stats.inactivePatients.map((p) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: context.primaryLightColor,
                      child: Icon(Icons.person_outline, color: context.primary),
                    ),
                    title: Text(p.name, style: AppTextStyles.bodyMedium(context)),
                    subtitle: Text(
                      '${AppStrings.isArabic ? 'آخر زيارة:' : 'Last visit:'} ${p.lastVisit}',
                      style: AppTextStyles.caption(context),
                    ),
                    trailing: Text(
                      '${p.daysSinceLastVisit} ${AppStrings.isArabic ? 'يوم' : 'days'}',
                      style: AppTextStyles.caption(context).copyWith(
                        color: context.dangerText,
                        fontWeight: FontWeight.bold,
                      ),
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

class _PatientStatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _PatientStatCard({
    required this.label,
    required this.value,
    required this.color,
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

class _GenderBar extends StatelessWidget {
  final String label;
  final int count;
  final int total;
  final Color color;

  const _GenderBar({
    required this.label,
    required this.count,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? (count / total * 100) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTextStyles.bodyMedium(context)),
            Text('${pct.toStringAsFixed(0)}%',
                style: AppTextStyles.bodyMedium(context)
                    .copyWith(fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (pct / 100).clamp(0.0, 1.0),
            backgroundColor: context.borderColor,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}

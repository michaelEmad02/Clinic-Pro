import 'package:flutter/material.dart';
import 'package:clinic_pro/core/strings/app_strings.dart';
import 'package:clinic_pro/core/themes/app_colors.dart';
import 'package:clinic_pro/core/themes/app_text_styles.dart';
import 'package:clinic_pro/features/reports/domain/entities/clinic_report_entity.dart';

class ClinicLeaderboardTable extends StatelessWidget {
  final List<ClinicComparisonItem> clinics;

  const ClinicLeaderboardTable({super.key, required this.clinics});

  @override
  Widget build(BuildContext context) {
    if (clinics.isEmpty) return const SizedBox.shrink();

    final medals = ['🥇', '🥈', '🥉'];

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
            Row(
              children: [
                Icon(Icons.emoji_events_rounded, color: Colors.amber[700], size: 22),
                const SizedBox(width: 8),
                Text(
                  AppStrings.isArabic ? 'ترتيب وتصنيف الفروع' : 'Clinic Leaderboard',
                  style: AppTextStyles.headlineSmall(context).copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 18,
                headingRowHeight: 40,
                dataRowMinHeight: 44,
                dataRowMaxHeight: 48,
                columns: [
                  DataColumn(label: Text(AppStrings.isArabic ? 'الترتيب' : 'Rank')),
                  DataColumn(label: Text(AppStrings.isArabic ? 'العيادة' : 'Clinic')),
                  DataColumn(label: Text(AppStrings.isArabic ? 'المتوقع' : 'Expected')),
                  DataColumn(label: Text(AppStrings.isArabic ? 'المحصل' : 'Collected')),
                  DataColumn(label: Text(AppStrings.isArabic ? 'الأرباح' : 'Profit')),
                  DataColumn(label: Text(AppStrings.isArabic ? 'هامش الربح' : 'Margin')),
                  DataColumn(label: Text(AppStrings.isArabic ? 'الأطباء' : 'Doctors')),
                  DataColumn(label: Text(AppStrings.isArabic ? 'إيراد/طبيب' : 'Rev/Doc')),
                ],
                rows: clinics.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final clinic = entry.value;
                  final rankDisplay = idx < 3 ? medals[idx] : '${idx + 1}';

                  return DataRow(
                    cells: [
                      DataCell(Text(rankDisplay, style: const TextStyle(fontSize: 16))),
                      DataCell(
                        Text(
                          clinic.clinicName,
                          style: AppTextStyles.bodyMedium(context).copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      DataCell(Text('${clinic.expectedRevenue.toStringAsFixed(0)} ${AppStrings.egp}')),
                      DataCell(
                        Text(
                          '${clinic.collectedAmount.toStringAsFixed(0)} ${AppStrings.egp}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataCell(
                        Text(
                          '${clinic.netProfit.toStringAsFixed(0)} ${AppStrings.egp}',
                          style: TextStyle(
                            color: clinic.netProfit >= 0 ? context.successText : context.dangerText,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: clinic.profitMargin < 20
                                ? context.warningBg
                                : context.successBg,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${clinic.profitMargin.toStringAsFixed(1)}%',
                            style: TextStyle(
                              color: clinic.profitMargin < 20
                                  ? context.warningText
                                  : context.successText,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      DataCell(Text('${clinic.numberOfDoctors}')),
                      DataCell(Text('${clinic.revenuePerDoctor.toStringAsFixed(0)} ${AppStrings.egp}')),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

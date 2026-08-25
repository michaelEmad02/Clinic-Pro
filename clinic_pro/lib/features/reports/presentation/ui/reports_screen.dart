// ────────────────────────────────────────────────────────
// الشاشة الرئيسية للتقارير — عرض أقسام التقارير المختلفة
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../core/strings/app_strings.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/responsive_helper.dart';
import 'financial_reports_screen.dart';
import 'appointment_reports_screen.dart';
import 'patient_reports_screen.dart';
import 'doctor_reports_screen.dart';
import 'drug_reports_screen.dart';
import 'clinic_reports_screen.dart';

class ReportsScreen extends StatelessWidget {
  final bool isOwner;

  const ReportsScreen({super.key, this.isOwner = true});

  @override
  Widget build(BuildContext context) {
    return _ReportsCategoryBody(isOwner: isOwner);
  }
}

class _ReportsCategoryBody extends StatelessWidget {
  final bool isOwner;

  const _ReportsCategoryBody({required this.isOwner});

  @override
  Widget build(BuildContext context) {
    final categories = [
      _ReportCategoryItem(
        title: AppStrings.isArabic ? 'التقارير المالية' : 'Financial Reports',
        subtitle: AppStrings.isArabic
            ? 'الملخص المالي والإيرادات والمصروفات'
            : 'Financial summary, revenue & expenses',
        icon: Icons.payments_outlined,
        color: context.primary,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const FinancialReportsScreen(),
          ),
        ),
      ),
      _ReportCategoryItem(
        title: AppStrings.isArabic ? 'تقارير المواعيد' : 'Appointment Reports',
        subtitle: AppStrings.isArabic
            ? 'نسب الحضور وأوقات الذروة والتوزيع'
            : 'Attendance rate, peak hours & distribution',
        icon: Icons.calendar_month_outlined,
        color: context.warningText,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const AppointmentReportsScreen(),
          ),
        ),
      ),
      if (isOwner)
        _ReportCategoryItem(
          title: AppStrings.isArabic ? 'تقارير العيادات' : 'Clinic Reports',
          subtitle: AppStrings.isArabic
              ? 'مقارنة أداء وإيرادات العيادات'
              : 'Compare clinics performance & revenue',
          icon: Icons.business_outlined,
          color: Colors.indigo,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ClinicReportsScreen(),
            ),
          ),
        ),
      _ReportCategoryItem(
        title: AppStrings.isArabic ? 'تقارير المرضى' : 'Patient Reports',
        subtitle: AppStrings.isArabic
            ? 'توزيع الأعمار والجنس والمرضى غير النشطين'
            : 'Age, gender distribution & inactive patients',
        icon: Icons.people_outline,
        color: context.successText,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const PatientReportsScreen(),
          ),
        ),
      ),
      if (isOwner)
        _ReportCategoryItem(
          title: AppStrings.isArabic
              ? 'تقارير أداء الأطباء'
              : 'Doctor Performance Reports',
          subtitle: AppStrings.isArabic
              ? 'مقارنة أداء وإيرادات أطباء العيادة'
              : 'Compare doctors performance & revenue',
          icon: Icons.badge_outlined,
          color: Colors.purple,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const DoctorReportsScreen(),
            ),
          ),
        ),
      if (!isOwner)
        _ReportCategoryItem(
          title: AppStrings.isArabic ? 'تقارير الأدوية' : 'Drugs Reports',
          subtitle: AppStrings.isArabic
              ? 'توزيع الأدوية وتصنيفاتها والأكثر وصفاً'
              : 'Drug categories breakdown & top prescribed',
          icon: Icons.medication_outlined,
          color: Colors.teal,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const DrugReportsScreen(),
            ),
          ),
        ),
    ];

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        toolbarHeight: 64,
        backgroundColor: context.surfaceColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          AppStrings.reports,
          style: AppTextStyles.headlineMedium(context).copyWith(
            fontWeight: FontWeight.bold,
            color: context.primary,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: context.borderColor, height: 1),
        ),
      ),
      body: ResponsiveHelper.responsiveCenter(
        maxWidth: AppConstants.maxContentWidth,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 600;
            return GridView.builder(
              padding: const EdgeInsets.all(AppConstants.spaceMd),
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 350,
                mainAxisExtent: isWide ? 90 : 95,
                crossAxisSpacing: AppConstants.spaceMd,
                mainAxisSpacing: AppConstants.spaceMd,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                return _CategoryCard(item: cat);
              },
            );
          },
        ),
      ),
    );
  }
}

class _ReportCategoryItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  _ReportCategoryItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

class _CategoryCard extends StatelessWidget {
  final _ReportCategoryItem item;

  const _CategoryCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.surfaceColor,
      borderRadius: BorderRadius.circular(AppConstants.radiusCard),
      elevation: 0,
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusCard),
        child: Container(
          padding: const EdgeInsets.all(AppConstants.spaceMd),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.radiusCard),
            border: Border.all(color: context.borderColor, width: 0.5),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.12),
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusButton),
                ),
                child: Icon(item.icon, color: item.color, size: 28),
              ),
              const SizedBox(width: AppConstants.spaceMd),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: AppTextStyles.headlineSmall(context).copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.subtitle,
                      style: AppTextStyles.caption(context).copyWith(
                        color: context.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: context.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

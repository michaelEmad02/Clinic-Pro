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

import 'package:go_router/go_router.dart';
import '../../../../core/constants/route_constants.dart';

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
        title: AppStrings.isArabic ? 'المستحقات المالية' : 'Financial Receivables',
        subtitle: AppStrings.isArabic
            ? 'ديون المرضى وحالات التفوتر والتحصيل'
            : 'Debtor patients & pending outstandings',
        icon: Icons.account_balance_wallet_outlined,
        color: context.danger,
        onTap: () => context.push(RouteConstants.reportsReceivables),
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

    final isDesktop = ResponsiveHelper.isDesktop(context);

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        toolbarHeight: isDesktop ? 70 : 64,
        backgroundColor: context.surfaceColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: Text(
          AppStrings.reports,
          style: AppTextStyles.headlineLarge(context).copyWith(
            fontWeight: FontWeight.bold,
            color: context.primary,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: context.borderColor, height: 1),
        ),
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ColoredBox(
          color: Colors.transparent,
          child: ResponsiveHelper.responsiveCenter(
            maxWidth: isDesktop ? 1200 : AppConstants.maxContentWidth,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 24 : AppConstants.spaceMd,
                vertical: isDesktop ? 24 : AppConstants.spaceMd,
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final crossAxisCount = width >= 1024
                      ? 3
                      : (width >= 600 ? 2 : 1);

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisExtent: isDesktop ? 108 : 96,
                      crossAxisSpacing: isDesktop ? 18 : AppConstants.spaceMd,
                      mainAxisSpacing: isDesktop ? 18 : AppConstants.spaceMd,
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
          ),
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

class _CategoryCard extends StatefulWidget {
  final _ReportCategoryItem item;

  const _CategoryCard({required this.item});

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final item = widget.item;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(AppConstants.radiusCard),
          border: Border.all(
            color: _isHovered ? item.color.withOpacity(0.5) : context.borderColor,
            width: _isHovered ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered
                  ? item.color.withOpacity(0.10)
                  : const Color(0x08000000),
              blurRadius: _isHovered ? 10 : 4,
              offset: Offset(0, _isHovered ? 4 : 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppConstants.radiusCard),
          child: InkWell(
            onTap: item.onTap,
            borderRadius: BorderRadius.circular(AppConstants.radiusCard),
            child: Padding(
              padding: EdgeInsets.all(isDesktop ? 16 : AppConstants.spaceMd),
              child: Row(
                children: [
                  Container(
                    width: isDesktop ? 54 : 48,
                    height: isDesktop ? 54 : 48,
                    decoration: BoxDecoration(
                      color: item.color.withOpacity(0.12),
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusButton),
                    ),
                    child: Icon(item.icon,
                        color: item.color, size: isDesktop ? 26 : 24),
                  ),
                  SizedBox(width: isDesktop ? 16 : AppConstants.spaceMd),
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
                            fontSize: isDesktop ? 17 : 15.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.subtitle,
                          style: AppTextStyles.caption(context).copyWith(
                            color: context.textSecondary,
                            fontSize: isDesktop ? 13 : 12,
                            height: 1.35,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: isDesktop ? 16 : 14,
                    color: _isHovered ? item.color : context.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

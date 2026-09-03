import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clinic_pro/core/strings/app_strings.dart';
import 'package:clinic_pro/core/themes/app_colors.dart';
import 'package:clinic_pro/core/themes/app_text_styles.dart';
import 'package:clinic_pro/core/constants/app_constants.dart';
import 'package:clinic_pro/features/auth/presentation/manager/auth_cubit.dart';
import 'package:clinic_pro/core/constants/route_constants.dart';
import 'package:go_router/go_router.dart';
import 'financial_reports_screen.dart';
import 'appointment_reports_screen.dart';
import 'patient_reports_screen.dart';
import 'drug_reports_screen.dart';

class DoctorMyReportsScreen extends StatelessWidget {
  final String? doctorId;

  const DoctorMyReportsScreen({super.key, this.doctorId});

  @override
  Widget build(BuildContext context) {
    final currentUserId = context.read<AuthCubit>().state.user?.id ?? '';
    final targetDoctorId = doctorId ?? currentUserId;

    final categories = [
      _ReportCategoryItem(
        title:
            AppStrings.isArabic ? 'مستحقاتي المالية' : 'My Receivables Report',
        subtitle: AppStrings.isArabic
            ? 'ديون مرضي وحالات الفواتير والزيارات المعلقة'
            : 'Debtor patients & pending outstandings',
        icon: Icons.account_balance_wallet_outlined,
        color: context.dangerText,
        onTap: () => context.push(RouteConstants.reportsReceivables),
      ),
      _ReportCategoryItem(
        title: AppStrings.isArabic ? 'تقاريري المالية' : 'My Financial Reports',
        subtitle: AppStrings.isArabic
            ? 'ملخص الإيرادات والمجموع الشخصي'
            : 'Personal revenue & collected summary',
        icon: Icons.payments_outlined,
        color: context.primary,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FinancialReportsScreen(doctorId: targetDoctorId),
          ),
        ),
      ),
      _ReportCategoryItem(
        title:
            AppStrings.isArabic ? 'تقارير مواعيدي' : 'My Appointment Reports',
        subtitle: AppStrings.isArabic
            ? 'نسب الحضور والإلغاء وتوزيع المواعيد'
            : 'Attendance, cancellation rates & appointment breakdown',
        icon: Icons.calendar_month_outlined,
        color: context.warningText,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AppointmentReportsScreen(doctorId: targetDoctorId),
          ),
        ),
      ),
      _ReportCategoryItem(
        title: AppStrings.isArabic ? 'تقارير مرضاي' : 'My Patient Reports',
        subtitle: AppStrings.isArabic
            ? 'إحصائيات مرضاي وتوزيع الأعمار والجنس'
            : 'My patients statistics, age & gender distribution',
        icon: Icons.people_outline,
        color: context.successText,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PatientReportsScreen(doctorId: targetDoctorId),
          ),
        ),
      ),
      _ReportCategoryItem(
        title: AppStrings.isArabic
            ? 'تقارير الأدوية والروشتات'
            : 'My Prescription & Drug Reports',
        subtitle: AppStrings.isArabic
            ? 'توزيع الأدوية الموصوفة من قبلي'
            : 'Breakdown of drugs prescribed by me',
        icon: Icons.medication_outlined,
        color: Colors.teal,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DrugReportsScreen(doctorId: targetDoctorId),
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
          AppStrings.isArabic ? 'تقاريري والإحصائيات' : 'My Reports',
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 600;
          return GridView.builder(
            padding: const EdgeInsets.all(AppConstants.spaceMd),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isWide ? 2 : 1,
              crossAxisSpacing: AppConstants.spaceMd,
              mainAxisSpacing: AppConstants.spaceMd,
              childAspectRatio: isWide ? 1.5 : 2.5,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              return _CategoryCard(item: cat);
            },
          );
        },
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
                width: 56,
                height: 56,
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.subtitle,
                      style: AppTextStyles.caption(context).copyWith(
                        color: context.textSecondary,
                      ),
                      maxLines: 2,
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

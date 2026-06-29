// ────────────────────────────────────────────────────────
// شبكة الإحصائيات السريعة Bento — 2×2 جوال، 4 أعمدة سطح مكتب
// بطاقة التقييم بلون مختلف (primary-container)
// مستوحى من تصميم phase8_ui/clinic_details_screen
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../manager/clinics_state.dart';

class ClinicSummaryCards extends StatelessWidget {
  final ClinicItem clinic;

  const ClinicSummaryCards({super.key, required this.clinic});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 600;
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: isWide ? 4 : 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1.3,
          children: [
            _SummaryCard(
              icon: Icons.groups,
              iconBg: AppColors.primaryLight,
              iconColor: AppColors.primary,
              value: _formatNumber(clinic.totalPatients),
              label: 'إجمالي المرضى',
              change: '+${clinic.patientsChange}% هذا الشهر',
              changeColor: AppColors.successText,
            ),
            _SummaryCard(
              icon: Icons.event,
              iconBg: AppColors.warningBg,
              iconColor: AppColors.warningText,
              value: _formatNumber(clinic.todayAppointments),
              label: 'مواعيد اليوم',
              change: 'متبقي ${clinic.todayRemaining}',
              changeColor: AppColors.textSecondary,
            ),
            _SummaryCard(
              icon: Icons.medical_services_outlined,
              iconBg: AppColors.primaryLight,
              iconColor: AppColors.primary,
              value: '${clinic.doctorsCount}',
              label: 'الأطباء',
              change: clinic.doctorsCount > 0 && clinic.doctorsOnLeave > 0
                  ? '${clinic.doctorsOnLeave} في إجازة'
                  : clinic.doctorsCount > 0
                      ? 'نشط'
                      : 'لا يوجد',
              changeColor: AppColors.textSecondary,
            ),
            // بطاقة التقييم — بلون مميز (primary-container)
            _RatingCard(
              rating: clinic.rating,
              totalReviews: clinic.totalReviews,
            ),
          ],
        );
      },
    );
  }
}

String _formatNumber(int value) {
  return value.toString().replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]},',
  );
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String value;
  final String label;
  final String change;
  final Color changeColor;

  const _SummaryCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.value,
    required this.label,
    required this.change,
    required this.changeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 4,
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
              Flexible(
                child: Text(
                  label,
                  style: AppTextStyles.bodyMedium(context).copyWith(
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: iconColor),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: AppTextStyles.dataNumeric(context).copyWith(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Icon(
                Icons.trending_up,
                size: 12,
                color: changeColor,
              ),
              const SizedBox(width: 2),
              Flexible(
                child: Text(
                  change,
                  style: AppTextStyles.caption(context).copyWith(
                    color: changeColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RatingCard extends StatelessWidget {
  final double rating;
  final int totalReviews;

  const _RatingCard({
    required this.rating,
    required this.totalReviews,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Stack(
        children: [
          // عنصر زخرفي
          Positioned(
            bottom: -12,
            right: -12,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.surfaceTint.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'التقييم العام',
                    style: AppTextStyles.bodyMedium(context).copyWith(
                      color: AppColors.onPrimaryContainer,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceTint.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.star,
                        size: 16, color: AppColors.onPrimaryContainer),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    rating.toStringAsFixed(1),
                    style: AppTextStyles.dataNumeric(context).copyWith(
                      color: AppColors.onPrimaryContainer,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    ' / 5.0',
                    style: AppTextStyles.caption(context).copyWith(
                      color: AppColors.onPrimaryContainer.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              Text(
                'من $totalReviews مراجعة',
                style: AppTextStyles.caption(context).copyWith(
                  color: AppColors.onPrimaryContainer.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

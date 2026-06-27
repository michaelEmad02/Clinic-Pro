import 'package:clinic_pro/core/constants/route_constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';

class QuickActionsRow extends StatelessWidget {
  const QuickActionsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'إجراءات سريعة',
            style: AppTextStyles.headlineSmall(context).copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 80,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildActionButton(
                context: context,
                label: 'إضافة عيادة',
                icon: Icons.add_business_outlined,
                onTap: () => context.push(RouteConstants.onboardingClinic),
              ),
              const SizedBox(width: 12),
              _buildActionButton(
                context: context,
                label: 'دعوة موظف',
                icon: Icons.person_add_alt_1_outlined,
                onTap: () => context.push(RouteConstants.onboardingInvite),
              ),
              const SizedBox(width: 12),
              _buildActionButton(
                context: context,
                label: 'التقارير المالية',
                icon: Icons.analytics_outlined,
                onTap: () {
                  // Action to view financial reports
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 120,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.01),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: AppColors.primaryContainer,
              size: 24,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: AppTextStyles.caption(context).copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

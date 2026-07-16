// ────────────────────────────────────────────────────────
// هذا الملف يحتوي على ويدجيت الاختصارات السريعة للطبيب (DoctorQuickActions)
// يسهل الوصول إلى شاشات الأدوية، قوالب الروشتات، وتعديل أنواع الزيارات
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:clinic_pro/core/constants/route_constants.dart';
import 'package:clinic_pro/core/themes/app_colors.dart';
import 'package:clinic_pro/core/themes/app_text_styles.dart';
import 'package:clinic_pro/core/strings/app_strings.dart';
import 'package:clinic_pro/features/settings/presentation/ui/widgets/edit_visit_types_sheet.dart';

class DoctorQuickActions extends StatelessWidget {
  const DoctorQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            AppStrings.quickActions,
            style: AppTextStyles.headlineSmall(context).copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 85,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildActionCard(
                context: context,
                label: AppStrings.drugs,
                icon: Icons.medical_services_outlined,
                onTap: () => context.push(RouteConstants.drugs),
              ),
              const SizedBox(width: 12),
              _buildActionCard(
                context: context,
                label: AppStrings.prescriptionTemplates,
                icon: Icons.description_outlined,
                onTap: () => context.push(RouteConstants.prescriptionTemplates),
              ),
              const SizedBox(width: 12),
              _buildActionCard(
                context: context,
                label: AppStrings.visitTypes,
                icon: Icons.loyalty_outlined,
                onTap: () => EditVisitTypesSheet.show(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 120,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.01),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: AppColors.primary,
              size: 24,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: AppTextStyles.caption(context).copyWith(
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
                overflow: TextOverflow.ellipsis,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

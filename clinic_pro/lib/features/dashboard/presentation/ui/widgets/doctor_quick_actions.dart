// ────────────────────────────────────────────────────────
// ويدجيت الاختصارات السريعة للطبيب المتجاوبة (Responsive Doctor Quick Actions)
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:clinic_pro/core/constants/route_constants.dart';
import 'package:clinic_pro/core/utils/responsive_helper.dart';
import 'package:clinic_pro/core/themes/app_colors.dart';
import 'package:clinic_pro/core/themes/app_text_styles.dart';
import 'package:clinic_pro/core/strings/app_strings.dart';
import 'package:clinic_pro/features/settings/presentation/ui/widgets/edit_visit_types_sheet.dart';

class DoctorQuickActions extends StatelessWidget {
  const DoctorQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    final actions = [
      {
        'label': AppStrings.drugs,
        'icon': Icons.medical_services_outlined,
        'onTap': () => context.push(RouteConstants.drugs),
      },
      {
        'label': AppStrings.prescriptionTemplates,
        'icon': Icons.description_outlined,
        'onTap': () => context.push(RouteConstants.prescriptionTemplates),
      },
      {
        'label': AppStrings.visitTypes,
        'icon': Icons.loyalty_outlined,
        'onTap': () => EditVisitTypesSheet.show(context),
      },
      {
        'label': AppStrings.isArabic ? 'تقاريري' : 'My Reports',
        'icon': TablerIcons.chart_bar,
        'onTap': () => context.push(RouteConstants.doctorMyReports),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            AppStrings.quickActions,
            style: AppTextStyles.headlineSmall(context).copyWith(
              color: context.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: actions.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isMobile ? 2 : 4,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: isMobile ? 1.9 : 2.4,
            ),
            itemBuilder: (context, index) {
              final action = actions[index];
              return _buildActionCard(
                context: context,
                label: action['label'] as String,
                icon: action['icon'] as IconData,
                onTap: action['onTap'] as VoidCallback,
              );
            },
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
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.borderColor),
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
              color: context.primary,
              size: 22,
            ),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption(context).copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.textPrimary,
                  fontSize: 10.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

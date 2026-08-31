// ────────────────────────────────────────────────────────
// ويدجيت الاختصارات السريعة للطبيب المتجاوبة (Responsive Doctor Quick Actions)
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:clinic_pro/core/constants/route_constants.dart';
import 'package:clinic_pro/core/themes/app_colors.dart';
import 'package:clinic_pro/core/themes/app_text_styles.dart';
import 'package:clinic_pro/core/strings/app_strings.dart';
import 'package:clinic_pro/features/settings/presentation/ui/widgets/edit_visit_types_sheet.dart';

import 'package:clinic_pro/core/utils/responsive_helper.dart';

class DoctorQuickActions extends StatelessWidget {
  const DoctorQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    final actions = [
      {
        'label': AppStrings.isArabic ? 'تقاريري' : 'My Reports',
        'icon': TablerIcons.chart_bar,
        'onTap': () => context.push(RouteConstants.doctorMyReports),
      },
      {
        'label': AppStrings.isArabic ? 'الفواتير' : 'Invoices',
        'icon': Icons.receipt_long_outlined,
        'onTap': () => context.push(RouteConstants.invoices),
      },
      {
        'label': AppStrings.allPrescriptions,
        'icon': Icons.medication_liquid_outlined,
        'onTap': () => context.push(RouteConstants.allPrescriptions),
      },
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
        if (isMobile)
          SizedBox(
            height: 52,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: actions.length,
              separatorBuilder: (context, index) => const SizedBox(width: 10),
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
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: List.generate(actions.length, (index) {
                final action = actions[index];
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: index < actions.length - 1 ? 10 : 0,
                    ),
                    child: _buildActionCard(
                      context: context,
                      label: action['label'] as String,
                      icon: action['icon'] as IconData,
                      onTap: action['onTap'] as VoidCallback,
                    ),
                  ),
                );
              }),
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.015),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: context.primaryLightColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: context.primary,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyMedium(context).copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.textPrimary,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

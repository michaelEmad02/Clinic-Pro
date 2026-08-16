import 'package:clinic_pro/core/constants/app_constants.dart';
import 'package:clinic_pro/core/strings/app_strings.dart';
import 'package:clinic_pro/core/themes/app_colors.dart';
import 'package:clinic_pro/core/themes/app_text_styles.dart';
import 'package:flutter/material.dart';

class UsageProgressSection extends StatelessWidget {
  final int patientsUsed;
  final int patientsMax;
  final int usersUsed;
  final int usersMax;
  final int clinicsUsed;
  final int clinicsMax;

  const UsageProgressSection({
    super.key,
    required this.patientsUsed,
    required this.patientsMax,
    required this.usersUsed,
    required this.usersMax,
    required this.clinicsUsed,
    required this.clinicsMax,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final childAspectRatio = isMobile ? 1.4 : 1.6;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.planUsage,
          style: AppTextStyles.headlineSmall(context),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        const SizedBox(height: AppConstants.spaceMd),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: isMobile ? 2 : 3,
          mainAxisSpacing: AppConstants.spaceMd,
          crossAxisSpacing: AppConstants.spaceMd,
          childAspectRatio: childAspectRatio,
          children: [
            _UsageCard(
              icon: Icons.groups,
              label: AppStrings.patients,
              used: patientsUsed,
              max: patientsMax,
              color: context.primary,
            ),
            _UsageCard(
              icon: Icons.person,
              label: AppStrings.users,
              used: usersUsed,
              max: usersMax,
              color: context.primary,
            ),
            _UsageCard(
              icon: Icons.domain,
              label: AppStrings.clinics,
              used: clinicsUsed,
              max: clinicsMax,
              color: context.warningText,
            ),
          ],
        ),
      ],
    );
  }
}

class _UsageCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int used;
  final int max;
  final Color color;

  const _UsageCard({
    required this.icon,
    required this.label,
    required this.used,
    required this.max,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = max > 0 ? (used / max).clamp(0.0, 1.0) : 0.0;
    final isFull = ratio >= 1.0;
    final maxDisplayStr = max <= 0 ? AppStrings.unlimited : '$max';

    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusCard),
        border: Border.all(
          color: isFull ? context.warningText : context.borderColor,
          width: isFull ? 1.5 : 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.bodyMedium(context).copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          const Spacer(),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              '$used / $maxDisplayStr',
              style: AppTextStyles.headlineSmall(context).copyWith(
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
              ),
            ),
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: ratio,
            backgroundColor: context.borderColor,
            color: isFull ? context.warningText : color,
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
        ],
      ),
    );
  }
}

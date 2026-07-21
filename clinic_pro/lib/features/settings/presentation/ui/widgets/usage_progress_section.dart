import 'package:flutter/material.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.planUsage, style: AppTextStyles.headlineSmall(context)),
        const SizedBox(height: AppConstants.spaceMd),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: AppConstants.spaceMd,
          crossAxisSpacing: AppConstants.spaceMd,
          childAspectRatio: 1.3,
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
    final fraction = max > 0 ? (used / max).clamp(0.0, 1.0) : 0.0;
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusCard),
        border: Border.all(color: context.border, width: 0.5),
        boxShadow: const [
          BoxShadow(color: Color(0x14000000), blurRadius: 3, offset: Offset(0, 1)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: context.primaryLightColor,
                  borderRadius: BorderRadius.circular(AppConstants.radiusInput),
                ),
                child: Icon(icon, color: context.primary, size: 18),
              ),
              Text('$used / $max', style: AppTextStyles.dataNumeric(context).copyWith(color: context.textSecondary)),
            ],
          ),
          const Spacer(),
          Text(label, style: AppTextStyles.headlineSmall(context)),
          const SizedBox(height: AppConstants.spaceSm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.radiusChip),
            child: LinearProgressIndicator(
              value: fraction,
              backgroundColor: context.surfaceContainerLow,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: AppConstants.spaceXs),
          Text(
            max - used >= 0
                ? '${AppStrings.remainingCount} ${max - used} $label'
                : AppStrings.overLimit,
            style: AppTextStyles.caption(context).copyWith(color: context.textSecondary),
          ),
        ],
      ),
    );
  }
}

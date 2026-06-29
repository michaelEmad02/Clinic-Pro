import 'package:flutter/material.dart';
import '../../../../../core/constants/app_constants.dart';
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
    this.patientsUsed = 150,
    this.patientsMax = 500,
    this.usersUsed = 3,
    this.usersMax = 5,
    this.clinicsUsed = 1,
    this.clinicsMax = 2,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('استهلاك الباقة الحالية', style: AppTextStyles.headlineSmall(context)),
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
              label: 'المرضى',
              used: patientsUsed,
              max: patientsMax,
              color: AppColors.primary,
            ),
            _UsageCard(
              icon: Icons.person,
              label: 'المستخدمين',
              used: usersUsed,
              max: usersMax,
              color: AppColors.primary,
            ),
            _UsageCard(
              icon: Icons.domain,
              label: 'العيادات',
              used: clinicsUsed,
              max: clinicsMax,
              color: AppColors.warningText,
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
    final fraction = used / max;
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusCard),
        border: Border.all(color: AppColors.border, width: 0.5),
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
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(AppConstants.radiusInput),
                ),
                child: Icon(icon, color: AppColors.primary, size: 18),
              ),
              Text('$used / $max', style: AppTextStyles.dataNumeric(context).copyWith(color: AppColors.textSecondary)),
            ],
          ),
          const Spacer(),
          Text(label, style: AppTextStyles.headlineSmall(context)),
          const SizedBox(height: AppConstants.spaceSm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.radiusChip),
            child: LinearProgressIndicator(
              value: fraction,
              backgroundColor: AppColors.surfaceContainer,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: AppConstants.spaceXs),
          Text('متبقي ${max - used} ${label == 'المرضى' ? 'مريض' : label == 'المستخدمين' ? 'مستخدمين' : 'فرع'}',
              style: AppTextStyles.caption(context).copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

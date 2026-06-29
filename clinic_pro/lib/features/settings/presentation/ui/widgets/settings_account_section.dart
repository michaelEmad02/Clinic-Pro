import 'package:flutter/material.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';

class SettingsAccountSection extends StatelessWidget {
  final String name;
  final String subtitle;
  final VoidCallback? onEdit;

  const SettingsAccountSection({
    super.key,
    required this.name,
    required this.subtitle,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceXs),
          child: Text('الحساب', style: AppTextStyles.headlineSmall(context).copyWith(color: AppColors.textSecondary)),
        ),
        const SizedBox(height: AppConstants.spaceSm),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppConstants.radiusCard),
            border: Border.all(color: AppColors.border, width: 0.5),
            boxShadow: const [
              BoxShadow(color: Color(0x14000000), blurRadius: 3, offset: Offset(0, 1)),
            ],
          ),
          padding: const EdgeInsets.all(AppConstants.spaceMd),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primaryLight,
                child: CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.surface,
                  child: Icon(Icons.person, color: AppColors.primary, size: 28),
                ),
              ),
              const SizedBox(width: AppConstants.spaceMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: AppTextStyles.headlineSmall(context)),
                    Text(subtitle, style: AppTextStyles.bodyMedium(context).copyWith(color: AppColors.textSecondary)),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: onEdit,
                label: Text('تعديل الملف', style: AppTextStyles.bodyLarge(context).copyWith(color: AppColors.primary)),
                icon: const Icon(Icons.chevron_left, color: AppColors.primary, size: 18),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

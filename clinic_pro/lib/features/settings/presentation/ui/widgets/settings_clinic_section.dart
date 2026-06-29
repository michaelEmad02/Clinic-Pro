import 'package:flutter/material.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';

class SettingsClinicSection extends StatelessWidget {
  final String clinicName;
  final String? clinicAddress;
  final VoidCallback? onChangeClinic;

  const SettingsClinicSection({
    super.key,
    required this.clinicName,
    this.clinicAddress,
    this.onChangeClinic,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceXs),
          child: Text('العيادة الحالية', style: AppTextStyles.headlineSmall(context).copyWith(color: AppColors.textSecondary)),
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
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(AppConstants.radiusButton),
                ),
                child: const Icon(Icons.local_hospital, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: AppConstants.spaceMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(clinicName, style: AppTextStyles.headlineSmall(context)),
                    if (clinicAddress != null) ...[
                      const SizedBox(height: 2),
                      Text(clinicAddress!, style: AppTextStyles.caption(context).copyWith(color: AppColors.textSecondary)),
                    ],
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: onChangeClinic,
                label: Text('تغيير العيادة', style: AppTextStyles.bodyLarge(context).copyWith(color: AppColors.primary)),
                icon: const Icon(Icons.chevron_left, color: AppColors.primary, size: 18),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

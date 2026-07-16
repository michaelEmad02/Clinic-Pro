import 'package:flutter/material.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/strings/app_strings.dart';
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
          child: Text(AppStrings.currentClinic, style: AppTextStyles.headlineSmall(context).copyWith(color: context.textSecondary)),
        ),
        const SizedBox(height: AppConstants.spaceSm),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: BorderRadius.circular(AppConstants.radiusCard),
            border: Border.all(color: context.borderColor, width: 0.5),
            boxShadow: const [
              BoxShadow(color: Color(0x0F000000), blurRadius: 4, offset: Offset(0, 2)),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppConstants.spaceMd),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: context.primaryLightColor,
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
                            Text(clinicAddress!, style: AppTextStyles.caption(context).copyWith(color: context.textSecondary)),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (onChangeClinic != null) ...[
                Divider(height: 1, thickness: 0.5, color: context.borderColor),
                InkWell(
                  onTap: onChangeClinic,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppConstants.spaceMd, horizontal: AppConstants.spaceMd),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppStrings.changeClinic,
                          style: AppTextStyles.bodyMedium(context).copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                        ),
                        const Icon(Icons.chevron_left, color: AppColors.primary, size: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

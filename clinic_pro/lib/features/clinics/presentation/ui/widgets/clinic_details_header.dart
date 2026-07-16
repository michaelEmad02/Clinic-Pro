// ────────────────────────────────────────────────────────
// الهيدر العلوي لشاشة تفاصيل العيادة — شعار كبير (128px)، شارات مزدوجة، زخرفة
// مستوحى من تصميم phase8_ui/clinic_details_screen
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../domain/entities/clinic_entity.dart';

class ClinicDetailsHeader extends StatelessWidget {
  final ClinicEntity clinic;

  const ClinicDetailsHeader({super.key, required this.clinic});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusButton),
        border: Border.all(color: context.border),
        boxShadow: AppConstants.cardShadow,
      ),
      child: Stack(
        children: [
          // عنصر زخرفي في الخلفية
          Positioned(
            top: 0,
            right: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: context.primaryLightColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(AppConstants.radiusFull),
                ),
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                const SizedBox(height: AppConstants.spaceSm),
                // شعار العيادة (دائري كبير 128px)
                Container(
                  width: AppConstants.avatarSizeLg,
                  height: AppConstants.avatarSizeLg,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.primaryLightColor,
                    border: Border.all(color: context.surface, width: 4),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1A000000),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: clinic.logoUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(64),
                          child: Image.network(
                            clinic.logoUrl,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Center(
                          child: Text(
                            clinic.initials,
                            style:
                                AppTextStyles.headlineLarge(context).copyWith(
                              color: context.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                ),
                const SizedBox(
                    height: AppConstants.spaceSm + AppConstants.spaceXs),
                // شارات مزدوجة: "مفتوح الآن" + "رئيسية"
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: context.successBg,
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusChip),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: context.successText,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            AppStrings.openNow,
                            style: AppTextStyles.labelChip(context).copyWith(
                              color: context.successText,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppConstants.spaceSm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: context.primaryLightColor,
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusChip),
                      ),
                      child: Text(
                        AppStrings.mainBranch,
                        style: AppTextStyles.labelChip(context).copyWith(
                          color: context.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                    height: AppConstants.spaceSm + AppConstants.spaceXs),
                // اسم العيادة
                Text(
                  clinic.name,
                  style: AppTextStyles.headlineMedium(context).copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppConstants.spaceSm),
                // العنوان
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_on_outlined,
                        size: AppConstants.iconSizeMd,
                        color: context.textSecondary),
                    const SizedBox(width: AppConstants.spaceXs),
                    Flexible(
                      child: Text(
                        clinic.address,
                        style: AppTextStyles.bodyMedium(context).copyWith(
                          color: context.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spaceXs),
                // الهاتف
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.call_outlined,
                        size: AppConstants.iconSizeMd,
                        color: context.textSecondary),
                    const SizedBox(width: AppConstants.spaceXs),
                    Text(
                      clinic.phone1,
                      style: AppTextStyles.bodyMedium(context).copyWith(
                        color: context.textSecondary,
                      ),
                      textDirection: TextDirection.ltr,
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spaceSm),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';

// ────────────────────────────────────────────────────────
// بطاقة رأس الروشتة: تعرض بيانات المريض والموعد
// ────────────────────────────────────────────────────────

class PrescriptionHeaderCard extends StatelessWidget {
  final String patientName;
  final String age;
  final String gender;
  final String bloodType;
  final String visitType;
  final String doctorName;
  final String visitDate;

  const PrescriptionHeaderCard({
    super.key,
    required this.patientName,
    required this.age,
    required this.gender,
    required this.bloodType,
    required this.visitType,
    required this.doctorName,
    required this.visitDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceMd,
        vertical: AppConstants.spaceSm,
      ),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusCard),
        border: Border.all(color: context.borderColor),
        boxShadow: AppConstants.cardShadow,
      ),
      child: Stack(
        children: [
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: 6,
            child: Container(
              decoration: BoxDecoration(
                color: context.primary,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(AppConstants.radiusCard),
                  bottomRight: Radius.circular(AppConstants.radiusCard),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.spaceMd,
              AppConstants.spaceMd,
              AppConstants.spaceLg,
              AppConstants.spaceMd,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: context.primaryLightColor,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.person,
                          color: context.primary,
                          size: 28,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppConstants.spaceSm + 4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            patientName,
                            style: AppTextStyles.headlineMedium(context).copyWith(
                              fontWeight: FontWeight.bold,
                              color: context.textPrimary,
                            ),
                          ),
                          const SizedBox(height: AppConstants.spaceXs),
                          Row(
                            children: [
                              Text(
                                age,
                                style: AppTextStyles.caption(context).copyWith(
                                  color: context.textSecondary,
                                ),
                              ),
                              const SizedBox(width: AppConstants.spaceSm),
                              Container(
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: context.borderColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: AppConstants.spaceSm),
                              Text(
                                gender,
                                style: AppTextStyles.caption(context).copyWith(
                                  color: context.textSecondary,
                                ),
                              ),
                              const SizedBox(width: AppConstants.spaceSm),
                              Container(
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: context.borderColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: AppConstants.spaceSm),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: context.dangerBg,
                                  borderRadius: BorderRadius.circular(AppConstants.radiusXs),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.water_drop,
                                      size: AppConstants.iconSizeSm,
                                      color: context.danger,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      bloodType,
                                      style: AppTextStyles.dataNumeric(context).copyWith(
                                        color: context.danger,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppConstants.spaceSm + 4),
                  child: Divider(color: context.borderColor, height: 1),
                ),
                Wrap(
                  spacing: AppConstants.spaceMd,
                  runSpacing: AppConstants.spaceSm,
                  children: [
                    _buildMetaItem(context, Icons.medical_services_outlined,
                        AppStrings.visitType, visitType),
                    _buildMetaItem(context, Icons.person_outline,
                        AppStrings.doctorLabel, doctorName),
                    _buildMetaItem(context, Icons.calendar_today,
                        AppStrings.date, visitDate),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaItem(
      BuildContext context, IconData icon, String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: AppConstants.iconSizeMd, color: context.primary),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.caption(context).copyWith(
                color: context.textHint,
              ),
            ),
            Text(
              value,
              style: AppTextStyles.bodyMedium(context).copyWith(
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

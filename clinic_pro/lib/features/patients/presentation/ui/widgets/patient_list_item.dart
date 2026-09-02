// ────────────────────────────────────────────────────────
// عنصر مريض واحد في القائمة — مطابق لتصميم Stitch
// يستخدم PatientEntity من طبقة الدومين
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../domain/entities/patient_entity.dart';

class PatientListItem extends StatelessWidget {
  final PatientEntity patient;
  final VoidCallback onTap;
  final VoidCallback onMore;

  const PatientListItem({
    super.key,
    required this.patient,
    required this.onTap,
    required this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spaceSm),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusCard),
        border: Border.all(color: context.borderColor),
        boxShadow: AppConstants.cardShadow,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusCard),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spaceMd),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: context.primaryLightColor,
                child: Text(
                  patient.initials,
                  style: AppTextStyles.bodyMedium(context).copyWith(
                    color: context.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.headlineSmall(context).copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.textPrimary,
                      ),
                    ),
                    if (patient.phone != null && patient.phone!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.phone_iphone_outlined,
                              size: 14, color: context.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            patient.phone!,
                            style: AppTextStyles.caption(context).copyWith(
                              color: context.textSecondary,
                            ),
                            textDirection: TextDirection.ltr,
                          ),
                        ],
                      ),
                    ],
                    // أيقونة تحذير الحساسية بجوار اسم المريض
                    if (patient.hasAllergies) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.warning_amber_outlined,
                              size: 14, color: context.danger),
                          const SizedBox(width: 4),
                          Text(
                            AppStrings.isArabic ? 'حساسية' : 'Allergy',
                            style: AppTextStyles.caption(context).copyWith(
                              color: context.danger,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.more_vert, color: context.textSecondary),
                onPressed: onMore,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

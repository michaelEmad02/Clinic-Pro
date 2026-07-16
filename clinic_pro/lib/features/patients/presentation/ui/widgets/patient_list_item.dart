// ────────────────────────────────────────────────────────
// عنصر مريض واحد في القائمة — مطابق لتصميم Stitch
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../manager/patients_state.dart';

class PatientListItem extends StatelessWidget {
  final PatientItem patient;
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: context.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusCard),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppConstants.radiusCard),
          child: Container(
            padding: const EdgeInsets.all(AppConstants.spaceMd),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppConstants.radiusCard),
              border: Border.all(color: context.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
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
                        style: AppTextStyles.headlineSmall(context).copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.phone_iphone_outlined,
                              size: 14, color: context.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            patient.phone,
                            style: AppTextStyles.caption(context).copyWith(
                              color: context.textSecondary,
                            ),
                            textDirection: TextDirection.ltr,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${AppStrings.lastVisit} ${patient.lastVisitLabel}',
                        style: AppTextStyles.caption(context).copyWith(
                          color: context.textHint,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon:  Icon(Icons.more_horiz,
                      color: context.textSecondary),
                  onPressed: onMore,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────
// عنصر مريض واحد في القائمة — مطابق لتصميم Stitch
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../../core/constants/app_constants.dart';
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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusCard),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppConstants.radiusCard),
          child: Container(
            padding: const EdgeInsets.all(AppConstants.spaceMd),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppConstants.radiusCard),
              border: Border.all(color: AppColors.border),
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
                  backgroundColor: AppColors.primaryLight,
                  child: Text(
                    patient.initials,
                    style: AppTextStyles.bodyMedium(context).copyWith(
                      color: AppColors.primary,
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
                          const Icon(Icons.phone_iphone_outlined,
                              size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            patient.phone,
                            style: AppTextStyles.caption(context).copyWith(
                              color: AppColors.textSecondary,
                            ),
                            textDirection: TextDirection.ltr,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'آخر زيارة ${patient.lastVisitLabel}',
                        style: AppTextStyles.caption(context).copyWith(
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusTag(context),
                IconButton(
                  icon: const Icon(Icons.more_horiz,
                      color: AppColors.textSecondary),
                  onPressed: onMore,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusTag(BuildContext context) {
    Color bg;
    Color text;
    String label;

    switch (patient.statusTag) {
      case 'completed':
        bg = AppColors.successBg;
        text = AppColors.successText;
        label = 'مكتمل';
      case 'chronic':
        bg = AppColors.warningBg;
        text = AppColors.warningText;
        label = 'مزمن';
      default:
        bg = AppColors.primaryLight;
        text = AppColors.primary;
        label = 'مراجعة';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      margin: const EdgeInsetsDirectional.only(end: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption(context).copyWith(
          color: text,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }
}

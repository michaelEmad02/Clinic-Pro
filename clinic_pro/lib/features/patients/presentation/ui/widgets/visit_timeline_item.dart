// ────────────────────────────────────────────────────────
// عنصر زيارة في الجدول الزمني — مطابق لتصميم Stitch
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../manager/patients_state.dart';

class VisitTimelineItem extends StatelessWidget {
  final PatientVisitItem visit;
  final bool isLast;

  const VisitTimelineItem({
    super.key,
    required this.visit,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: context.primary,
                  shape: BoxShape.circle,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: context.border,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(AppConstants.spaceMd),
              decoration: BoxDecoration(
                color: context.surface,
                borderRadius: BorderRadius.circular(AppConstants.radiusCard),
                border: Border.all(color: context.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    visit.title,
                    style: AppTextStyles.headlineSmall(context).copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    visit.displayDate,
                    style: AppTextStyles.caption(context).copyWith(
                      color: context.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    visit.description,
                    style: AppTextStyles.bodyMedium(context).copyWith(
                      color: context.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.medical_services_outlined,
                          size: 14, color: context.primaryContainer),
                      const SizedBox(width: 4),
                      Text(
                        visit.doctorName,
                        style: AppTextStyles.caption(context).copyWith(
                          color: context.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────
// عنصر زيارة في الجدول الزمني — مطابق لتصميم Stitch
// يستخدم AppointmentEntity بدلاً من PatientVisitItem
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../appointments/domain/entities/appointment_entity.dart';

class VisitTimelineItem extends StatelessWidget {
  final AppointmentEntity visit;
  final bool isLast;
  final VoidCallback? onTap;

  const VisitTimelineItem({
    super.key,
    required this.visit,
    this.isLast = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ─── الخط الزمني والنقطة الطبية المحسنة ───
          Column(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: context.primaryLightColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: context.primary, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: context.primary.withOpacity(0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.event_available_rounded,
                    size: 13,
                    color: context.primary,
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: context.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),

          // ─── كرت الزيارة التفاعلي الأنيق ───
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: Material(
                color: context.surfaceColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusCard),
                  side: BorderSide(color: context.borderColor),
                ),
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(AppConstants.radiusCard),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // الرأس: أيقونة الزيارة + نوع الموعد + زر التنقل
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: context.primaryLightColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.medical_information_outlined,
                                size: 18,
                                color: context.primary,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    visit.typeName ?? (AppStrings.isArabic ? 'كشف عادي' : 'Regular Visit'),
                                    style: AppTextStyles.headlineSmall(context).copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: context.textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today_outlined,
                                        size: 12,
                                        color: context.textSecondary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        visit.date,
                                        style: AppTextStyles.dataNumeric(context).copyWith(
                                          color: context.textSecondary,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            if (onTap != null)
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: context.primaryLightColor.withOpacity(0.5),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 12,
                                  color: context.primary,
                                ),
                              ),
                          ],
                        ),

                        // التشخيص من الروشتة (إن وجد) بتنسيق راقٍ
                        if (visit.prescriptionDiagnosis != null &&
                            visit.prescriptionDiagnosis!.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                            decoration: BoxDecoration(
                              color: context.primaryLightColor.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: context.primary.withOpacity(0.15)),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.assignment_outlined,
                                  size: 14,
                                  color: context.primary,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    '${AppStrings.isArabic ? "التشخيص: " : "Diagnosis: "}${visit.prescriptionDiagnosis!}',
                                    style: AppTextStyles.caption(context).copyWith(
                                      color: context.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 10),
                        const Divider(height: 1),
                        const SizedBox(height: 8),

                        // تذييل الكرت: الطبيب + زر عرض التفاصيل
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 11,
                              backgroundColor: context.primaryLightColor,
                              child: Icon(
                                Icons.person_outline,
                                size: 13,
                                color: context.primary,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                visit.doctorName ?? (AppStrings.isArabic ? 'طبيب غير معروف' : 'Unknown Doctor'),
                                style: AppTextStyles.caption(context).copyWith(
                                  color: context.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              AppStrings.isArabic ? 'عرض التفاصيل' : 'View Details',
                              style: AppTextStyles.caption(context).copyWith(
                                color: context.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

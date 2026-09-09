// ────────────────────────────────────────────────────────
// عارض الصور التفاعلي للفحوصات الطبية (MedicalRecordImageViewer)
// يدعم التكبير والتصغير باللمس (Pinch-to-zoom) مع عرض تفاصيل الفحص
// ────────────────────────────────────────────────────────

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:clinic_pro/core/constants/app_constants.dart';
import 'package:clinic_pro/core/strings/app_strings.dart';
import 'package:clinic_pro/core/themes/app_colors.dart';
import 'package:clinic_pro/core/themes/app_text_styles.dart';
import 'package:clinic_pro/core/widgets/app_loading.dart';
import 'package:clinic_pro/features/medical_records/domain/entities/medical_record_entity.dart';

class MedicalRecordImageViewer extends StatelessWidget {
  final MedicalRecordEntity record;

  const MedicalRecordImageViewer({super.key, required this.record});

  static void show(BuildContext context, MedicalRecordEntity record) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MedicalRecordImageViewer(record: record),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLab = record.isLabTest;
    final badgeColor = isLab ? const Color(0xFF0D9488) : const Color(0xFF6366F1);
    final badgeBg = isLab
        ? const Color(0xFF0D9488).withOpacity(0.2)
        : const Color(0xFF6366F1).withOpacity(0.2);
    final typeLabel = isLab ? AppStrings.labTestShort : AppStrings.radiologyShort;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // صورة الفحص التفاعلية مع دعم الـ Zoom والـ Pan
            Center(
              child: InteractiveViewer(
                minScale: 0.8,
                maxScale: 5.0,
                child: CachedNetworkImage(
                  imageUrl: record.fileUrl,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const Center(
                    child: AppLoadingWidget(color: Colors.white),
                  ),
                  errorWidget: (context, url, error) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.broken_image_rounded,
                            size: 64, color: Colors.white54),
                        const SizedBox(height: 12),
                        Text(
                          AppStrings.failedToLoadImage,
                          style: AppTextStyles.bodyMedium(context)
                              .copyWith(color: Colors.white70),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),

            // شريط العنوان العلوي مع زر الإغلاق
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.85),
                      Colors.transparent
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close_rounded,
                          color: Colors.white, size: 28),
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: AppStrings.close,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        record.title,
                        style: AppTextStyles.headlineSmall(context).copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusChip),
                        border: Border.all(
                            color: badgeColor.withOpacity(0.5), width: 0.8),
                      ),
                      child: Text(
                        typeLabel,
                        style: AppTextStyles.caption(context).copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // شريط التفاصيل والملاحظات السفلي
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(AppConstants.spaceLg),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.88)
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded,
                            color: Colors.white70, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          '${AppStrings.testDatePrefix} ${record.recordDate}',
                          style: AppTextStyles.caption(context)
                              .copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          record.isLinkedToAppointment
                              ? Icons.event_available_rounded
                              : Icons.link_off_rounded,
                          color: record.isLinkedToAppointment
                              ? const Color(0xFF34D399)
                              : Colors.white60,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            record.isLinkedToAppointment
                                ? (record.appointmentTypeName != null &&
                                        record.appointmentTypeName!.isNotEmpty
                                    ? AppStrings.linkedToAppointmentWithName(
                                        record.appointmentTypeName!)
                                    : AppStrings.linkedToAppointment)
                                : AppStrings.unlinkedRecord,
                            style: AppTextStyles.caption(context).copyWith(
                              color: record.isLinkedToAppointment
                                  ? const Color(0xFF34D399)
                                  : Colors.white70,
                              fontWeight: record.isLinkedToAppointment
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (record.isLinkedToAppointment &&
                        record.appointmentId != null &&
                        record.appointmentId!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            context
                                .push('/appointments/${record.appointmentId}');
                          },
                          icon: const Icon(Icons.calendar_month_rounded,
                              size: 18),
                          label: Text(
                            record.appointmentTypeName != null &&
                                    record.appointmentTypeName!.isNotEmpty
                                ? AppStrings.goToAppointmentDetailsWithName(
                                    record.appointmentTypeName!)
                                : AppStrings.goToAppointmentDetails,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: context.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  AppConstants.radiusButton),
                            ),
                            elevation: 2,
                          ),
                        ),
                      ),
                    ],
                    if (record.notes != null && record.notes!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.notes_rounded,
                              color: Colors.white70, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              record.notes!,
                              style: AppTextStyles.caption(context)
                                  .copyWith(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

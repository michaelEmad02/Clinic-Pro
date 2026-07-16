import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/widgets/realtime_indicator.dart';
import '../../../../../core/constants/route_constants.dart';
import '../../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../appointments/presentation/manager/appointments_state.dart';

class WaitingQueueList extends StatelessWidget {
  final List<AppointmentItem> queue;
  final VoidCallback onCallNext;

  const WaitingQueueList({
    super.key,
    required this.queue,
    required this.onCallNext,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── عنوان القسم مع مؤشر الوقت الحقيقي وزر الاستدعاء ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    AppStrings.todayQueue,
                    style: AppTextStyles.headlineSmall(context).copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const RealtimeIndicator(),
                ],
              ),
              if (queue.isNotEmpty)
                TextButton.icon(
                  onPressed: onCallNext,
                  icon: const Icon(Icons.volume_up_outlined, size: 16),
                  label: Text(
                    AppStrings.callNext,
                    style: AppTextStyles.bodyMedium(context).copyWith(
                      color: AppColors.primaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // ── حالة فارغة ──
        if (queue.isEmpty)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(24),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: context.surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.borderColor),
            ),
            child: Text(
              AppStrings.queueEmptyDesc,
              style: AppTextStyles.bodyMedium(context).copyWith(
                color: context.textSecondary,
              ),
            ),
          )
        else
          // ── قائمة عناصر طابور الانتظار ──
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: queue.length,
            itemBuilder: (context, index) {
              final patient = queue[index];
              final isUrgent = patient.isUrgent;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: context.surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: context.borderColor),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── رقم الترتيب في الطابور ──
                      CircleAvatar(
                        backgroundColor: context.primaryLightColor,
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // ── بيانات المريض عموديًا ──
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              patient.patientName,
                              style: AppTextStyles.headlineSmall(context).copyWith(
                                color: context.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              patient.doctorName,
                              style: AppTextStyles.bodyMedium(context).copyWith(
                                color: context.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              patient.typeName,
                              style: AppTextStyles.bodyMedium(context).copyWith(
                                color: context.textSecondary,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              patient.displayTime,
                              style: AppTextStyles.bodyMedium(context).copyWith(
                                color: context.textSecondary,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),

                      // ── أزرار الإجراءات + شارة مستعجل ──
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.more_vert),
                            color: context.textSecondary,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              // إظهار Bottom Sheet مع خيارات المريض
                              AppBottomSheet.show(
                                context: context,
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        patient.patientName,
                                        style: AppTextStyles.headlineSmall(context).copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        patient.patientPhone,
                                        style: AppTextStyles.bodyMedium(context).copyWith(
                                          color: context.textSecondary,
                                        ),
                                        textDirection: TextDirection.ltr,
                                      ),
                                      const SizedBox(height: 16),
                                      ListTile(
                                        leading: const Icon(Icons.person_outline, color: AppColors.primary),
                                        title: Text(
                                          AppStrings.patientDetails,
                                          style: AppTextStyles.bodyMedium(context).copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        onTap: () {
                                          Navigator.pop(context);
                                          context.push(
                                            RouteConstants.patientDetails.replaceAll(':id', patient.patientId),
                                          );
                                        },
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          if (isUrgent)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.dangerBg,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                AppStrings.urgent,
                                style: AppTextStyles.caption(context).copyWith(
                                  color: AppColors.dangerText,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

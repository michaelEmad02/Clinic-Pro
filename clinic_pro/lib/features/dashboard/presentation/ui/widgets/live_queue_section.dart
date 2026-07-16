// ─────────────────────────────────────────
// هذا الملف يحتوي على قسم قائمة الانتظار المباشرة في لوحة التحكم
// يعرض أول 5 مرضى مع إمكانية التنقل لكامل طابور الانتظار
// ─────────────────────────────────────────

import 'package:clinic_pro/core/widgets/app_bottom_sheet.dart';
import 'package:clinic_pro/features/appointments/presentation/manager/appointments_state.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/route_constants.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/widgets/realtime_indicator.dart';

class LiveQueueSection extends StatelessWidget {
  final List<AppointmentItem> queue;
  final Function(String) onCall;

  const LiveQueueSection({
    super.key,
    required this.queue,
    required this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    // عرض أول 5 مرضى فقط كحد أقصى
    final displayQueue = queue.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                AppStrings.liveQueue,
                style: AppTextStyles.headlineSmall(context).copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              const RealtimeIndicator(),
              const Spacer(),
              if (queue.length > 5)
                TextButton(
                  onPressed: () => context.push(RouteConstants.waitingQueue),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    AppStrings.viewAll,
                    style: AppTextStyles.labelChip(context).copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
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
              AppStrings.noPatientsWaiting,
              style: AppTextStyles.bodyMedium(context).copyWith(
                color: context.textSecondary,
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: displayQueue.length,
            itemBuilder: (context, index) {
              final app = displayQueue[index];
              final isInProgress = app.status == 'in_progress';
              final isUrgent = app.isUrgent;
 
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
                      CircleAvatar(
                        backgroundColor: isInProgress
                            ? AppColors.accent.withOpacity(0.2)
                            : context.primaryLightColor,
                        child: Icon(
                          isInProgress ? Icons.volume_up : Icons.person,
                          color:
                              isInProgress ? AppColors.accent : AppColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              app.patientName,
                              style: AppTextStyles.headlineSmall(context).copyWith(
                                color: context.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              app.doctorName,
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
                              app.typeName,
                              style: AppTextStyles.bodyMedium(context).copyWith(
                                color: context.textSecondary,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              app.displayTime,
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.more_vert),
                            color: context.textSecondary,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              AppBottomSheet.show(
                                context: context,
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        app.patientName,
                                        style: AppTextStyles.headlineSmall(context).copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        app.patientPhone,
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
                                            RouteConstants.patientDetails.replaceAll(':id', app.patientId),
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
                          if (isInProgress)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.successBg,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                AppStrings.atDoctor,
                                style: AppTextStyles.caption(context).copyWith(
                                  color: AppColors.successText,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            )
                          else
                            ElevatedButton(
                              onPressed: () => onCall(app.id),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryContainer,
                                foregroundColor: AppColors.onPrimary,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                AppStrings.call,
                                style: AppTextStyles.caption(context).copyWith(
                                  color: AppColors.onPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          if (isUrgent) ...[
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
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

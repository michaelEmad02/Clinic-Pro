// ────────────────────────────────────────────────────────
// قائمة طابور الانتظار الموحدة (Responsive)
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/widgets/realtime_indicator.dart';
import '../../../domain/entities/appointment_entity.dart';
import 'queue_item.dart';

class WaitingQueueList extends StatelessWidget {
  final List<AppointmentEntity> queue;
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
                      color: context.primary,
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
                      color: context.primaryContainer,
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
              return QueueItem(
                index: index,
                patient: queue[index],
              );
            },
          ),
      ],
    );
  }
}

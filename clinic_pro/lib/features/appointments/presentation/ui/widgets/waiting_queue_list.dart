// ────────────────────────────────────────────────────────
// قائمة طابور الانتظار الموحدة (Responsive)
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/widgets/realtime_indicator.dart';
import '../../../../../core/utils/responsive_helper.dart';
import '../../../domain/entities/appointment_entity.dart';
import 'queue_item.dart';

class WaitingQueueList extends StatelessWidget {
  final List<AppointmentEntity> queue;
  final VoidCallback onCallNext;
  final int? maxItems;

  const WaitingQueueList({
    super.key,
    required this.queue,
    required this.onCallNext,
    this.maxItems,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final horizontalPadding = isDesktop ? 0.0 : 16.0;

    final displayedQueue = (maxItems != null && maxItems! < queue.length)
        ? queue.take(maxItems!).toList()
        : queue;
        
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── عنوان القسم مع مؤشر الوقت الحقيقي وزر الاستدعاء ──
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
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
                      fontSize: isDesktop ? 18 : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const RealtimeIndicator(),
                ],
              ),
              if (queue.isNotEmpty)
                TextButton.icon(
                  onPressed: onCallNext,
                  icon: Icon(Icons.volume_up_outlined, size: isDesktop ? 18 : 16),
                  label: Text(
                    AppStrings.callNext,
                    style: AppTextStyles.bodyMedium(context).copyWith(
                      color: context.primaryContainer,
                      fontWeight: FontWeight.w600,
                      fontSize: isDesktop ? 15 : null,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // ── حالة فارغة ──
        if (displayedQueue.isEmpty)
          Container(
            margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
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
                fontSize: isDesktop ? 15 : null,
              ),
            ),
          )
        else
          // ── قائمة عناصر طابور الانتظار (Responsive Grid/List) ──
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final int columns = (width / 340).floor().clamp(1, 5);

              if (columns == 1) {
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  itemCount: displayedQueue.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    return QueueItem(
                      index: index,
                      patient: displayedQueue[index],
                    );
                  },
                );
              }

              return Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    mainAxisExtent: 176,
                  ),
                  itemCount: displayedQueue.length,
                  itemBuilder: (context, index) {
                    return QueueItem(
                      index: index,
                      patient: displayedQueue[index],
                    );
                  },
                ),
              );
            },
          ),
      ],
    );
  }
}

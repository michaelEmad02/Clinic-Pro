// ────────────────────────────────────────────────────────
// قائمة طابور الانتظار
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/widgets/empty_state.dart';
import '../../../../../core/widgets/realtime_indicator.dart';
import '../../manager/waiting_queue_state.dart';
import 'queue_item.dart';

class QueueList extends StatelessWidget {
  final List<QueuePatient> queue;
  final ValueChanged<String> onCallPatient;

  const QueueList({
    super.key,
    required this.queue,
    required this.onCallPatient,
  });

  @override
  Widget build(BuildContext context) {
    // عرض المرضى في الانتظار فقط (confirmed + in_progress + done)
    final waiting = queue.where((p) => p.status != 'cancelled').toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                'المرضى في الطابور',
                style: AppTextStyles.headlineSmall(context).copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              const RealtimeIndicator(),
              const Spacer(),
              Text(
                '${waiting.length} مريض',
                style: AppTextStyles.caption(context).copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (waiting.isEmpty)
          const EmptyState(
            title: 'الطابور فارغ',
            subtitle: 'لا يوجد مرضى في طابور الانتظار حالياً.',
            icon: Icons.people_outline,
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: waiting.length,
            itemBuilder: (context, index) {
              final patient = waiting[index];
              return QueueItem(
                patient: patient,
                onCall: patient.status == 'confirmed'
                    ? () => onCallPatient(patient.id)
                    : null,
              );
            },
          ),
      ],
    );
  }
}

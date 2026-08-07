// ────────────────────────────────────────────────────────
// قائمة طابور الانتظار (Responsive)
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/widgets/empty_state.dart';
import '../../../../../core/widgets/realtime_indicator.dart';
import '../../../../../core/utils/responsive_helper.dart';
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
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMd),
          child: Row(
            children: [
              Text(
                AppStrings.patientsInQueue,
                style: AppTextStyles.headlineSmall(context).copyWith(
                  color: context.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: AppConstants.spaceSm),
              const RealtimeIndicator(),
              const Spacer(),
              Text(
                '${waiting.length} ${AppStrings.patient}',
                style: AppTextStyles.caption(context).copyWith(
                  color: context.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppConstants.spaceSm + 4),
        if (waiting.isEmpty)
          EmptyState(
            title: AppStrings.queueEmpty,
            subtitle: AppStrings.queueEmptyDesc,
            icon: Icons.people_outline,
          )
        else if (!ResponsiveHelper.isMobile(context))
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMd),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 400,
              mainAxisSpacing: AppConstants.spaceSm,
              crossAxisSpacing: AppConstants.spaceSm,
              childAspectRatio: 3.2,
            ),
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
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMd),
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

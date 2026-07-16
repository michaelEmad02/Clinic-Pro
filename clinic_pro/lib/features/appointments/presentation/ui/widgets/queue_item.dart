// ────────────────────────────────────────────────────────
// عنصر مريض واحد في طابور الانتظار
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/widgets/app_list_item.dart';
import '../../../../../core/widgets/status_badge.dart';
import '../../manager/waiting_queue_state.dart';

class QueueItem extends StatelessWidget {
  final QueuePatient patient;
  final VoidCallback? onCall;

  const QueueItem({
    super.key,
    required this.patient,
    this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    final isInProgress = patient.status == 'in_progress';
    final isDone = patient.status == 'done';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppListItem(
        title: patient.patientName,
        subtitle: '${patient.typeName} • ${patient.displayTime}',
        leading: CircleAvatar(
          backgroundColor: patient.isUrgent
              ? context.dangerBg
              : (isInProgress ? context.warningBg : context.primaryLightColor),
          child: Text(
            '${patient.queueNumber}',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.bold,
              color: isInProgress ? context.warningText : context.primary,
            ),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (patient.isUrgent) ...[
              const StatusBadge(
                text: '🚨',
                status: BadgeStatus.error,
                addBackgroundColor: false,
              ),
              const SizedBox(width: 8),
            ],
            if (isInProgress)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: context.warningBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  AppStrings.atDoctor,
                  style: AppTextStyles.caption(context).copyWith(
                    color: context.warningText,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              )
            else if (isDone)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: context.successBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  AppStrings.finished,
                  style: AppTextStyles.caption(context).copyWith(
                    color: context.successText,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              )
            else if (onCall != null)
              IconButton(
                icon: Icon(Icons.volume_up_outlined, color: context.primary),
                onPressed: onCall,
                tooltip: AppStrings.call,
              ),
          ],
        ),
      ),
    );
  }
}

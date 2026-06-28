// ────────────────────────────────────────────────────────
// عنصر مريض واحد في طابور الانتظار
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/widgets/app_list_item.dart';
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
              ? AppColors.dangerBg
              : (isInProgress ? AppColors.warningBg : AppColors.primaryLight),
          child: Text(
            '${patient.queueNumber}',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.bold,
              color: isInProgress ? AppColors.warningText : AppColors.primary,
            ),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (patient.isUrgent)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                margin: const EdgeInsets.only(left: 8),
                decoration: BoxDecoration(
                  color: AppColors.dangerBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'مستعجل',
                  style: AppTextStyles.caption(context).copyWith(
                    color: AppColors.dangerText,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            if (isInProgress)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.warningBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'عند الطبيب',
                  style: AppTextStyles.caption(context).copyWith(
                    color: AppColors.warningText,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              )
            else if (isDone)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.successBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'انتهى',
                  style: AppTextStyles.caption(context).copyWith(
                    color: AppColors.successText,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              )
            else if (onCall != null)
              IconButton(
                icon: const Icon(Icons.volume_up_outlined, color: AppColors.primary),
                onPressed: onCall,
                tooltip: 'استدعاء',
              ),
          ],
        ),
      ),
    );
  }
}

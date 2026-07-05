import 'package:flutter/material.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/widgets/realtime_indicator.dart';
import '../../../../../core/widgets/app_list_item.dart';
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'طابور الانتظار اليوم',
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
                    'استدعاء التالي',
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
        if (queue.isEmpty)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(24),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              'لا يوجد مرضى في طابور الانتظار حالياً.',
              style: AppTextStyles.bodyMedium(context).copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          )
        else
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
                child: AppListItem(
                  title: patient.patientName,
                  subtitle: '${patient.typeName} ${patient.notes != null ? '• ${patient.notes}' : ''}',
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primaryLight,
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isUrgent)
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
                      Text(
                        patient.displayTime,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
                        onPressed: () {
                          // Action bottom sheet
                        },
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

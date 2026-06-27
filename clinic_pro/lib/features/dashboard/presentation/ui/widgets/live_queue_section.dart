import 'package:flutter/material.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/widgets/realtime_indicator.dart';
import '../../../../../core/widgets/app_list_item.dart';
import '../../manager/secretary_dashboard_state.dart';

class LiveQueueSection extends StatelessWidget {
  final List<AppointmentMock> queue;
  final Function(String) onCall;

  const LiveQueueSection({
    super.key,
    required this.queue,
    required this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                'الانتظار المباشر',
                style: AppTextStyles.headlineSmall(context).copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              const RealtimeIndicator(),
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
              'لا يوجد مرضى بانتظار الدخول حالياً.',
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
              final app = queue[index];
              final isInProgress = app.status == 'in_progress';
              final isUrgent = app.type == 'urgent';

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: AppListItem(
                  title: app.patientName,
                  subtitle: '${app.doctorName} • ${app.time}',
                  leading: CircleAvatar(
                    backgroundColor: isInProgress ? AppColors.accent.withOpacity(0.2) : AppColors.primaryLight,
                    child: Icon(
                      isInProgress ? Icons.volume_up : Icons.person,
                      color: isInProgress ? AppColors.accent : AppColors.primary,
                      size: 20,
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
                      if (isInProgress)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.successBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'عند الطبيب',
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
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'استدعاء',
                            style: AppTextStyles.caption(context).copyWith(
                              color: AppColors.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      const SizedBox(width: 4),
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

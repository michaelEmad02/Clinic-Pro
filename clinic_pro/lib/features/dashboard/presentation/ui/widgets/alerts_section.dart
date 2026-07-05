import 'package:flutter/material.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../domain/entities/dashboard_alert_entity.dart';

class AlertsSection extends StatelessWidget {
  final List<DashboardAlertEntity> alerts;

  const AlertsSection({
    super.key,
    required this.alerts,
  });

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'تنبيهات هامة',
            style: AppTextStyles.headlineSmall(context).copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: alerts.length,
          itemBuilder: (context, index) {
            final alert = alerts[index];
            final isWarning = alert.type == DashboardAlertType.warning;
            final bg = isWarning ? AppColors.warningBg : AppColors.primaryLight;
            final textCol = isWarning ? AppColors.warningText : AppColors.primary;
            final borderCol = isWarning
                ? AppColors.warningText.withOpacity(0.1)
                : AppColors.primaryContainer.withOpacity(0.1);

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderCol),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    isWarning ? Icons.warning_amber_rounded : Icons.info_outline,
                    color: textCol,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          alert.title,
                          style: AppTextStyles.headlineSmall(context).copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: textCol,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          alert.message,
                          style: AppTextStyles.caption(context).copyWith(
                            color: textCol.withOpacity(0.85),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

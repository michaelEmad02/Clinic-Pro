import 'package:flutter/material.dart';
import '../themes/app_colors.dart';
import '../themes/app_text_styles.dart';
import '../constants/app_constants.dart';

class RealtimeIndicator extends StatelessWidget {
  final bool isConnected;

  const RealtimeIndicator({
    super.key,
    this.isConnected = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isConnected ? AppColors.accent : AppColors.danger,
            boxShadow: isConnected
                ? [
                    BoxShadow(
                      color: AppColors.accent.withOpacity(0.5),
                      blurRadius: 4,
                      spreadRadius: 1,
                    )
                  ]
                : null,
          ),
        ),
        const SizedBox(width: AppConstants.spaceXs),
        Text(
          isConnected ? 'متصل (مباشر)' : 'غير متصل',
          style: AppTextStyles.caption(context).copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

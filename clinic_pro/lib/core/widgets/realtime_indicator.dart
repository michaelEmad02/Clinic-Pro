import 'package:flutter/material.dart';
import '../themes/app_colors.dart';
import '../themes/app_text_styles.dart';
import '../constants/app_constants.dart';
import '../strings/app_strings.dart';

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
            color: isConnected ? context.accent : context.danger,
            boxShadow: isConnected
                ? [
                    BoxShadow(
                      color: context.accent.withOpacity(0.5),
                      blurRadius: 4,
                      spreadRadius: 1,
                    )
                  ]
                : null,
          ),
        ),
        const SizedBox(width: AppConstants.spaceXs),
        Text(
          isConnected ? AppStrings.availableNow : AppStrings.offline,
          style: AppTextStyles.caption(context).copyWith(
            color: context.textSecondary,
          ),
        ),
      ],
    );
  }
}

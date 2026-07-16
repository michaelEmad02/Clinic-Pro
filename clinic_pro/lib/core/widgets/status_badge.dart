import 'package:flutter/material.dart';
import '../themes/app_colors.dart';
import '../themes/app_text_styles.dart';
import '../constants/app_constants.dart';

enum BadgeStatus { success, warning, error, info }

class StatusBadge extends StatelessWidget {
  final String text;
  final BadgeStatus status;
  final bool addBackgroundColor;

  const StatusBadge({
    super.key,
    required this.text,
    required this.status,
    this.addBackgroundColor = true,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;

    switch (status) {
      case BadgeStatus.success:
        backgroundColor = addBackgroundColor
            ? context.accent.withOpacity(0.1)
            : Colors.transparent;
        textColor = context.accent;
        break;
      case BadgeStatus.warning:
        backgroundColor = addBackgroundColor
            ? context.warning.withOpacity(0.1)
            : Colors.transparent;
        textColor = context.warning;
        break;
      case BadgeStatus.error:
        backgroundColor = addBackgroundColor
            ? context.danger.withOpacity(0.1)
            : Colors.transparent;
        textColor = context.danger;
        break;
      case BadgeStatus.info:
        backgroundColor = addBackgroundColor
            ? context.primary.withOpacity(0.1)
            : Colors.transparent;
        textColor = context.primary;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceMd,
        vertical: AppConstants.spaceXs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusChip),
      ),
      child: Text(
        text,
        style: AppTextStyles.bodyMedium(context).copyWith(
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

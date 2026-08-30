import 'package:flutter/material.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/strings/app_strings.dart';

class ProgressIndicatorBar extends StatelessWidget {
  final int step;
  final int totalSteps;
  final String title;

  const ProgressIndicatorBar({
    super.key,
    required this.step,
    required this.totalSteps,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            RichText(
              text: TextSpan(
                text: AppStrings.step,
                style: AppTextStyles.headlineSmall(context).copyWith(
                  color: context.primary,
                ),
                children: [
                  TextSpan(
                    text: '$step',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(text: AppStrings.of),
                  TextSpan(
                    text: '$totalSteps',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              title,
              style: AppTextStyles.bodyMedium(context).copyWith(
                color: context.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: context.primary,
            borderRadius: BorderRadius.circular(4),
          ),
          alignment: Alignment.centerRight,
          child: FractionallySizedBox(
            widthFactor: (totalSteps > 0) ? (step / totalSteps).clamp(0.0, 1.0) : 0.0,
            child: Container(
              decoration: BoxDecoration(
                color: context.primary,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

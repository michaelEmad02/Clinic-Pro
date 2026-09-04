import 'package:flutter/material.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';

class PlanFeature {
  final String text;
  final bool included;
  final String? numericValue;

  const PlanFeature({
    required this.text,
    this.included = true,
    this.numericValue,
  });
}

class PlanCard extends StatelessWidget {
  final String title;
  final String price;
  final String priceSubtext;
  final List<PlanFeature> features;
  final bool isFeatured;
  final bool isCurrentPlan;
  final String? badgeText;
  final String buttonText;
  final VoidCallback onSelect;

  const PlanCard({
    super.key,
    required this.title,
    required this.price,
    required this.priceSubtext,
    required this.features,
    required this.buttonText,
    required this.onSelect,
    this.isFeatured = false,
    this.isCurrentPlan = false,
    this.badgeText,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Container(
      margin: (isFeatured || isCurrentPlan)
          ? const EdgeInsets.only(top: 0)
          : const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: isCurrentPlan
            ? (isDark ? context.successText.withOpacity(0.2) : context.successBg.withOpacity(0.35))
            : context.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrentPlan
              ? context.successText
              : isFeatured
                  ? context.primary
                  : context.borderColor,
          width: isCurrentPlan ? 3 : (isFeatured ? 2.5 : 1),
        ),
        boxShadow: [
          if (isCurrentPlan)
            BoxShadow(
              color: context.successText.withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 6),
            )
          else if (isFeatured)
            BoxShadow(
              color: isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          else
            BoxShadow(
              color: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: AppTextStyles.headlineMedium(context).copyWith(
                          color: isCurrentPlan
                              ? context.successText
                              : context.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    if (isCurrentPlan)
                      Icon(
                        Icons.check_circle_rounded,
                        color: context.successText,
                        size: 26,
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        price,
                        style: AppTextStyles.headlineLarge(context).copyWith(
                          color: isCurrentPlan ? context.successText : context.primary,
                          fontFamily: title == 'Enterprise' ? 'Cairo' : 'Inter',
                          fontWeight: FontWeight.w800,
                        ),
                        textDirection: TextDirection.ltr,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          priceSubtext,
                          style: AppTextStyles.caption(context).copyWith(
                            color: context.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ...features.map((e) => _buildFeature(e, context)),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: onSelect,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isCurrentPlan
                        ? context.successText
                        : (isFeatured ? context.primary : context.surfaceColor),
                    foregroundColor: isCurrentPlan || isFeatured
                        ? context.onPrimary
                        : context.primary,
                    elevation: isCurrentPlan || isFeatured ? 4 : 0,
                    shadowColor: isCurrentPlan
                        ? context.successText.withOpacity(0.4)
                        : (isFeatured
                            ? context.primaryContainer.withOpacity(0.4)
                            : null),
                    side: isCurrentPlan || isFeatured
                        ? null
                        : BorderSide(color: context.borderColor),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isCurrentPlan) ...[
                        const Icon(Icons.autorenew_rounded, size: 20),
                        const SizedBox(width: 6),
                      ],
                      Flexible(
                        child: Text(
                          buttonText,
                          style: AppTextStyles.bodyLarge(context).copyWith(
                            color: isCurrentPlan || isFeatured
                                ? context.onPrimary
                                : context.primary,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isCurrentPlan)
            Positioned(
              top: -14,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                  decoration: BoxDecoration(
                    color: context.successText,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: context.successText.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded,
                          size: 16, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        AppStrings.currentPlanBadge,
                        style: AppTextStyles.labelChip(context).copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else if (isFeatured && badgeText != null)
            Positioned(
              top: -12,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: context.primaryLightColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: context.primary.withOpacity(0.2)),
                  ),
                  child: Text(
                    badgeText!,
                    style: AppTextStyles.labelChip(context).copyWith(
                      color: context.primary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFeature(PlanFeature feature, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            feature.included ? Icons.check_circle : Icons.cancel,
            color: feature.included ? context.accent : context.danger,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    color: context.textPrimary),
                children: [
                  if (feature.numericValue != null)
                    TextSpan(
                      text: '${feature.numericValue} ',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  TextSpan(
                    text: feature.text,
                    style: TextStyle(
                      color: feature.included
                          ? context.textPrimary
                          : context.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

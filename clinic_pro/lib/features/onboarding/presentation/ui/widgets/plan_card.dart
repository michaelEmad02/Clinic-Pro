import 'package:flutter/material.dart';
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
    this.badgeText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: isFeatured
          ? const EdgeInsets.only(top: 0)
          : const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFeatured ? context.primary : context.border,
          width: isFeatured ? 2 : 1,
        ),
        boxShadow: [
          if (isFeatured)
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          else
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
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
                Text(
                  title,
                  style: AppTextStyles.headlineMedium(context).copyWith(
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      price,
                      style: AppTextStyles.headlineLarge(context).copyWith(
                        color: context.primary,
                        fontFamily: title == 'Enterprise' ? 'Cairo' : 'Inter',
                      ),
                      textDirection: TextDirection.ltr,
                    ),
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        priceSubtext,
                        style: AppTextStyles.caption(context).copyWith(
                          color: context.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ...features
                    .map(_buildFeature as Widget Function(PlanFeature e)),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: onSelect,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isFeatured ? context.primary : context.surface,
                    foregroundColor:
                        isFeatured ? context.onPrimary : context.primary,
                    elevation: isFeatured ? 4 : 0,
                    shadowColor: isFeatured
                        ? context.primaryContainer.withOpacity(0.4)
                        : null,
                    side: isFeatured ? null : BorderSide(color: context.border),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    buttonText,
                    style: AppTextStyles.headlineSmall(context).copyWith(
                      color: isFeatured ? context.onPrimary : context.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isFeatured && badgeText != null)
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
            color: feature.included ? context.successText : context.textHint,
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

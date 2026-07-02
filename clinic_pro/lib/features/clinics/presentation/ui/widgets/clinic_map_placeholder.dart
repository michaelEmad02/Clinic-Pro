// ────────────────────────────────────────────────────────
// عنصر نائب للخريطة في شاشة تفاصيل العيادة
// يعرض مكاناً وهمياً للخريطة مع زر "احصل على الاتجاهات"
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';

class ClinicMapPlaceholder extends StatelessWidget {
  const ClinicMapPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusButton),
        border: Border.all(color: AppColors.border),
        boxShadow: AppConstants.cardShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.radiusButton),
        child: Stack(
          children: [
            // خلفية وهمية للخريطة
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryLight,
                    AppColors.surfaceContainerLow,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.map_outlined,
                  size: 64,
                  color: AppColors.primary.withOpacity(0.3),
                ),
              ),
            ),
            // طبقة التدرج الداكن في الأسفل
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.5),
                      Colors.transparent,
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.directions_outlined,
                      color: AppColors.surface,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'احصل على الاتجاهات',
                      style: AppTextStyles.bodyMedium(context).copyWith(
                        color: AppColors.surface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

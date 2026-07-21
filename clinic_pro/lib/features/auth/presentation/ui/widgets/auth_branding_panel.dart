import 'package:flutter/material.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';

/// البنر الترويجي الجمالي الذي يستعرض هوية ClinicPro في الشاشات العريضة (Desktop / Tablet)
class AuthBrandingPanel extends StatelessWidget {
  final String? title;
  final String? subtitle;

  const AuthBrandingPanel({
    super.key,
    this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primaryContainer,
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
      child: Stack(
        children: [
          // عناصر خلفية جمالية ممتدة
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent.withOpacity(0.08),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppConstants.spaceXl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppConstants.spaceMd),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(AppConstants.radiusCard),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.medical_services_rounded,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: AppConstants.spaceLg),
                Text(
                  title ?? 'ClinicPro',
                  style: AppTextStyles.headlineLarge(context).copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppConstants.spaceSm),
                Text(
                  subtitle ?? AppStrings.welcomeGreeting,
                  style: AppTextStyles.bodyLarge(context).copyWith(
                    color: Colors.white.withOpacity(0.85),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: AppConstants.spaceXl),
                // ميزات سريعة (Features Badges)
                _buildFeatureItem(
                  context,
                  icon: Icons.shield_outlined,
                  text: 'نظام إدارة طاقم العيادات الذكي والموثوق',
                ),
                const SizedBox(height: AppConstants.spaceMd),
                _buildFeatureItem(
                  context,
                  icon: Icons.speed_outlined,
                  text: 'إدارة الطوابير والمواعيد بسرعة فائقة',
                ),
                const SizedBox(height: AppConstants.spaceMd),
                _buildFeatureItem(
                  context,
                  icon: Icons.cloud_done_outlined,
                  text: 'مزامنة فورية على كود ورعاية المرضى',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(BuildContext context, {required IconData icon, required String text}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppConstants.spaceSm),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: AppConstants.iconSizeLg,
            color: AppColors.accent,
          ),
        ),
        const SizedBox(width: AppConstants.spaceMd),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodyMedium(context).copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ),
      ],
    );
  }
}

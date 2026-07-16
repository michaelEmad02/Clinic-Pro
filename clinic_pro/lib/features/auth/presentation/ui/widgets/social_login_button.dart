import 'package:flutter/material.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';

enum SocialLoginType { google, apple }

class SocialLoginButton extends StatelessWidget {
  final SocialLoginType type;
  final VoidCallback onPressed;
  final String text;

  const SocialLoginButton({
    super.key,
    required this.type,
    required this.onPressed,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: type == SocialLoginType.google ? (context.isDarkMode ? AppColors.darkBackground : AppColors.surfaceContainerLow) : context.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: type == SocialLoginType.google ? Colors.transparent : context.borderColor,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIcon(context),
            const SizedBox(width: 8),
            Text(
              text,
              style: AppTextStyles.headlineSmall(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    if (type == SocialLoginType.google) {
      // Using SVG string or Icon data for Google. For now, a custom widget or an asset is preferred,
      // but to keep it simple without adding SVG assets, we can use a colored container or similar.
      // Since the design expects SVG, we can create a simple placeholder icon or use Google's colors.
      return const Icon(Icons.g_mobiledata, size: 28, color: Colors.blue);
    } else {
      return Icon(Icons.apple, size: 24, color: context.textPrimary);
    }
  }
}

// ────────────────────────────────────────────────────────
// عرض حالة الدعوة المنتهية أو المقبولة مسبقاً
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/constants/route_constants.dart';
import '../../../../../core/strings/app_strings.dart';

class InvitationExpiredView extends StatelessWidget {
  final String? message;
  final IconData icon;
  final Color? iconColor;

  const InvitationExpiredView({
    super.key,
    this.message,
    this.icon = Icons.timer_off_rounded,
    this.iconColor,
  });

  /// عرض حالة الدعوة المنتهية
  factory InvitationExpiredView.expired({String? message}) {
    return InvitationExpiredView(
      message: message,
      icon: Icons.timer_off_rounded,
    );
  }

  /// عرض حالة الدعوة المقبولة مسبقاً
  factory InvitationExpiredView.alreadyAccepted({String? message}) {
    return InvitationExpiredView(
      message: message,
      icon: Icons.check_circle_outline_rounded,
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColor = iconColor ?? context.warning;
    final defaultMessage = icon == Icons.check_circle_outline_rounded
        ? (AppStrings.isArabic
            ? 'تم قبول هذه الدعوة مسبقاً.\nيمكنك تسجيل الدخول مباشرة.'
            : 'This invitation has already been accepted.\nYou can log in directly.')
        : (AppStrings.isArabic
            ? 'انتهت صلاحية هذه الدعوة.\nيرجى التواصل مع مالك العيادة لإرسال دعوة جديدة.'
            : 'This invitation has expired.\nPlease contact the clinic owner for a new invite.');

    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spaceLg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // أيقونة الحالة
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: effectiveColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 64,
                    color: effectiveColor,
                  ),
                ),
                const SizedBox(height: AppConstants.spaceLg),

                // رسالة الحالة
                Text(
                  message ?? defaultMessage,
                  style: AppTextStyles.bodyLarge(context).copyWith(
                    color: context.textSecondary,
                    height: 1.8,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppConstants.spaceXl),

                // زر العودة لتسجيل الدخول
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      context.go(RouteConstants.login);
                    },
                    icon: const Icon(Icons.login_rounded),
                    label: Text(AppStrings.backToLogin),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: context.primary,
                      side: BorderSide(color: context.primary),
                      padding: const EdgeInsets.symmetric(
                        vertical: AppConstants.spaceMd,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppConstants.radiusButton,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

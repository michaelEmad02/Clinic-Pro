// ────────────────────────────────────────────────────────
// عرض حالة الدعوة المنتهية أو المقبولة مسبقاً
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/constants/route_constants.dart';

class InvitationExpiredView extends StatelessWidget {
  final String message;
  final IconData icon;
  final Color iconColor;

  const InvitationExpiredView({
    super.key,
    required this.message,
    this.icon = Icons.timer_off_rounded,
    this.iconColor = AppColors.warning,
  });

  /// عرض حالة الدعوة المنتهية
  factory InvitationExpiredView.expired({String? message}) {
    return InvitationExpiredView(
      message: message ?? 'انتهت صلاحية هذه الدعوة.\nيرجى التواصل مع مالك العيادة لإرسال دعوة جديدة.',
      icon: Icons.timer_off_rounded,
      iconColor: AppColors.warning,
    );
  }

  /// عرض حالة الدعوة المقبولة مسبقاً
  factory InvitationExpiredView.alreadyAccepted({String? message}) {
    return InvitationExpiredView(
      message: message ?? 'تم قبول هذه الدعوة مسبقاً.\nيمكنك تسجيل الدخول مباشرة.',
      icon: Icons.check_circle_outline_rounded,
      iconColor: AppColors.accent,
    );
  }

  @override
  Widget build(BuildContext context) {
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
                    color: iconColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 64,
                    color: iconColor,
                  ),
                ),
                const SizedBox(height: AppConstants.spaceLg),

                // رسالة الحالة
                Text(
                  message,
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
                    label: const Text('الذهاب لتسجيل الدخول'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: context.primary,
                      side:  BorderSide(color: context.primary),
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

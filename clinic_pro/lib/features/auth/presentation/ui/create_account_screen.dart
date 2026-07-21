import 'package:flutter/material.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/strings/app_strings.dart';
import '../../../../core/utils/responsive_helper.dart';
import 'widgets/auth_branding_panel.dart';
import 'widgets/account_form.dart';
import 'widgets/social_login_row.dart';
import 'dart:ui' as ui;

class CreateAccountScreen extends StatelessWidget {
  const CreateAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: isMobile
          ? _buildFormCard(context)
          : Row(
              children: [
                Expanded(
                  flex: 5,
                  child: AuthBrandingPanel(
                    title: AppStrings.createAccount,
                    subtitle: AppStrings.teamViaInvite,
                  ),
                ),
                Expanded(
                  flex: 6,
                  child: _buildFormCard(context),
                ),
              ],
            ),
    );
  }

  Widget _buildFormCard(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -40,
          right: -20,
          child: _buildBlurCircle(
              context.primaryContainer.withOpacity(0.1), 384),
        ),
        Positioned(
          bottom: -40,
          left: -20,
          child: _buildBlurCircle(
              context.accent.withOpacity(0.1), 288),
        ),
        Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: context.surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 24,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header Section
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: context.primaryLightColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons
                              .monitor_heart_outlined, // vital_signs approximate
                          color: context.primaryContainer,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppStrings.createAccount,
                        style: AppTextStyles.headlineLarge(context),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: context.isDarkMode
                              ? AppColors.darkBackground
                              : AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: context.borderColor),
                        ),
                        child: Text(
                          AppStrings.teamViaInvite,
                          style: AppTextStyles.caption(context).copyWith(
                            color: context.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Form Section
                      const AccountForm(),

                      const SizedBox(height: 24),

                      // Divider
                      Row(
                        children: [
                          Expanded(child: Divider(color: context.borderColor)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              AppStrings.orRegisterWith,
                              style: AppTextStyles.caption(context).copyWith(
                                color: context.textHint,
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: context.borderColor)),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // أزرار تسجيل الدخول الاجتماعي المشتركة
                      SocialLoginRow(
                        onGooglePressed: () {
                          // منطق تسجيل الدخول بـ Google عند إنشاء الحساب
                        },
                        onApplePressed: () {
                          // منطق تسجيل الدخول بـ Apple عند إنشاء الحساب
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      );
  }

  Widget _buildBlurCircle(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 40, sigmaY: 40),
        child: Container(color: Colors.transparent),
      ),
    );
  }
}

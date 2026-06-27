import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/constants/route_constants.dart';
import '../manager/auth_cubit.dart';
import '../manager/auth_state.dart';
import 'widgets/social_login_button.dart';
import 'widgets/magic_link_form.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo & Header
                  Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.15),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.medical_services,
                          size: 36,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'أهلاً بك',
                        style: AppTextStyles.headlineLarge(context),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'سجّل الدخول للوصول إلى لوحة تحكم عيادتك المتقدمة.',
                        style: AppTextStyles.bodyLarge(context).copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  // Social Login
                  SocialLoginButton(
                    type: SocialLoginType.google,
                    text: 'المتابعة باستخدام Google',
                    onPressed: () {
                      // TODO: Implement Google Sign In
                    },
                  ),
                  const SizedBox(height: 16),
                  SocialLoginButton(
                    type: SocialLoginType.apple,
                    text: 'المتابعة باستخدام Apple',
                    onPressed: () {
                      // TODO: Implement Apple Sign In
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Divider
                  Row(
                    children: [
                      const Expanded(child: Divider(color: AppColors.border)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'أو',
                          style: AppTextStyles.caption(context).copyWith(
                            color: AppColors.textHint,
                          ),
                        ),
                      ),
                      const Expanded(child: Divider(color: AppColors.border)),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Magic Link Form
                  MagicLinkForm(
                    onSubmit: (email) {
                      // TODO: Call Cubit to send magic link
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('تم إرسال الرابط إلى $email')),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Footer Link
                  Center(
                    child: TextButton(
                      onPressed: () {
                        context.push(RouteConstants.register);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'صاحب عيادة جديد؟ أنشئ حساباً',
                            style: AppTextStyles.headlineSmall(context).copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_forward, size: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

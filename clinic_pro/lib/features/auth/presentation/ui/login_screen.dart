import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/strings/app_strings.dart';
import '../../../../core/constants/staff_roles.dart';
import '../manager/auth_cubit.dart';
import '../manager/auth_state.dart';
import 'widgets/magic_link_form.dart';
import 'widgets/email_password_form.dart';
import 'widgets/auth_tab_selector.dart';
import 'widgets/social_login_row.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final ValueNotifier<int> _selectedTab = ValueNotifier<int>(0);

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        // عند نجاح تسجيل الدخول — التوجيه حسب الدور
        if (state is AuthAuthenticated) {
          final role = state.user.role;

          if (role == StaffRoles.owner) {
            context.go(RouteConstants.ownerDashboard);
          } else if (role == StaffRoles.doctor) {
            context.go(RouteConstants.doctorDashboard);
          } else if (role == StaffRoles.secretary) {
            context.go(RouteConstants.secretaryDashboard);
          }
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: context.backgroundColor,
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: context.surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) {
                    final isLoading = state is AuthLoading;

                    return Column(
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
                                color: context.primaryLightColor,
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
                              AppStrings.welcomeGreeting,
                              style: AppTextStyles.headlineLarge(context),
                            ),
                            // const SizedBox(height: 8),
                            // Text(
                            //   AppStrings.loginSubtitle,
                            //   style: AppTextStyles.bodyLarge(context).copyWith(
                            //     color: context.textSecondary,
                            //   ),
                            //   textAlign: TextAlign.center,
                            // ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // مؤشر التحميل عند الضغط
                        if (isLoading) ...[
                          const Center(child: CircularProgressIndicator()),
                          const SizedBox(height: 16),
                        ],

                        // أزرار تسجيل الدخول الاجتماعي
                        SocialLoginRow(
                          onGooglePressed: isLoading
                              ? () {}
                              : () {
                                  // context.read<AuthCubit>().login('sara@clinicpro.com', 'mock');
                                  context.read<AuthCubit>().loginWithGoogle();
                                },
                          onApplePressed: isLoading
                              ? () {}
                              : () {
                                  // context
                                  //     .read<AuthCubit>()
                                  //     .login('owner@clinicpro.com', 'mock');
                                  context.read<AuthCubit>().loginWithApple();
                                },
                        ),
                        const SizedBox(height: 24),

                        // Divider
                        Row(
                          children: [
                            Expanded(
                                child: Divider(color: context.borderColor)),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                AppStrings.orText,
                                style: AppTextStyles.caption(context).copyWith(
                                  color: AppColors.textHint,
                                ),
                              ),
                            ),
                            Expanded(
                                child: Divider(color: context.borderColor)),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // شريط التبديل بين البريد الإلكتروني والرابط السحري
                        ValueListenableBuilder<int>(
                          valueListenable: _selectedTab,
                          builder: (context, activeTab, child) {
                            return AuthTabSelector(
                              activeTab: activeTab,
                              onTabSelected: (index) {
                                _selectedTab.value = index;
                              },
                            );
                          },
                        ),

                        const SizedBox(height: 24),

                        // محتوى النموذج بناءً على التبويب النشط
                        ValueListenableBuilder<int>(
                          valueListenable: _selectedTab,
                          builder: (context, activeTab, child) {
                            if (activeTab == 0) {
                              return EmailPasswordForm(
                                onSubmit: isLoading
                                    ? (_, __) {}
                                    : (email, password) {
                                        context
                                            .read<AuthCubit>()
                                            .login(email, password);
                                      },
                              );
                            } else {
                              return MagicLinkForm(
                                onSubmit: isLoading
                                    ? (_) {}
                                    : (email) {
                                        context
                                            .read<AuthCubit>()
                                            .login(email, 'mock');
                                      },
                              );
                            }
                          },
                        ),

                        const SizedBox(height: 16),

                        // اختبار سريع: دخول كطبيب أو سكرتارية
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                              onPressed: isLoading
                                  ? null
                                  : () {
                                      context
                                          .read<AuthCubit>()
                                          .loginAsRole(StaffRoles.doctor);
                                    },
                              child: Text(
                                AppStrings.loginAsDoctor,
                                style: AppTextStyles.caption(context).copyWith(
                                  color: context.textSecondary,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text('|',
                                style: TextStyle(color: context.borderColor)),
                            const SizedBox(width: 8),
                            TextButton(
                              onPressed: isLoading
                                  ? null
                                  : () {
                                      context
                                          .read<AuthCubit>()
                                          .loginAsRole(StaffRoles.secretary);
                                    },
                              child: Text(
                                AppStrings.loginAsSecretary,
                                style: AppTextStyles.caption(context).copyWith(
                                  color: context.textSecondary,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Footer Link — إنشاء حساب جديد
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
                                  AppStrings.newClinicOwner,
                                  style: AppTextStyles.headlineSmall(context)
                                      .copyWith(
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
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

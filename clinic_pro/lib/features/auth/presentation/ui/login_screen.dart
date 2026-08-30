import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/strings/app_strings.dart';
import '../../../../core/constants/staff_roles.dart';
import '../manager/auth_cubit.dart';
import '../manager/auth_state.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_snackbar.dart';
import 'widgets/auth_branding_panel.dart';
import 'widgets/email_password_form.dart';
import 'widgets/social_login_row.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        // عند نجاح تسجيل الدخول — التوجيه حسب الدور
        if (state is AuthAuthenticated) {
          final role = state.user.role;

          if (role == StaffRoles.owner) {
            if (state.user.isNewUser) {
              context.go(RouteConstants.onboardingPlan);
            } else {
              context.go(RouteConstants.ownerDashboard);
            }
          } else if (role == StaffRoles.doctor) {
            context.go(RouteConstants.doctorDashboard);
          } else if (role == StaffRoles.secretary) {
            context.go(RouteConstants.secretaryDashboard);
          }
        } else if (state is AuthError) {
          AppSnackbar.error(context, message: state.message);
        }
      },
      child: Scaffold(
        backgroundColor: context.backgroundColor,
        body: isMobile
            ? _buildMobileContent(context)
            : Row(
                children: [
                  const Expanded(
                    flex: 5,
                    child: AuthBrandingPanel(),
                  ),
                  Expanded(
                    flex: 6,
                    child: _buildMobileContent(context),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildMobileContent(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            decoration: BoxDecoration(
              color: context.surfaceColor,
              borderRadius: BorderRadius.circular(AppConstants.radiusCard),
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
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: context.primaryLightColor,
                            borderRadius: BorderRadius.circular(AppConstants.radiusCard),
                            boxShadow: [
                              BoxShadow(
                                color: context.primary.withOpacity(0.15),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'images/logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          AppStrings.welcomeGreeting,
                          style: AppTextStyles.headlineLarge(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // مؤشر التحميل عند الضغط
                    if (isLoading) ...[
                      const Center(child: AppLoadingWidget()),
                      const SizedBox(height: 16),
                    ],

                    // أزرار تسجيل الدخول الاجتماعي
                    SocialLoginRow(
                      onGooglePressed: isLoading
                          ? () {}
                          : () {
                              context.read<AuthCubit>().loginWithGoogle();
                            },
                    ),
                    const SizedBox(height: 24),

                    // Divider
                    Row(
                      children: [
                        Expanded(child: Divider(color: context.borderColor)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            AppStrings.orText,
                            style: AppTextStyles.caption(context).copyWith(
                              color: context.textHint,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: context.borderColor)),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // نموذج تسجيل الدخول بالبريد الإلكتروني وكلمة المرور
                    EmailPasswordForm(
                      onSubmit: isLoading
                          ? (_, __) {}
                          : (email, password) {
                              context.read<AuthCubit>().login(email, password);
                            },
                    ),

                    const SizedBox(height: 16),

                    // Footer Link — إنشاء حساب جديد
                    Center(
                      child: TextButton(
                        onPressed: () {
                          context.push(RouteConstants.register);
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: context.primary,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                AppStrings.newClinicOwner,
                                style: AppTextStyles.headlineSmall(context)
                                    .copyWith(
                                  color: context.primary,
                                ),
                                overflow: TextOverflow.ellipsis,
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
    );
  }
}

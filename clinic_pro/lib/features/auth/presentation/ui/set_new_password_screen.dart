// ────────────────────────────────────────────────────────
// شاشة تعيين كلمة المرور الجديدة (SetNewPasswordScreen)
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/strings/app_strings.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../manager/auth_cubit.dart';
import '../manager/auth_state.dart';
import 'widgets/auth_branding_panel.dart';
import 'widgets/set_new_password_form.dart';

class SetNewPasswordScreen extends StatelessWidget {
  const SetNewPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthPasswordUpdatedSuccess) {
          AppSnackbar.success(
            context,
            message: AppStrings.passwordUpdatedSuccess,
          );
          context.go(RouteConstants.login);
        } else if (state is AuthError) {
          AppSnackbar.error(context, message: state.message);
        }
      },
      child: Scaffold(
        backgroundColor: context.backgroundColor,
        body: SafeArea(
          child: isMobile
              ? _buildMobileContent(context)
              : Row(
                  children: [
                    const Expanded(
                      flex: 5,
                      child: AuthBrandingPanel(
                        title: 'Clinic Pro',
                        subtitle: 'حماية وأمان بيانات عيادتك ومرضاك في المقام الأول دائماً.',
                      ),
                    ),
                    Expanded(
                      flex: 6,
                      child: _buildMobileContent(context),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildMobileContent(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.screenEdgeH,
          vertical: AppConstants.screenEdgeV,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 460,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spaceLg,
              vertical: AppConstants.spaceXl,
            ),
            decoration: BoxDecoration(
              color: context.surfaceColor,
              borderRadius: BorderRadius.circular(AppConstants.radiusCard),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
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
                    // الأيقونة والعنوان
                    Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: context.primaryLightColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.12),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.key_rounded,
                            size: 40,
                            color: context.primary,
                          ),
                        ),
                        const SizedBox(height: AppConstants.spaceMd),
                        Text(
                          AppStrings.setNewPasswordTitle,
                          style: AppTextStyles.headlineLarge(context),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppConstants.spaceSm),
                        Text(
                          AppStrings.setNewPasswordSubtitle,
                          style: AppTextStyles.caption(context).copyWith(
                            color: context.textSecondary,
                            fontSize: 13,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.spaceLg),

                    // مؤشر التحميل
                    if (isLoading) ...[
                      const Center(child: AppLoadingWidget()),
                      const SizedBox(height: AppConstants.spaceMd),
                    ],

                    // نموذج إدخال وتأكيد كلمة المرور
                    SetNewPasswordForm(
                      isLoading: isLoading,
                      onSubmit: (newPassword) {
                        context.read<AuthCubit>().updatePassword(newPassword);
                      },
                    ),

                    const SizedBox(height: AppConstants.spaceMd),

                    // زر العودة لتسجيل الدخول
                    Center(
                      child: TextButton(
                        onPressed: isLoading
                            ? null
                            : () => context.go(RouteConstants.login),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.spaceMd,
                            vertical: AppConstants.spaceSm,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.arrow_back, size: 16),
                            const SizedBox(width: AppConstants.spaceXs),
                            Flexible(
                              child: Text(
                                AppStrings.backToLogin,
                                style: AppTextStyles.headlineSmall(context)
                                    .copyWith(
                                  color: AppColors.primary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
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

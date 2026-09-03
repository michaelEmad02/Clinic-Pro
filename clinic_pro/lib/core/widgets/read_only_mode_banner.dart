// ────────────────────────────────────────────────────────
// شريط تنبيه وضع القراءة فقط (ReadOnlyModeBanner)
// يظهر أعلى الشاشات والداشبورد عند انتهاء الاشتراك لتنبيه المستخدم مع زر للتجديد
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_constants.dart';
import '../constants/route_constants.dart';
import '../strings/app_strings.dart';
import '../themes/app_colors.dart';
import '../themes/app_text_styles.dart';
import '../../features/auth/presentation/manager/auth_cubit.dart';
import '../../features/auth/presentation/manager/auth_state.dart';

class ReadOnlyModeBanner extends StatelessWidget {
  const ReadOnlyModeBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      buildWhen: (prev, curr) {
        final prevReadOnly = prev is AuthAuthenticated && prev.isReadOnlyMode;
        final currReadOnly = curr is AuthAuthenticated && curr.isReadOnlyMode;
        return prevReadOnly != currReadOnly;
      },
      builder: (context, state) {
        final isReadOnly = state is AuthAuthenticated && state.isReadOnlyMode;
        if (!isReadOnly) {
          return const SizedBox.shrink();
        }

        final isArabic = AppStrings.isArabic;

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(
            AppConstants.spaceMd,
            AppConstants.spaceSm,
            AppConstants.spaceMd,
            AppConstants.spaceSm,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spaceMd,
            vertical: AppConstants.spaceSm + 2,
          ),
          decoration: BoxDecoration(
            color: context.warningBg.withOpacity(0.85),
            borderRadius: BorderRadius.circular(AppConstants.radiusCard),
            border: Border.all(
              color: context.warning.withOpacity(0.4),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: context.warning.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 600;

              final textWidget = Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: context.warning.withOpacity(0.18),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.visibility_outlined,
                      size: 20,
                      color: context.warning,
                    ),
                  ),
                  const SizedBox(width: AppConstants.spaceSm + 2),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isArabic
                              ? 'أنت تتصفح في وضع القراءة فقط 👁️'
                              : 'You are browsing in Read-Only Mode 👁️',
                          style: AppTextStyles.bodyMedium(context).copyWith(
                            fontWeight: FontWeight.bold,
                            color: context.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isArabic
                              ? 'انتهت فترة الاشتراك. لتسجيل بيانات جديدة وإجراء التعديلات، يرجى تجديد الاشتراك.'
                              : 'Your subscription has expired. Adding and editing records is restricted until renewal.',
                          style: AppTextStyles.bodyMedium(context).copyWith(
                            color: context.textSecondary,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );

              final actionButton = ElevatedButton.icon(
                onPressed: () => context.push(RouteConstants.plansComparison),
                icon: const Icon(Icons.stars_rounded, size: 18, color: Colors.white),
                label: Text(
                  isArabic ? 'تجديد الاشتراك الآن' : 'Renew Subscription',
                  style: AppTextStyles.bodyMedium(context).copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spaceMd,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusButton),
                  ),
                  elevation: 1,
                ),
              );

              if (isCompact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    textWidget,
                    const SizedBox(height: AppConstants.spaceSm + 2),
                    actionButton,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: textWidget),
                  const SizedBox(width: AppConstants.spaceMd),
                  actionButton,
                ],
              );
            },
          ),
        );
      },
    );
  }
}

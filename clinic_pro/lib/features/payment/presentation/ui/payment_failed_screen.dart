// ────────────────────────────────────────────────────────
// شاشة فشل عملية الدفع (PaymentFailedScreen)
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/strings/app_strings.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../plans_and_subscriptions/domain/entities/company_info_entity.dart';
import '../../../plans_and_subscriptions/domain/entities/plan_entity.dart';

class PaymentFailedScreen extends StatelessWidget {
  final String message;
  final PlanEntity? plan;
  final String? subscriptionType;
  final CompanyInfoEntity? companyInfo;

  const PaymentFailedScreen({
    super.key,
    required this.message,
    this.plan,
    this.subscriptionType,
    this.companyInfo,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: context.backgroundColor,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.spaceLg),
              child: ResponsiveHelper.responsiveCenter(
                maxWidth: 500,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // أيقونة الفشل
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: context.danger.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.error_outline_rounded,
                        color: context.danger,
                        size: 64,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spaceLg),

                    Text(
                      AppStrings.paymentIncompleteTitle,
                      style: AppTextStyles.headlineMedium(context).copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppConstants.spaceSm),

                    Text(
                      message.isNotEmpty
                          ? message
                          : AppStrings.unexpectedPaymentError,
                      style: AppTextStyles.bodyMedium(context).copyWith(
                        color: context.textSecondary,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppConstants.spaceXl),

                    // زر إعادة المحاولة
                    if (plan != null && subscriptionType != null) ...[
                      ElevatedButton.icon(
                        onPressed: () {
                          context.pushReplacement(
                            RouteConstants.paymentMethods,
                            extra: {
                              'targetPlan': plan,
                              'subscriptionType': subscriptionType,
                              'companyInfo': companyInfo,
                            },
                          );
                        },
                        icon: const Icon(Icons.refresh_rounded),
                        label: Flexible(
                          child: Text(
                            AppStrings.retryAnotherMethod,
                            style: AppTextStyles.bodyMedium(context).copyWith(
                              fontWeight: FontWeight.bold,
                              color: context.onPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.primary,
                          foregroundColor: context.onPrimary,
                          minimumSize: const Size(double.infinity, 52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppConstants.radiusButton),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppConstants.spaceMd),
                    ],

                    // زر التحويل للتواصل اليدوي عبر واتساب (Fallback)
                    OutlinedButton.icon(
                      onPressed: () {
                        context.pushReplacement(
                          RouteConstants.pendingSubscription,
                          extra: {
                            'plan': plan,
                            'subscriptionType': subscriptionType,
                            'companyInfo': companyInfo,
                          },
                        );
                      },
                      icon: const Icon(Icons.chat_bubble_outline_rounded),
                      label: Flexible(
                        child: Text(
                          AppStrings.contactSupportWhatsAppManual,
                          style: AppTextStyles.bodyMedium(context).copyWith(
                            color: context.primary,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: context.primary,
                        minimumSize: const Size(double.infinity, 50),
                        side: BorderSide(color: context.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppConstants.radiusButton),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppConstants.spaceMd),

                    // العودة للخطط
                    TextButton(
                      onPressed: () {
                        context.go(RouteConstants.plansComparison);
                      },
                      child: Text(
                        AppStrings.backToPlansSelection,
                        style: AppTextStyles.bodyMedium(context).copyWith(
                          color: context.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

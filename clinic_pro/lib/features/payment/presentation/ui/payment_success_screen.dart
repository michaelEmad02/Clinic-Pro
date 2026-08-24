// ────────────────────────────────────────────────────────
// شاشة نجاح الدفع وتفعيل الاشتراك (PaymentSuccessScreen)
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/widgets/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/strings/app_strings.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../plans_and_subscriptions/domain/entities/plan_entity.dart';
import '../../domain/entities/payment_status_entity.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final PaymentStatusEntity statusResult;
  final PlanEntity plan;
  final String subscriptionType;

  const PaymentSuccessScreen({
    super.key,
    required this.statusResult,
    required this.plan,
    required this.subscriptionType,
  });

  String _getCycleTitle() {
    switch (subscriptionType) {
      case 'yearly':
        return AppStrings.yearlyLabel;
      case 'lifetime':
        return AppStrings.lifetimeLabel;
      default:
        return AppStrings.monthlyLabel;
    }
  }

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
                    // أنيميشن / أيقونة الحالة (نجاح أم انتظار سداد فوري)
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: (statusResult.isPending ||
                                (statusResult.fawryCode ?? '').isNotEmpty)
                            ? Colors.amber.withOpacity(0.15)
                            : context.accent.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        (statusResult.isPending ||
                                (statusResult.fawryCode ?? '').isNotEmpty)
                            ? Icons.pending_actions_rounded
                            : Icons.check_circle_rounded,
                        color: (statusResult.isPending ||
                                (statusResult.fawryCode ?? '').isNotEmpty)
                            ? Colors.amber
                            : context.accent,
                        size: 64,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spaceLg),

                    Text(
                      (statusResult.isPending ||
                              (statusResult.fawryCode ?? '').isNotEmpty)
                          ? 'طلب الدفع قيد الانتظار'
                          : AppStrings.paymentSuccessTitle,
                      style: AppTextStyles.headlineMedium(context).copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppConstants.spaceSm),

                    Text(
                      (statusResult.isPending ||
                              (statusResult.fawryCode ?? '').isNotEmpty)
                          ? 'تم إصدار كود فوري بنجاح، يرجى السداد في أقرب ماكينة فوري لتفعيل الاشتراك تلقائياً'
                          : AppStrings.paymentSuccessDesc(
                              plan.name.toUpperCase(),
                              _getCycleTitle(),
                            ),
                      style: AppTextStyles.bodyMedium(context).copyWith(
                        color: context.textSecondary,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppConstants.spaceXl),

                    // حالة طلب دفع فوري المعلق
                    if ((statusResult.fawryCode ?? '').isNotEmpty) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppConstants.spaceLg),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.amber, width: 1.5),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.storefront_rounded,
                                    color: Colors.amber, size: 28),
                                const SizedBox(width: 8),
                                Text(
                                  'كود الدفع في فوري (Fawry Code)',
                                  style: AppTextStyles.headlineSmall(context)
                                      .copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            SelectableText(
                              statusResult.fawryCode!,
                              style:
                                  AppTextStyles.headlineLarge(context).copyWith(
                                fontWeight: FontWeight.bold,
                                color: context.primary,
                                letterSpacing: 2.0,
                              ),
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                              onPressed: () {
                                Clipboard.setData(ClipboardData(
                                    text: statusResult.fawryCode!));
                                AppSnackbar.success(context,
                                    message: 'تم نسخ كود فوري بنجاح!');
                              },
                              icon: const Icon(Icons.copy_rounded),
                              label: const Text('نسخ كود فوري'),
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      AppConstants.radiusButton),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppConstants.spaceLg),
                    ],

                    // بطاقة تفاصيل الاشتراك
                    Container(
                      padding: const EdgeInsets.all(AppConstants.spaceMd),
                      decoration: BoxDecoration(
                        color: context.surfaceColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: context.borderColor),
                      ),
                      child: Column(
                        children: [
                          _buildDetailRow(
                            context,
                            AppStrings.selectedPlanLabel,
                            plan.name.toUpperCase(),
                          ),
                          const Divider(height: 20),
                          _buildDetailRow(
                            context,
                            AppStrings.billingCyclePrefix,
                            _getCycleTitle(),
                          ),
                          const Divider(height: 20),
                          _buildDetailRow(
                            context,
                            AppStrings.paidAmountLabel,
                            '${statusResult.amount.toInt()} ${statusResult.currency}',
                          ),
                          if ((statusResult.referenceNumber ?? '')
                              .isNotEmpty) ...[
                            const Divider(height: 20),
                            _buildDetailRow(
                              context,
                              'رقم الطلب المرجعي (Merchant Order ID)',
                              statusResult.referenceNumber!,
                            ),
                          ],
                          if ((statusResult.gatewayOrderId ?? '')
                              .isNotEmpty) ...[
                            const Divider(height: 20),
                            _buildDetailRow(
                              context,
                              'رقم طلب Paymob',
                              statusResult.gatewayOrderId!,
                            ),
                          ] else if ((statusResult.referenceNumber ?? '')
                              .isEmpty) ...[
                            const Divider(height: 20),
                            _buildDetailRow(
                              context,
                              AppStrings.transactionNumberLabel,
                              statusResult.transactionId,
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: AppConstants.spaceXl),

                    // زر الانتقال للوحة التحكم
                    ElevatedButton.icon(
                      onPressed: () {
                        if ((statusResult.fawryCode ?? '').isNotEmpty) {
                        context.go(RouteConstants.paymentMethods,extra: {
                              'targetPlan': plan,
                              'subscriptionType': subscriptionType,
                              
                            },);
                        } else {
                          context.go(RouteConstants.ownerDashboard);
                        }
                      },
                      icon: const Icon(Icons.dashboard_rounded),
                      label: Flexible(
                        child: Text(
                            (statusResult.fawryCode != null && statusResult.fawryCode!.isNotEmpty )? AppStrings.isArabic? "دفع بطريقه اخري" : "Pay with another method" : AppStrings.goToDashboard,
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
                          borderRadius:
                              BorderRadius.circular(AppConstants.radiusButton),
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

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium(context).copyWith(
            color: context.textSecondary,
          ),
        ),
        const SizedBox(width: AppConstants.spaceMd),
        Expanded(
          child: SelectableText(
            value,
            style: AppTextStyles.bodyMedium(context).copyWith(
              fontWeight: FontWeight.bold,
              color: context.textPrimary,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

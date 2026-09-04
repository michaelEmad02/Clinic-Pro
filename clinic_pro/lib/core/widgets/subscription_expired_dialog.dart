// ────────────────────────────────────────────────────────
// نافذة تنبيه انتهاء الاشتراك (SubscriptionExpiredDialog)
// تظهر عندما يتم إرجاع خطأ SUBSCRIPTION_EXPIRED أو NO_SUBSCRIPTION
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:clinic_pro/core/constants/app_constants.dart';
import 'package:clinic_pro/core/constants/route_constants.dart';
import 'package:clinic_pro/core/error/failures.dart';
import 'package:clinic_pro/core/error/query_failure.dart';
import 'package:clinic_pro/core/strings/app_strings.dart';
import 'package:clinic_pro/core/themes/app_colors.dart';
import 'package:clinic_pro/core/themes/app_text_styles.dart';
import 'package:clinic_pro/core/utils/responsive_helper.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clinic_pro/core/constants/staff_roles.dart';
import '../../features/auth/presentation/manager/auth_cubit.dart';

class SubscriptionExpiredDialog extends StatelessWidget {
  final String? message;
  final bool isNoSubscription;

  const SubscriptionExpiredDialog({
    super.key,
    this.message,
    this.isNoSubscription = false,
  });

  /// فحص ومعالجة الخطأ تلقائياً:
  /// إذا كان الخطأ متعلقاً بانتهاء أو غياب الاشتراك، يُعرض الـ Dialog ويعيد true
  /// خلاف ذلك يعيد false ليتمكن المطور من معالجة الأخطاء العادية
  static bool handleIfSubscriptionFailure(BuildContext context, Failure failure) {
    if (failure is SubscriptionExpiredFailure) {
      show(context, message: failure.message, isNoSubscription: false);
      return true;
    } else if (failure is NoSubscriptionFailure) {
      show(context, message: failure.message, isNoSubscription: true);
      return true;
    }
    return false;
  }

  /// إظهار نافذة التنبيه
  static Future<void> show(
    BuildContext context, {
    String? message,
    bool isNoSubscription = false,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => SubscriptionExpiredDialog(
        message: message,
        isNoSubscription: isNoSubscription,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = AppStrings.isArabic;
    final isOwner =
        context.read<AuthCubit>().state.user?.role == StaffRoles.owner;

    final defaultTitle = isNoSubscription
        ? (isArabic ? 'لا يوجد اشتراك مفعل' : 'No Active Subscription')
        : (isArabic ? 'انتهت فترة الاشتراك' : 'Subscription Expired');

    final defaultDescription = message ??
        (isOwner
            ? (isNoSubscription
                ? (isArabic
                    ? 'لا يوجد اشتراك نشط مسجل لحسابك. للاستمرار في إضافة وتعديل البيانات، يرجى اختيار باقة وتفعيل الاشتراك.'
                    : 'There is no active subscription for this account. Please subscribe to a plan to continue managing your clinic.')
                : (isArabic
                    ? 'انتهت صلاحية اشتراكك الحالي. لا يمكن إجراء عمليات الإضافة أو التعديل حتى يتم تجديد الاشتراك.'
                    : 'Your current subscription has expired. Adding or editing records is temporarily disabled until renewal.'))
            : (isNoSubscription
                ? (isArabic
                    ? 'لا يوجد اشتراك نشط مسجل للعيادة. لا يمكن إجراء عمليات الإضافة أو التعديل حتى يقوم مالك العيادة بتفعيل الاشتراك.'
                    : 'There is no active subscription for this clinic. Adding or editing records is disabled until the owner activates a plan.')
                : (isArabic
                    ? 'انتهت صلاحية اشتراك العيادة. لا يمكن إجراء عمليات الإضافة أو التعديل حتى يقوم مالك العيادة بتجديد الاشتراك.'
                    : 'The clinic subscription has expired. Adding or editing records is disabled until the owner renews it.')));

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceMd,
        vertical: AppConstants.spaceLg,
      ),
      child: ResponsiveHelper.responsiveCenter(
        maxWidth: 440,
        child: Container(
          padding: const EdgeInsets.all(AppConstants.spaceLg),
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: BorderRadius.circular(AppConstants.radiusCard * 1.5),
            border: Border.all(
              color: context.danger.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: context.danger.withOpacity(0.08),
                blurRadius: 28,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
              // 1. أيقونة التنبيه
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: context.dangerBg,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: context.danger.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.lock_clock_outlined,
                  size: 34,
                  color: context.danger,
                ),
              ),
              const SizedBox(height: AppConstants.spaceLg),

              // 2. العنوان
              Text(
                defaultTitle,
                style: AppTextStyles.headlineSmall(context).copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.spaceSm),

              // 3. الرسالة التوضيحية
              Text(
                defaultDescription,
                style: AppTextStyles.bodyMedium(context).copyWith(
                  color: context.textSecondary,
                  height: 1.45,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.spaceLg + 4),

              // 4. أزرار الإجراء
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (isOwner) ...[
                    // زر الانتقال للباقات والتجديد (للمالك فقط)
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppConstants.radiusButton),
                        ),
                      ),
                      icon: const Icon(Icons.stars_rounded, size: 20),
                      label: Text(
                        isArabic
                            ? 'تجديد أو ترقية الاشتراك'
                            : 'Renew / Upgrade Subscription',
                        style: AppTextStyles.bodyLarge(context).copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        context.push(RouteConstants.plansComparison);
                      },
                    ),
                    const SizedBox(height: AppConstants.spaceSm),

                    // زر الإغلاق
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        isArabic ? 'لاحقاً' : 'Later',
                        style: AppTextStyles.bodyMedium(context).copyWith(
                          color: context.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ] else ...[
                    // زر الإغلاق/الفهم لطاقم العيادة (طبيب / سكرتير)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppConstants.radiusButton),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        isArabic ? 'حسناً، فهمت' : 'OK, Understood',
                        style: AppTextStyles.bodyLarge(context).copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }
}

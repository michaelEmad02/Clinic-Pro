// ────────────────────────────────────────────────────────
// ودجت شاشة القفل الفخمة (FeatureLockedPaywallWidget)
// تظهر للمستخدم عندما يسترجع السيرفر خطأ عدم توفر الصلاحية في باقة اشتراكه
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clinic_pro/core/constants/app_constants.dart';
import 'package:clinic_pro/core/constants/route_constants.dart';
import 'package:clinic_pro/core/constants/staff_roles.dart';
import 'package:clinic_pro/core/strings/app_strings.dart';
import 'package:clinic_pro/core/themes/app_colors.dart';
import 'package:clinic_pro/core/themes/app_text_styles.dart';
import 'package:clinic_pro/core/utils/responsive_helper.dart';
import 'package:clinic_pro/features/auth/presentation/manager/auth_cubit.dart';
import 'package:go_router/go_router.dart';

class FeatureLockedPaywallWidget extends StatelessWidget {
  final String featureName;
  final String? featureKey;
  final VoidCallback? onUpgradeTap;

  const FeatureLockedPaywallWidget({
    super.key,
    required this.featureName,
    this.featureKey,
    this.onUpgradeTap,
  });

  @override
  Widget build(BuildContext context) {
    final isArabic = AppStrings.isArabic;

    // التحقق مما إذا كان المستخدم ممارساً كمالك للعيادة (Owner)
    bool isOwner = false;
    try {
      final authState = context.read<AuthCubit>().state;
      final user = authState.user;
      final originalRole = context.read<AuthCubit>().originalRole;
      isOwner = user?.role == StaffRoles.owner || originalRole == StaffRoles.owner;
    } catch (_) {
      isOwner = false; // Fallback default
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spaceLg),
        child: ResponsiveHelper.responsiveCenter(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Container(
              padding: const EdgeInsets.all(AppConstants.spaceLg),
              decoration: BoxDecoration(
                color: context.surfaceColor,
                borderRadius: BorderRadius.circular(AppConstants.radiusCard * 1.5),
                border: Border.all(color: context.primary.withOpacity(0.2), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: context.primary.withOpacity(0.08),
                    blurRadius: 24,
                    spreadRadius: 4,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 🔒 أيقونة القفل الفاخرة
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          context.dangerBg,
                          context.dangerBg,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Icon(
                      Icons.error_rounded,
                      size: 40,
                      color: context.danger,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spaceLg),

                  // 🏷️ العنوان
                  Text(
                    isArabic ? 'هذه الخدمة غير مفعّلة بباقتك' : 'Feature Not Included',
                    style: AppTextStyles.headlineSmall(context).copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppConstants.spaceSm),

                  // 📝 النص التوضيحي
                  Text(
                    isArabic
                        ? (isOwner
                            ? 'خدمة ($featureName) متوفرة في الباقات الاعلي. قم بترقية اشتراكك الآن للاستفادة منها ومن كافة التحليلات والتقارير الفائقة.'
                            : 'خدمة ($featureName) غير مفعّلة حالياً في باقة هذه العيادة. يرجى التواصل مع مالك العيادة لترقية الباقة.')
                        : (isOwner
                            ? 'The ($featureName) service is available on higher plans. Upgrade your subscription to unlock this feature.'
                            : 'The ($featureName) service is not enabled for this clinic. Please contact the clinic owner to upgrade.'),
                    style: AppTextStyles.bodyMedium(context).copyWith(
                      color: context.textSecondary,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  // 🚀 زر الترقية الفخم للمالك فقط
                  if (isOwner) ...[
                    const SizedBox(height: AppConstants.spaceLg),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: onUpgradeTap ??
                            () {
                              context.push(RouteConstants.plansComparison);
                            },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppConstants.radiusCard),
                          ),
                          elevation: 4,
                        ),
                        icon: const Icon(Icons.workspace_premium_rounded, size: 22),
                        label: Text(
                          isArabic ? 'ترقية الباقة الآن ⚡' : 'Upgrade Plan Now ⚡',
                          style: AppTextStyles.bodyLarge(context).copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

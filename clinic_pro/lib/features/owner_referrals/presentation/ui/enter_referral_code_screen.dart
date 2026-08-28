// ─────────────────────────────────────────────────────────────────────────────
// شاشة إدخال كود الدعوة والترحيب بالأطباء الجدد (Enter Referral Code Screen)
// تظهر كخطوة أولى بعد تسجيل الحساب لتطبيق كود دعوة زميله أو التخطي لاختيار الخطة
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:clinic_pro/core/constants/app_constants.dart';
import 'package:clinic_pro/core/constants/route_constants.dart';
import 'package:clinic_pro/core/di/injection_container.dart';
import 'package:clinic_pro/core/strings/app_strings.dart';
import 'package:clinic_pro/core/themes/app_colors.dart';
import 'package:clinic_pro/core/themes/app_text_styles.dart';
import 'package:clinic_pro/core/utils/responsive_helper.dart';
import 'package:clinic_pro/core/widgets/app_loading.dart';
import 'package:clinic_pro/core/widgets/app_snackbar.dart';
import 'package:clinic_pro/features/auth/presentation/manager/auth_cubit.dart';
import 'package:clinic_pro/features/owner_referrals/domain/entities/apply_referral_result_entity.dart';
import 'package:clinic_pro/features/owner_referrals/presentation/manager/referral_cubit.dart';
import 'package:clinic_pro/features/owner_referrals/presentation/manager/referral_state.dart';

class EnterReferralCodeScreen extends StatelessWidget {
  const EnterReferralCodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ReferralCubit>(),
      child: const _EnterReferralCodeBody(),
    );
  }
}

class _EnterReferralCodeBody extends StatefulWidget {
  const _EnterReferralCodeBody();

  @override
  State<_EnterReferralCodeBody> createState() => _EnterReferralCodeBodyState();
}

class _EnterReferralCodeBodyState extends State<_EnterReferralCodeBody> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkClipboardForReferral();
  }

  /// فحص الحافظة تلقائياً لاكتشاف كود الدعوة إذا نسخه الطبيب
  Future<void> _checkClipboardForReferral() async {
    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      final text = clipboardData?.text?.trim() ?? '';
      final regExp = RegExp(r'^DOC-[A-Z0-9]{4,10}$', caseSensitive: false);
      if (regExp.hasMatch(text) && mounted) {
        setState(() {
          _controller.text = text.toUpperCase();
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSkip() {
    context.go(RouteConstants.onboardingPlan);
  }

  Future<void> _submitCode() async {
    final code = _controller.text.trim().toUpperCase();
    if (code.isEmpty) {
      AppSnackbar.error(
        context,
        message: AppStrings.enterReferralCodePrompt,
      );
      return;
    }

    final ownerId = context.read<AuthCubit>().state.user?.id ?? '';
    if (ownerId.isEmpty) {
      AppSnackbar.error(
        context,
        message: 'تعذر تحديد بيانات المستخدم',
      );
      return;
    }

    setState(() => _isLoading = true);
    final result = await context.read<ReferralCubit>().applyReferralCode(
          referralCode: code,
          newOwnerId: ownerId,
        );
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result != null && result.success) {
      AppSnackbar.success(
        context,
        message: result.message,
      );

      // التوجيه الذكي لشاشة الباقات مع تمرير الكود المنشأ
      _navigateAfterSuccess(result);
    }
  }

  void _navigateAfterSuccess(ApplyReferralResultEntity result) {
    // الانتقال لشاشة الباقات مع تمرير الكود المطبق
    context.go(
      RouteConstants.onboardingPlan,
      extra: {
        'initialCouponCode': result.couponCode,
        'referralResult': result,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: SafeArea(
        child: BlocListener<ReferralCubit, ReferralState>(
          listener: (context, state) {
            if (state is ReferralError) {
              AppSnackbar.error(context, message: state.message);
            }
          },
          child: ResponsiveHelper.responsiveCenter(
            maxWidth: AppConstants.maxDialogWidth,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.screenEdgeH,
                vertical: AppConstants.screenEdgeV,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 24),
                  // أيقونة الهدية الترحيبية المميزة
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: context.primary.withOpacity(0.12),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: context.primary.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        TablerIcons.gift,
                        color: context.primary,
                        size: 46,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // عنوان الترحيب
                  Text(
                    'أهلاً بك في Clinic Pro! 🎉',
                    style: AppTextStyles.headlineLarge(context).copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  Text(
                    'هل تمت دعوتك بواسطة زميل؟ أدخل كود الدعوة للحصول على هديتك الترحيبية المخصصة.',
                    style: AppTextStyles.bodyMedium(context).copyWith(
                      color: context.textSecondary,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // كارت إدخال الكود
                  Container(
                    padding: const EdgeInsets.all(AppConstants.spaceLg),
                    decoration: BoxDecoration(
                      color: context.surfaceColor,
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusCard),
                      border: Border.all(color: context.borderColor),
                      boxShadow: AppConstants.cardShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'كود الدعوة',
                          style: AppTextStyles.bodyMedium(context).copyWith(
                            fontWeight: FontWeight.bold,
                            color: context.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _controller,
                          textCapitalization: TextCapitalization.characters,
                          style: AppTextStyles.headlineSmall(context).copyWith(
                            letterSpacing: 2,
                            fontWeight: FontWeight.bold,
                            color: context.primary,
                          ),
                          decoration: InputDecoration(
                            hintText: 'DOC-XXXXX',
                            hintStyle:
                                AppTextStyles.bodyLarge(context).copyWith(
                              color: context.textHint,
                              letterSpacing: 1.5,
                            ),
                            prefixIcon: Icon(
                              TablerIcons.ticket,
                              color: context.primary,
                            ),
                            filled: true,
                            fillColor: context.surface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                  AppConstants.radiusButton),
                              borderSide:
                                  BorderSide(color: context.borderColor),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                  AppConstants.radiusButton),
                              borderSide:
                                  BorderSide(color: context.borderColor),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                  AppConstants.radiusButton),
                              borderSide: BorderSide(
                                  color: context.primary, width: 1.5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _submitCode,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: context.primary,
                            foregroundColor: context.onPrimary,
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  AppConstants.radiusButton),
                            ),
                          ),
                          child: _isLoading
                              ? AppLoadingWidget(
                                  size: AppLoadingSize.small,
                                  color: context.onPrimary,
                                )
                              : Text(
                                  'تطبيق كود الدعوة والحصول على الهدية',
                                  style: AppTextStyles.bodyMedium(context)
                                      .copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: context.onPrimary,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // زر التخطي
                  TextButton.icon(
                    onPressed: _onSkip,
                    icon: Icon(
                      Icons.arrow_back_ios,
                      size: 14,
                      color: context.textSecondary,
                    ),
                    label: Text(
                      'ليس لدي كود دعوة (تخطي إلى الباقات)',
                      style: AppTextStyles.bodyMedium(context).copyWith(
                        color: context.textSecondary,
                        fontWeight: FontWeight.w600,
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

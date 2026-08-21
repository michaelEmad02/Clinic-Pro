// ────────────────────────────────────────────────────────
// شاشة انتظار وتأكيد الاشتراك بعد الطلب (PendingSubscriptionScreen)
// تمنع المالك من الوصول للعيادة حتى تفعيل الاشتراك مع زر الفحص المباشر
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/strings/app_strings.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../auth/presentation/manager/auth_cubit.dart';
import '../../domain/entities/company_info_entity.dart';
import '../../domain/entities/plan_entity.dart';
import '../manager/subscriptions_cubit.dart';
import '../manager/subscriptions_state.dart';

class PendingSubscriptionScreen extends StatelessWidget {
  final PlanEntity? plan;
  final String? subscriptionType;
  final CompanyInfoEntity? companyInfo;
  final bool isExpired;

  const PendingSubscriptionScreen({
    super.key,
    this.plan,
    this.subscriptionType,
    this.companyInfo,
    this.isExpired = false,
  });

  @override
  Widget build(BuildContext context) {
    final ownerId = context.read<AuthCubit>().state.user?.id ?? '';

    return BlocProvider(
      create: (_) => sl<SubscriptionsCubit>()..loadSubscriptionsData(ownerId),
      child: _PendingSubscriptionBody(
        passedPlan: plan,
        passedType: subscriptionType,
        passedCompanyInfo: companyInfo,
        isExpired: isExpired,
      ),
    );
  }
}

class _PendingSubscriptionBody extends StatefulWidget {
  final PlanEntity? passedPlan;
  final String? passedType;
  final CompanyInfoEntity? passedCompanyInfo;
  final bool isExpired;

  const _PendingSubscriptionBody({
    this.passedPlan,
    this.passedType,
    this.passedCompanyInfo,
    this.isExpired = false,
  });

  @override
  State<_PendingSubscriptionBody> createState() =>
      _PendingSubscriptionBodyState();
}

class _PendingSubscriptionBodyState extends State<_PendingSubscriptionBody> {
  bool _isChecking = false;

  String _getCycleTitle(String? type) {
    switch (type) {
      case 'yearly':
        return 'السنوي';
      case 'lifetime':
        return 'مدى الحياة';
      default:
        return 'الشهري';
    }
  }

  Future<void> _openWhatsApp(
    BuildContext context,
    CompanyInfoEntity companyInfo,
    PlanEntity? plan,
    String? type,
  ) async {
    final authState = context.read<AuthCubit>().state;
    final userName = authState.user?.name ?? 'غير محدد';
    final userEmail = authState.user?.email ?? 'غير محدد';
    final planName = plan?.name.toUpperCase() ?? 'المختارة';

    final rawPhone = companyInfo.whatsApp1.trim();
    final cleanPhone =
        rawPhone.replaceAll('+', '').replaceAll(' ', '').replaceAll('-', '');
    final message = Uri.encodeComponent(
      'مرحباً ${companyInfo.name}، لقد قمت بطلب الاشتراك في خطة ($planName) بالباقة ${_getCycleTitle(type)}.\n'
      'تفاصيل الحساب:\n'
      '- الاسم: $userName\n'
      '- البريد الإلكتروني: $userEmail\n'
      'يرجى تفعيل الاشتراك.',
    );

    final url = Uri.parse('https://wa.me/+2$cleanPhone?text=$message');
    final apiUrl = Uri.parse(
        'https://api.whatsapp.com/send?phone=+2$cleanPhone&text=$message');

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(apiUrl)) {
        await launchUrl(apiUrl, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(url, mode: LaunchMode.platformDefault);
      }
    } catch (_) {
      if (context.mounted) {
        AppSnackbar.info(
          context,
          message: 'رقم الواتساب للاشتراك: ${companyInfo.whatsApp1}',
        );
      }
    }
  }

  Future<void> _makePhoneCall(BuildContext context, String phone) async {
    final cleanPhone = phone.trim().replaceAll(' ', '');
    final url = Uri.parse('tel:$cleanPhone');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      if (context.mounted) {
        AppSnackbar.info(
          context,
          message: 'رقم الهاتف للاتصال: $phone',
        );
      }
    }
  }

  Future<void> _checkActivation(BuildContext context, String ownerId) async {
    setState(() => _isChecking = true);
    await context.read<SubscriptionsCubit>().loadSubscriptionsData(ownerId);
    setState(() => _isChecking = false);
  }

  @override
  Widget build(BuildContext context) {
    final ownerId = context.read<AuthCubit>().state.user?.id ?? '';

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: context.backgroundColor,
        body: SafeArea(
          child: BlocConsumer<SubscriptionsCubit, SubscriptionsState>(
            listener: (context, state) {
              if (state is SubscriptionsLoaded) {
                final activeSub = state.activeSubscription;
                if (activeSub != null && activeSub.isActive) {
                  AppSnackbar.success(
                    context,
                    message: AppStrings.subscriptionActivatedSuccess,
                  );
                  context.go(RouteConstants.ownerDashboard);
                }
              }
            },
            builder: (context, state) {
              CompanyInfoEntity companyInfo = widget.passedCompanyInfo ??
                  const CompanyInfoEntity(
                    id: 'default',
                    name: 'Clinic Pro Support',
                    phone1: '+201000000000',
                    whatsApp1: '+201000000000',
                  );

              PlanEntity? plan = widget.passedPlan;
              String? type = widget.passedType;

              if (state is SubscriptionsLoaded) {
                companyInfo = state.companyInfo ?? companyInfo;
                final sub = state.activeSubscription;
                if (sub != null) {
                  type = sub.subscriptionType;
                  plan = state.plans.firstWhere(
                    (p) => p.id == sub.planId || p.name == sub.planId,
                  );
                }
              }

              final planNameStr =
                  plan != null ? plan.name.toUpperCase() : '';

              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppConstants.spaceLg),
                  child: ResponsiveHelper.responsiveCenter(
                    maxWidth: 520,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: (widget.isExpired
                                    ? context.danger
                                    : context.primary)
                                .withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            widget.isExpired
                                ? Icons.timer_off_rounded
                                : Icons.hourglass_top_rounded,
                            color: widget.isExpired
                                ? context.danger
                                : context.primary,
                            size: 44,
                          ),
                        ),
                        const SizedBox(height: AppConstants.spaceLg),

                        Text(
                          widget.isExpired
                              ? AppStrings.subscriptionExpired
                              : AppStrings.subscriptionRequestSubmitted,
                          style: AppTextStyles.headlineMedium(context).copyWith(
                            fontWeight: FontWeight.bold,
                            color: context.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                        const SizedBox(height: AppConstants.spaceSm),

                        // الرسالة التوضيحية
                        Text(
                          widget.isExpired
                              ? 'لقد انتهت فترة الاشتراك الحالي في خطة ($planNameStr).\nيرجى التجديد أو الترقية لخطة أعلى لمتابعة استخدام خدمات العيادة.'
                              : 'تم تسجيل طلبك لخطة ($planNameStr) بحالة قيد الانتظار (Pending).\n'
                                  'يرجى الانتظار حتى يقوم المسؤول بالتفعيل أو يمكنك التواصل معه لتأكيد التفعيل فوراً.',
                          style: AppTextStyles.bodyMedium(context).copyWith(
                            color: context.textSecondary,
                            height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppConstants.spaceXl),

                        if (widget.isExpired) ...[
                          // زر التجديد أو الترقية عند انتهاء الاشتراك
                          ElevatedButton.icon(
                            onPressed: () =>
                                context.push(RouteConstants.plansComparison),
                            icon: const Icon(Icons.rocket_launch_rounded,
                                color: Colors.white),
                            label: const Text('تجديد أو ترقية الاشتراك الآن'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.primary,
                              foregroundColor: context.onPrimary,
                              minimumSize: const Size(double.infinity, 52),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    AppConstants.radiusButton),
                              ),
                              elevation: 4,
                            ),
                          ),
                          const SizedBox(height: AppConstants.spaceMd),
                        ],

                        // زر التواصل عبر واتساب
                        if (!widget.isExpired)
                          ElevatedButton.icon(
                            onPressed: () =>
                                _openWhatsApp(context, companyInfo, plan, type),
                            icon: const Icon(Icons.chat_bubble_outline_rounded,
                                color: Colors.white),
                            label: const Text('تواصل عبر واتساب للتفعيل'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF25D366),
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    AppConstants.radiusButton),
                              ),
                              elevation: 2,
                            ),
                          ),
                        const SizedBox(height: AppConstants.spaceMd),

                        // زر الاتصال الهاتفي
                        if (!widget.isExpired)
                          OutlinedButton.icon(
                            onPressed: () =>
                                _makePhoneCall(context, companyInfo.phone1),
                            icon: Icon(Icons.phone_outlined,
                                color: context.primary),
                            label: const Text(
                                'إجراء مكالمة هاتفية'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: context.primary,
                              minimumSize: const Size(double.infinity, 50),
                              side: BorderSide(color: context.primary),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    AppConstants.radiusButton),
                              ),
                            ),
                          ),
                        if (!widget.isExpired) ...[
                          const SizedBox(height: AppConstants.spaceXl),

                          // زر الفحص والتحقق من التفعيل المباشر
                          ElevatedButton.icon(
                            onPressed: _isChecking
                                ? null
                                : () => _checkActivation(context, ownerId),
                            icon: _isChecking
                                ? const AppLoadingWidget(
                                    size: AppLoadingSize.small,
                                    color: Colors.white,
                                  )
                                : const Icon(Icons.refresh_rounded,
                                    color: Colors.white),
                            label: Text(_isChecking
                                ? 'جاري التحقق...'
                                : 'التحقق من التفعيل الآن'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.primary,
                              foregroundColor: context.onPrimary,
                              minimumSize: const Size(double.infinity, 52),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    AppConstants.radiusButton),
                              ),
                              elevation: 4,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

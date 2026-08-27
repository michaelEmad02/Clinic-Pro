// ────────────────────────────────────────────────────────
// شاشة اختيار طريقة الدفع (PaymentMethodsScreen)
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/features/payment/domain/entities/payment_status_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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
import '../../../plans_and_subscriptions/domain/entities/company_info_entity.dart';
import '../../../plans_and_subscriptions/domain/entities/plan_entity.dart';
import '../../domain/entities/payment_method.dart';
import '../manager/payment_cubit.dart';
import '../manager/payment_state.dart';
import '../../../coupons/presentation/manager/coupons_cubit.dart';
import '../../../coupons/presentation/manager/coupons_state.dart';
import '../../../coupons/presentation/ui/widgets/coupon_input_row.dart';
import '../../../coupons/presentation/ui/widgets/available_coupons_bottom_sheet.dart';


class PaymentMethodsScreen extends StatelessWidget {
  final PlanEntity targetPlan;
  final String subscriptionType;
  final CompanyInfoEntity? companyInfo;

  const PaymentMethodsScreen({
    super.key,
    required this.targetPlan,
    required this.subscriptionType,
    this.companyInfo,
  });

  @override
  Widget build(BuildContext context) {
    final ownerId = context.read<AuthCubit>().state.user?.id ?? '';
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<PaymentCubit>()),
        BlocProvider(
          create: (_) {
            final cubit = sl<CouponsCubit>();
            if (ownerId.isNotEmpty) {
              cubit.loadAvailableCoupons(ownerId);
            }
            return cubit;
          },
        ),
      ],
      child: _PaymentMethodsBody(
        targetPlan: targetPlan,
        subscriptionType: subscriptionType,
        companyInfo: companyInfo,
      ),
    );
  }
}

class _PaymentMethodsBody extends StatefulWidget {
  final PlanEntity targetPlan;
  final String subscriptionType;
  final CompanyInfoEntity? companyInfo;

  const _PaymentMethodsBody({
    required this.targetPlan,
    required this.subscriptionType,
    this.companyInfo,
  });

  @override
  State<_PaymentMethodsBody> createState() => _PaymentMethodsBodyState();
}

class _PaymentMethodsBodyState extends State<_PaymentMethodsBody> {
  PaymentMethod _selectedMethod = PaymentMethod.card;
  final TextEditingController _walletController = TextEditingController();

  @override
  void dispose() {
    _walletController.dispose();
    super.dispose();
  }

  double _calculatePrice() {
    if (widget.subscriptionType == 'yearly') {
      return widget.targetPlan.yearlyPriceEgp;
    } else if (widget.subscriptionType == 'lifetime') {
      return widget.targetPlan.lifetimePriceEgp;
    }
    return widget.targetPlan.monthlyPriceEgp;
  }

  String _getCycleText() {
    if (widget.subscriptionType == 'yearly') return AppStrings.yearlyLabel;
    if (widget.subscriptionType == 'lifetime') return AppStrings.lifetimeLabel;
    return AppStrings.monthlyLabel;
  }

  void _onPayPressed(BuildContext context) {
    final ownerId = context.read<AuthCubit>().state.user?.id ?? '';
    if (ownerId.isEmpty) {
      AppSnackbar.error(context, message: AppStrings.userIdentityError);
      return;
    }

    final couponsCubit = context.read<CouponsCubit>();

    // ────────────────────────────────────────────────────────────────────────
    // هل نتخطى بوابة الدفع؟
    // (أيام/شهور مجانية أو خصم 100%)
    // ────────────────────────────────────────────────────────────────────────
    if (couponsCubit.shouldSkipPaymentGateway) {
      couponsCubit.redeemCouponDirectly(
        ownerId: ownerId,
        planId: widget.targetPlan.id,
        billingCycle: widget.subscriptionType,
      );
      return;
    }

    final couponCode = couponsCubit.appliedCoupon?.code;

    if (_selectedMethod == PaymentMethod.wallet) {
      _showWalletBottomSheet(context, ownerId, couponCode);
    } else {
      context.read<PaymentCubit>().initiatePayment(
            ownerId: ownerId,
            plan: widget.targetPlan,
            subscriptionType: widget.subscriptionType,
            paymentMethod: _selectedMethod,
            couponCode: couponCode,
          );
    }
  }

  void _showWalletBottomSheet(BuildContext parentContext, String ownerId, String? couponCode) {
    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + AppConstants.spaceLg,
            top: AppConstants.spaceLg,
            left: AppConstants.spaceLg,
            right: AppConstants.spaceLg,
          ),
          decoration: BoxDecoration(
            color: parentContext.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: parentContext.borderColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.spaceMd),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: parentContext.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.account_balance_wallet_rounded,
                      color: parentContext.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'رقم المحفظة الإلكترونية',
                          style: AppTextStyles.headlineSmall(parentContext).copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'فودافون كاش، أورنج كاش، اتصالات كاش، وي باي، أو المحافظ البنكية',
                          style: AppTextStyles.caption(parentContext).copyWith(
                            color: parentContext.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spaceLg),
              TextField(
                controller: _walletController,
                keyboardType: TextInputType.phone,
                textDirection: TextDirection.ltr,
                maxLength: 11,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'رقم المحفظة',
                  hintText: '010XXXXXXXX',
                  prefixIcon: const Icon(Icons.phone_android_rounded),
                  counterText: '',
                  filled: true,
                  fillColor: parentContext.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: parentContext.borderColor),
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.spaceLg),
              ElevatedButton(
                onPressed: () {
                  final walletNum = _walletController.text.trim();
                  if (walletNum.isEmpty) {
                    AppSnackbar.error(sheetContext, message: 'الرجاء إدخال رقم المحفظة الإلكترونية');
                    return;
                  }
                  Navigator.pop(sheetContext);
                  parentContext.read<PaymentCubit>().initiatePayment(
                        ownerId: ownerId,
                        plan: widget.targetPlan,
                        subscriptionType: widget.subscriptionType,
                        paymentMethod: PaymentMethod.wallet,
                        walletNumber: walletNum,
                        couponCode: couponCode,
                      );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: parentContext.primary,
                  foregroundColor: parentContext.onPrimary,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusButton),
                  ),
                ),
                child: Text(
                  'تأكيد ومتابعة الدفع',
                  style: AppTextStyles.bodyLarge(parentContext).copyWith(
                    fontWeight: FontWeight.bold,
                    color: parentContext.onPrimary,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFawryCodeBottomSheet(BuildContext parentContext, PaymentIntentReady state) {
    final rawCode = state.intentResult.fawryCode;
    final code = (rawCode != null && rawCode.trim().isNotEmpty)
        ? rawCode.trim()
        : (state.intentResult.referenceNumber.trim().isNotEmpty
            ? state.intentResult.referenceNumber.trim()
            : state.intentResult.orderId);

    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.all(AppConstants.spaceLg),
          decoration: BoxDecoration(
            color: parentContext.surfaceColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: parentContext.borderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppConstants.spaceLg),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.storefront_rounded,
                  color: Colors.amber,
                  size: 36,
                ),
              ),
              const SizedBox(height: AppConstants.spaceMd),
              Text(
                'كود الدفع في فوري (Fawry Code)',
                style: AppTextStyles.headlineSmall(parentContext).copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppConstants.spaceXs),
              Text(
                'احفظ هذا الكود وادفع به في أي منافذ أو منافذ فوري لتفعيل الاشتراك',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium(parentContext).copyWith(
                  color: parentContext.textSecondary,
                ),
              ),
              const SizedBox(height: AppConstants.spaceLg),
              
              // بطاقة عرض كود فوري
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                decoration: BoxDecoration(
                  color: parentContext.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.amber, width: 1.5),
                ),
                child: Column(
                  children: [
                    Text(
                      'رقم الخدمة/المرجع:',
                      style: AppTextStyles.caption(parentContext).copyWith(
                        color: parentContext.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    SelectableText(
                      code,
                      style: AppTextStyles.headlineLarge(parentContext).copyWith(
                        fontWeight: FontWeight.bold,
                        color: parentContext.primary,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.spaceLg),

              // زر نسخ الكود
              OutlinedButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: code));
                  AppSnackbar.success(sheetContext, message: 'تم نسخ كود فوري بنجاح!');
                },
                icon: const Icon(Icons.copy_rounded),
                label: const Text('نسخ الكود'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusButton),
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.spaceMd),

              // زر متابعة وتوجه لشاشة الاشتراكات
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(sheetContext);
                  context.go(RouteConstants.onboardingPlan);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: parentContext.primary,
                  foregroundColor: parentContext.onPrimary,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusButton),
                  ),
                ),
                child: Text(
                  'فهمت',
                  style: AppTextStyles.bodyLarge(parentContext).copyWith(
                    fontWeight: FontWeight.bold,
                    color: parentContext.onPrimary,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final price = _calculatePrice();

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        toolbarHeight: 64,
        backgroundColor: context.surfaceColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          AppStrings.checkoutTitle,
          style: AppTextStyles.headlineMedium(context).copyWith(
            fontWeight: FontWeight.bold,
            color: context.textPrimary,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: context.borderColor, height: 1),
        ),
      ),
      body: BlocListener<CouponsCubit, CouponsState>(
        listener: (context, couponState) {
          if (couponState is CouponRedeemSuccess) {
            AppSnackbar.success(context, message: couponState.message);
            final cycleText = couponState.freeDaysGranted > 0
                ? (AppStrings.isArabic ? '${couponState.freeDaysGranted} يوم' : '${couponState.freeDaysGranted} Days')
                : widget.subscriptionType;

            context.push(
              RouteConstants.paymentSuccess,
              extra: {
                'statusResult': PaymentStatusEntity(
                  transactionId: 'COUPON-DIRECT',
                  status: 'success',
                  paymentMethod: 'coupon',
                  amount: 0,
                  currency: AppStrings.egp,
                ),
                'plan': widget.targetPlan,
                'subscriptionType': cycleText,
              },
            );
          } else if (couponState is CouponRedeemError) {
            AppSnackbar.error(context, message: couponState.message);
          }
        },
        child: BlocConsumer<PaymentCubit, PaymentState>(
        listener: (context, state) {
          if (state is PaymentIntentReady) {
            final fawryCode = state.intentResult.fawryCode ?? '';
            if (state.paymentMethod == PaymentMethod.fawry || fawryCode.isNotEmpty) {
              context.push(
                RouteConstants.paymentSuccess,
                extra: {
                  'statusResult': PaymentStatusEntity(
                    transactionId: state.intentResult.transactionId,
                    referenceNumber: state.intentResult.referenceNumber,
                    gatewayOrderId: state.intentResult.orderId,
                    fawryCode: fawryCode,
                    status: 'pending',
                    paymentMethod: 'fawry',
                    amount: state.intentResult.amount,
                    currency: state.intentResult.currency,
                  ),
                  'plan': state.plan,
                  'subscriptionType': state.subscriptionType,
                },
              );
            } else {
              context.push(
                RouteConstants.paymentWebview,
                extra: {
                  'paymentUrl': state.intentResult.paymentUrl,
                  'transactionId': state.intentResult.transactionId,
                  'plan': state.plan,
                  'subscriptionType': state.subscriptionType,
                },
              );
            }
          } else if (state is PaymentFailed) {
            context.push(
              RouteConstants.paymentFailed,
              extra: {
                'message': state.message,
                'plan': widget.targetPlan,
                'subscriptionType': widget.subscriptionType,
                'companyInfo': widget.companyInfo,
              },
            );
          } else if (state is PaymentError) {
            AppSnackbar.error(context, message: state.message);
          }
        },
        builder: (context, state) {
          final isLoading = state is PaymentCreatingIntent;

          return ResponsiveHelper.responsiveCenter(
            maxWidth: 600,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.spaceLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // بطاقة ملخص الباقة
                  Builder(
                    builder: (context) {
                      final couponsCubit = context.watch<CouponsCubit>();
                      final appliedCoupon = couponsCubit.appliedCoupon;
                      final finalPrice = appliedCoupon != null
                          ? appliedCoupon.finalAmount
                          : price;

                      return Container(
                        padding: const EdgeInsets.all(AppConstants.spaceMd),
                        decoration: BoxDecoration(
                          color: context.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: context.borderColor),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        AppStrings.planNamePrefix(widget.targetPlan.name.toUpperCase()),
                                        style: AppTextStyles.headlineSmall(context).copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: context.textPrimary,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${AppStrings.billingCyclePrefix}: ${_getCycleText()}',
                                        style: AppTextStyles.bodyMedium(context).copyWith(
                                          color: context.textSecondary,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: AppConstants.spaceSm),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    if (appliedCoupon != null) ...[
                                      Text(
                                        '${price.toInt()} ${AppStrings.egp}',
                                        style: AppTextStyles.bodyMedium(context).copyWith(
                                          decoration: TextDecoration.lineThrough,
                                          color: context.textPrimary,
                                        ),
                                      ),
                                    ],
                                    Text(
                                      '${finalPrice.toInt()} ${AppStrings.egp}',
                                      style: AppTextStyles.headlineMedium(context).copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: appliedCoupon != null ? context.accent : context.primary,
                                      ),
                                    ),
                                    Text(
                                      '/${_getCycleText()}',
                                      style: AppTextStyles.caption(context).copyWith(
                                        color: context.textSecondary,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: AppConstants.spaceLg),

                  // صف إدخال وتطبيق الكوبونات
                  Builder(
                    builder: (context) {
                      final ownerId = context.read<AuthCubit>().state.user?.id ?? '';
                      return CouponInputRow(
                        ownerId: ownerId,
                        planId: widget.targetPlan.id,
                        billingCycle: widget.subscriptionType,
                        onOpenAvailableCoupons: () {
                          final coupons = context.read<CouponsCubit>().availableCoupons;
                          AvailableCouponsBottomSheet.show(
                            context: context,
                            coupons: coupons,
                            onSelectCoupon: (coupon) {
                              context.read<CouponsCubit>().validateAndApplyCoupon(
                                    code: coupon.code,
                                    ownerId: ownerId,
                                    planId: widget.targetPlan.id,
                                    billingCycle: widget.subscriptionType,
                                  );
                            },
                          );
                        },
                      );
                    },
                  ),

                  const SizedBox(height: AppConstants.spaceXl),

                  Text(
                    AppStrings.selectOnlinePaymentMethod,
                    style: AppTextStyles.headlineSmall(context).copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spaceSm),
                  Text(
                    AppStrings.secureRedirectNotice,
                    style: AppTextStyles.bodyMedium(context).copyWith(
                      color: context.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spaceLg),

                  // خيارات طريقة الدفع
                  _buildPaymentOptionCard(
                    context: context,
                    method: PaymentMethod.card,
                    title: AppStrings.bankCardTitle,
                    subtitle: AppStrings.bankCardSubtitle,
                    icon: Icons.credit_card_rounded,
                  ),
                  const SizedBox(height: AppConstants.spaceMd),

                  _buildPaymentOptionCard(
                    context: context,
                    method: PaymentMethod.wallet,
                    title: AppStrings.vodafoneCashTitle,
                    subtitle: AppStrings.vodafoneCashSubtitle,
                    icon: Icons.account_balance_wallet_rounded,
                  ),
                  const SizedBox(height: AppConstants.spaceMd),

                  _buildPaymentOptionCard(
                    context: context,
                    method: PaymentMethod.fawry,
                    title: AppStrings.fawryTitle,
                    subtitle: AppStrings.fawrySubtitle,
                    icon: Icons.storefront_rounded,
                  ),

                  const SizedBox(height: AppConstants.spaceXl),

                  // زر متابعة الدفع
                  ElevatedButton(
                    onPressed: isLoading ? null : () => _onPayPressed(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.primary,
                      foregroundColor: context.onPrimary,
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppConstants.radiusButton),
                      ),
                    ),
                    child: isLoading
                        ? const AppLoadingWidget(
                            size: AppLoadingSize.small,
                            color: Colors.white,
                          )
                        : Flexible(
                            child: Text(
                              AppStrings.continuePaymentWithMethod(_selectedMethod.arabicName),
                              style: AppTextStyles.bodyLarge(context).copyWith(
                                fontWeight: FontWeight.bold,
                                color: context.onPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                  ),

                  const SizedBox(height: AppConstants.spaceLg),

                  // الخيار اليدوي الاحتياطي
                  Center(
                    child: TextButton.icon(
                      onPressed: () {
                        context.push(
                          RouteConstants.pendingSubscription,
                          extra: {
                            'plan': widget.targetPlan,
                            'subscriptionType': widget.subscriptionType,
                            'companyInfo': widget.companyInfo,
                          },
                        );
                      },
                      icon: Icon(Icons.chat_bubble_outline_rounded, color: context.textSecondary),
                      label: Flexible(
                        child: Text(
                          AppStrings.contactWhatsAppManualPay,
                          style: AppTextStyles.bodyMedium(context).copyWith(
                            color: context.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      ),
    );
  }

  Widget _buildPaymentOptionCard({
    required BuildContext context,
    required PaymentMethod method,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _selectedMethod == method;

    return InkWell(
      onTap: () => setState(() => _selectedMethod = method),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppConstants.spaceMd),
        decoration: BoxDecoration(
          color: isSelected ? context.primary.withOpacity(0.05) : context.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? context.primary : context.borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (isSelected ? context.primary : context.textSecondary).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? context.primaryFixedDim : context.textSecondary,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyLarge(context).copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? context.primaryFixedDim : context.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption(context).copyWith(
                      color: context.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            Radio<PaymentMethod>(
              value: method,
              groupValue: _selectedMethod,
              activeColor: context.primary,
              onChanged: (val) {
                if (val != null) setState(() => _selectedMethod = val);
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ويدجت حقل إدخال وتطبيق كوبون الخصم في شاشات الدفع والاشتراكات
// يدعم التجاوب الكامل (Responsive)، وتنسيقات الثيم والألوان وثوابت التطبيق
// ─────────────────────────────────────────────────────────────────────────────

import 'package:clinic_pro/core/widgets/app_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clinic_pro/core/constants/app_constants.dart';
import 'package:clinic_pro/core/strings/app_strings.dart';
import 'package:clinic_pro/core/themes/app_colors.dart';
import 'package:clinic_pro/core/themes/app_text_styles.dart';
import 'package:clinic_pro/core/widgets/app_snackbar.dart';
import 'package:clinic_pro/features/coupons/presentation/manager/coupons_cubit.dart';
import 'package:clinic_pro/features/coupons/presentation/manager/coupons_state.dart';

class CouponInputRow extends StatefulWidget {
  final String ownerId;
  final String planId;
  final String billingCycle;
  final VoidCallback onOpenAvailableCoupons;

  const CouponInputRow({
    super.key,
    required this.ownerId,
    required this.planId,
    this.billingCycle = 'monthly',
    required this.onOpenAvailableCoupons,
  });

  @override
  State<CouponInputRow> createState() => _CouponInputRowState();
}

class _CouponInputRowState extends State<CouponInputRow> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _applyCoupon() {
    final code = _controller.text.trim();
    if (code.isEmpty) {
      AppSnackbar.error(context, message: AppStrings.couponInputHint);
      return;
    }
    context.read<CouponsCubit>().validateAndApplyCoupon(
          code: code,
          ownerId: widget.ownerId,
          planId: widget.planId,
          billingCycle: widget.billingCycle,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CouponsCubit, CouponsState>(
      listener: (context, state) {
        if (state is CouponValidationError) {
          AppSnackbar.error(context, message: state.message);
        } else if (state is CouponValidationSuccess) {
          final code = state.validationResult.code ?? '';
          if (code.isNotEmpty && _controller.text != code) {
            _controller.text = code;
          }
        }
      },
      builder: (context, state) {
        final cubit = context.read<CouponsCubit>();
        final appliedCoupon = cubit.appliedCoupon;
        if (appliedCoupon != null && _controller.text.isEmpty) {
          _controller.text = appliedCoupon.code ?? '';
        }
        final availableCoupons = cubit.availableCoupons;
        final isLoading = state is CouponsLoading;


        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // حقل الإدخال وزر التطبيق
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    readOnly: appliedCoupon != null || isLoading,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _applyCoupon(),
                    style: AppTextStyles.bodyMedium(context),
                    decoration: InputDecoration(
                      hintText: AppStrings.couponInputHint,
                      hintStyle: AppTextStyles.bodyMedium(context).copyWith(
                        color: context.textSecondary.withOpacity(0.6),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.spaceMd,
                        vertical: AppConstants.spaceSm + 4,
                      ),
                      filled: true,
                      fillColor: appliedCoupon != null
                          ? context.surfaceContainerLow.withOpacity(0.2)
                          : context.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppConstants.radiusButton),
                        borderSide: BorderSide(color: context.borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppConstants.radiusButton),
                        borderSide: BorderSide(color: context.borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppConstants.radiusButton),
                        borderSide: BorderSide(color: context.primary, width: 1.5),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppConstants.radiusButton),
                        borderSide: BorderSide(color: context.borderColor.withOpacity(0.5)),
                      ),
                      suffixIcon: appliedCoupon != null
                          ? IconButton(
                              icon: Icon(Icons.close_rounded, color: context.danger, size: 20),
                              tooltip: AppStrings.remove,
                              onPressed: () {
                                _controller.clear();
                                cubit.removeAppliedCoupon();
                              },
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: AppConstants.spaceSm + 2),
                ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 90, minHeight: 48),
                  child: ElevatedButton(
                    onPressed: (appliedCoupon == null && !isLoading) ? _applyCoupon : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.primary,
                      foregroundColor: context.onPrimary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.spaceMd,
                        vertical: AppConstants.spaceSm + 4,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppConstants.radiusButton),
                      ),
                    ),
                    child: isLoading
                        ? const AppLoadingWidget(
                            size: AppLoadingSize.small,
                            color: Colors.white,
                          )
                        : Text(
                            AppStrings.applyCoupon,
                            style: AppTextStyles.bodyMedium(context).copyWith(
                              fontWeight: FontWeight.bold,
                              color: context.onPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                  ),
                ),
              ],
            ),

            // شرط الظهور: يظهر فقط إذا كان لدى المالك كوبونات خاصة غير مستخدمة ومتاحة (ستايل تذكرة قسيمة / Voucher متجاوب)
            if (availableCoupons.isNotEmpty && appliedCoupon == null) ...[
              const SizedBox(height: AppConstants.spaceSm + 2),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onOpenAvailableCoupons,
                  borderRadius: BorderRadius.circular(AppConstants.radiusButton),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spaceMd,
                      vertical: AppConstants.spaceSm + 2,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          context.primary.withOpacity(0.09),
                          context.primary.withOpacity(0.03),
                        ],
                        begin: AlignmentDirectional.centerStart,
                        end: AlignmentDirectional.centerEnd,
                      ),
                      borderRadius: BorderRadius.circular(AppConstants.radiusButton),
                      border: Border.all(
                        color: context.primary.withOpacity(0.25),
                        width: 1.2,
                      ),
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isNarrow = constraints.maxWidth < 340;

                        return Row(
                          children: [
                            // أيقونة الكوبون داخل شارة مميزة
                            Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: context.primary,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: context.primary.withOpacity(0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.confirmation_num_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: AppConstants.spaceSm + 2),

                            // تفاصيل العرض
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          AppStrings.isArabic
                                              ? 'لديك (${availableCoupons.length}) قسائم متاحة'
                                              : 'You have (${availableCoupons.length}) available vouchers',
                                          style: AppTextStyles.bodyMedium(context).copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: context.textPrimary,
                                            height: 1.2,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ),
                                      if (!isNarrow) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                          decoration: BoxDecoration(
                                            color: context.accent.withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            AppStrings.isArabic ? 'خصم متاح' : 'Discount',
                                            style: AppTextStyles.caption(context).copyWith(
                                              color: context.accent,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    AppStrings.isArabic
                                        ? 'اضغط هنا لاستعراض وتطبيق خصوماتك فوراً'
                                        : 'Tap here to view and apply your discounts now',
                                    style: AppTextStyles.caption(context).copyWith(
                                      color: context.textSecondary,
                                      fontSize: 11,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: AppConstants.spaceXs + 2),

                            // زر الاختيار مع سهم
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isNarrow ? 8 : 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: context.primary.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    AppStrings.isArabic ? 'استعراض' : 'View',
                                    style: AppTextStyles.caption(context).copyWith(
                                      color: context.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 3),
                                  Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    color: context.primary,
                                    size: 11,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],

            // بطاقة تأكيد نجاح تطبيق الكوبون
            if (appliedCoupon != null) ...[
              const SizedBox(height: AppConstants.spaceSm + 2),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spaceMd,
                  vertical: AppConstants.spaceSm + 2,
                ),
                decoration: BoxDecoration(
                  color: context.accent.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(AppConstants.radiusCard),
                  border: Border.all(color: context.accent.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline_rounded, color: context.accent, size: 20),
                    const SizedBox(width: AppConstants.spaceSm),
                    Expanded(
                      child: Text(
                        appliedCoupon.freeDaysGranted > 0
                            ? '${appliedCoupon.freeDaysGranted} ${AppStrings.isArabic ? 'يوم مجاناً' : 'Free days'} 🎉'
                            : AppStrings.couponAppliedSuccess(appliedCoupon.discountAmount),
                        style: AppTextStyles.bodyMedium(context).copyWith(
                          color: context.accent,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
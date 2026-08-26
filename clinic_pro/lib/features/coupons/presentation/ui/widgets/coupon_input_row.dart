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
        }
      },
      builder: (context, state) {
        final cubit = context.read<CouponsCubit>();
        final appliedCoupon = cubit.appliedCoupon;
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
                    enabled: appliedCoupon == null && !isLoading,
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
                          ? context.surfaceContainerLow.withOpacity(0.5)
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

            // شرط الظهور: يظهر فقط إذا كان لدى المالك كوبونات خاصة غير مستخدمة ومتاحة
            if (availableCoupons.isNotEmpty && appliedCoupon == null) ...[
              const SizedBox(height: AppConstants.spaceSm),
              InkWell(
                onTap: widget.onOpenAvailableCoupons,
                borderRadius: BorderRadius.circular(AppConstants.radiusChip),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppConstants.spaceXs,
                    horizontal: AppConstants.spaceXs,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.local_offer_outlined, color: context.primary, size: 18),
                      const SizedBox(width: AppConstants.spaceXs + 2),
                      Flexible(
                        child: Text(
                          AppStrings.availableCouponsButton(availableCoupons.length),
                          style: AppTextStyles.caption(context).copyWith(
                            color: context.primary,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
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
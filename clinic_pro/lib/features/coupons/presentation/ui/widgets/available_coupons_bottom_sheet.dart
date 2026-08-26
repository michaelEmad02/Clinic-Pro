// ─────────────────────────────────────────────────────────────────────────────
// قائمة الكوبونات المتاحة للطبيب (Available Coupons BottomSheet)
// يدعم التخصيص التلقائي للثيم (context color getters) وتعدد اللغات (AppStrings)
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:clinic_pro/core/constants/supabase_constants.dart';
import 'package:clinic_pro/core/strings/app_strings.dart';
import 'package:clinic_pro/core/themes/app_colors.dart';
import 'package:clinic_pro/core/themes/app_text_styles.dart';
import 'package:clinic_pro/features/coupons/domain/entities/coupon_entity.dart';

class AvailableCouponsBottomSheet extends StatelessWidget {
  final List<CouponEntity> coupons;
  final Function(CouponEntity coupon) onCouponSelected;

  const AvailableCouponsBottomSheet({
    super.key,
    required this.coupons,
    required this.onCouponSelected,
  });

  static Future<void> show({
    required BuildContext context,
    required List<CouponEntity> coupons,
    required Function(CouponEntity coupon) onSelectCoupon,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AvailableCouponsBottomSheet(
        coupons: coupons,
        onCouponSelected: onSelectCoupon,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.availableCouponsTitle,
                style: AppTextStyles.bodyLarge(context).copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (coupons.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Center(
                child: Text(
                  AppStrings.noAvailableCoupons,
                  style: AppTextStyles.bodyMedium(context).copyWith(color: context.textSecondary),
                ),
              ),
            )
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: coupons.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final coupon = coupons[index];
                  final isPrivate = coupon.scope == CouponScope.private;

                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isPrivate
                          ? context.primary.withOpacity(0.04)
                          : context.surfaceColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isPrivate
                            ? context.primary.withOpacity(0.3)
                            : context.borderColor,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isPrivate
                                ? context.primary.withOpacity(0.1)
                                : context.borderColor.withOpacity(0.4),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isPrivate ? TablerIcons.gift : TablerIcons.ticket,
                            color: isPrivate ? context.primary : context.textSecondary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    coupon.code,
                                    style: AppTextStyles.bodyLarge(context).copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: context.primary,
                                    ),
                                  ),
                                  if (isPrivate) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: context.primary.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        AppStrings.referralGiftBadge,
                                        style: AppTextStyles.headlineSmall(context).copyWith(
                                          fontSize: 10,
                                          color: context.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                coupon.description ?? AppStrings.discountAvailableOnPlans,
                                style: AppTextStyles.headlineSmall(context).copyWith(
                                  color: context.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            onCouponSelected(coupon);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: context.primary,
                            foregroundColor: context.onPrimary,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(AppStrings.applyCoupon),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

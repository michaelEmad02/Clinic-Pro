import 'package:clinic_pro/core/constants/app_constants.dart';
import 'package:clinic_pro/core/strings/app_strings.dart';
import 'package:clinic_pro/core/themes/app_colors.dart';
import 'package:clinic_pro/core/themes/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/billing_history_item_entity.dart';

class BillingHistoryList extends StatelessWidget {
  final List<BillingHistoryItemEntity> history;

  const BillingHistoryList({
    super.key,
    this.history = const [],
  });

  String _planTitle(String name) {
    switch (name.toLowerCase()) {
      case 'pro':
      case 'growth':
        return AppStrings.isArabic ? 'الباقة الاحترافية (Pro)' : 'Pro Plan';
      case 'enterprise':
      case 'professional':
        return AppStrings.isArabic ? 'باقة المؤسسات (Enterprise)' : 'Enterprise Plan';
      case 'basic':
      default:
        return AppStrings.isArabic ? 'الباقة الأساسية (Basic)' : 'Basic Plan';
    }
  }

  String _cycleLabel(String type) {
    switch (type.toLowerCase()) {
      case 'trail':
      case 'trial':
        return AppStrings.trial;
      case 'yearly':
        return AppStrings.yearlyCycle;
      case 'lifetime':
        return AppStrings.lifetimeCycle;
      case 'monthly':
      default:
        return AppStrings.monthlyCycle;
    }
  }

  Color _statusColor(BuildContext context, String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'success':
        return context.accent;
      case 'pending':
        return context.warningText;
      case 'expired':
      case 'cancelled':
      case 'failed':
      default:
        return context.danger;
    }
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return AppStrings.active;
      case 'pending':
        return AppStrings.subscriptionPending;
      case 'expired':
        return AppStrings.subscriptionExpired;
      case 'cancelled':
        return AppStrings.subscriptionCancelled;
      case 'trail':
      case 'trial':
        return AppStrings.trial;
      default:
        return status;
    }
  }

  String _paymentMethodLabel(String? method) {
    if (method == null || method.isEmpty) return '-';
    switch (method.toLowerCase()) {
      case 'card':
        return AppStrings.bankCardTitle;
      case 'wallet':
        return AppStrings.vodafoneCashTitle;
      case 'fawry':
        return 'Fawry';
      case 'manual':
        return AppStrings.isArabic ? 'دفع يدوي' : 'Manual Payment';
      case 'coupon':
        return AppStrings.isArabic ? 'كوبون' : 'Coupon';
      default:
        return method;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.billingHistoryTitle,
              style: AppTextStyles.headlineSmall(context),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            if (history.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: context.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(AppConstants.radiusChip),
                ),
                child: Text(
                  '${history.length}',
                  style: AppTextStyles.caption(context).copyWith(
                    color: context.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppConstants.spaceMd),
        if (history.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppConstants.spaceLg),
            decoration: BoxDecoration(
              color: context.surfaceColor,
              borderRadius: BorderRadius.circular(AppConstants.radiusCard),
              border: Border.all(color: context.borderColor, width: 0.5),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 40,
                  color: context.textSecondary.withOpacity(0.5),
                ),
                const SizedBox(height: AppConstants.spaceSm),
                Text(
                  AppStrings.noBillingRecords,
                  style: AppTextStyles.bodyMedium(context).copyWith(
                    color: context.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ],
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: context.surfaceColor,
              borderRadius: BorderRadius.circular(AppConstants.radiusCard),
              border: Border.all(color: context.borderColor, width: 0.5),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: history.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                thickness: 0.5,
                color: context.borderColor,
              ),
              itemBuilder: (context, index) {
                final item = history[index];
                final sub = item.subscription;
                final planName = item.plan?.name ?? sub.subscriptionType;
                final title = _planTitle(planName);
                final cycle = _cycleLabel(sub.subscriptionType);
                final status = sub.status;
                final statusColor = _statusColor(context, status);
                final statusText = _statusLabel(status);
                final originalAmount = item.originalAmount;
                final paidAmount = item.paidAmount;
                final hasDiscount = originalAmount != null &&
                    paidAmount != null &&
                    originalAmount > paidAmount;

                final paidAmountText = paidAmount != null
                    ? '${paidAmount.toInt()} ${AppStrings.egp}'
                    : sub.isTrial
                        ? '0 ${AppStrings.egp}'
                        : '-';
                final originalAmountText = originalAmount != null
                    ? '${originalAmount.toInt()} ${AppStrings.egp}'
                    : null;

                final dateFormatted = DateFormat('d MMM yyyy', AppStrings.isArabic ? 'ar' : 'en')
                    .format(sub.createdAt);
                final methodText = _paymentMethodLabel(item.paymentMethod);

                return Padding(
                  padding: const EdgeInsets.all(AppConstants.spaceMd),
                  child: Row(
                    children: [
                      // الأيقونة
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: statusColor.withAlpha(20),
                          borderRadius: BorderRadius.circular(AppConstants.radiusInput),
                        ),
                        child: Icon(
                          sub.isTrial
                              ? Icons.hourglass_top_rounded
                              : status == 'active'
                                  ? Icons.check_circle_outline
                                  : status == 'pending'
                                      ? Icons.pending_outlined
                                      : Icons.receipt_outlined,
                          color: statusColor,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: AppConstants.spaceMd),
                      // تفاصيل الاشتراك
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    title,
                                    style: AppTextStyles.headlineSmall(context).copyWith(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: context.primaryLightColor,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    cycle,
                                    style: AppTextStyles.caption(context).copyWith(
                                      color: context.primary,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                if (item.couponCode != null && item.couponCode!.isNotEmpty) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: context.accent.withAlpha(25),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.local_offer_outlined, size: 10, color: context.accent),
                                        const SizedBox(width: 2),
                                        Text(
                                          item.couponCode!,
                                          style: AppTextStyles.caption(context).copyWith(
                                            color: context.accent,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  dateFormatted,
                                  style: AppTextStyles.caption(context).copyWith(
                                    color: context.textSecondary,
                                  ),
                                ),
                                if (methodText != '-') ...[
                                  Text(
                                    ' • ',
                                    style: AppTextStyles.caption(context).copyWith(
                                      color: context.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    methodText,
                                    style: AppTextStyles.caption(context).copyWith(
                                      color: context.textSecondary,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppConstants.spaceSm),
                      // السعر والحالة
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (hasDiscount && originalAmountText != null) ...[
                                Text(
                                  originalAmountText,
                                  style: AppTextStyles.caption(context).copyWith(
                                    decoration: TextDecoration.lineThrough,
                                    color: context.textSecondary,
                                    fontSize: 12,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                                const SizedBox(width: 6),
                              ],
                              Text(
                                paidAmountText,
                                style: AppTextStyles.headlineSmall(context).copyWith(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Inter',
                                  color: hasDiscount ? context.accent : null,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: statusColor.withAlpha(20),
                              borderRadius: BorderRadius.circular(AppConstants.radiusChip),
                              border: Border.all(color: statusColor.withAlpha(50), width: 0.5),
                            ),
                            child: Text(
                              statusText,
                              style: AppTextStyles.caption(context).copyWith(
                                color: statusColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

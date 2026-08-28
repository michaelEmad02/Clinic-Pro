// ─────────────────────────────────────────────────────────────────────────────
// ويدجت كارت كود الدعوة وزر النسخ والمشاركة السريعة
// يدعم التخصيص التلقائي للثيم (context color getters) وتعدد اللغات (AppStrings)
// ─────────────────────────────────────────────────────────────────────────────

import 'package:clinic_pro/core/constants/app_constants.dart';
import 'package:clinic_pro/core/widgets/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:clinic_pro/core/strings/app_strings.dart';
import 'package:clinic_pro/core/themes/app_colors.dart';
import 'package:clinic_pro/core/themes/app_text_styles.dart';

class ReferralCodeCard extends StatelessWidget {
  final String referralCode;

  const ReferralCodeCard({
    super.key,
    required this.referralCode,
  });

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: referralCode));
    AppSnackbar.success(
      context,
      message: AppStrings.referralCodeCopied(referralCode),
    );
  }

  void _shareInvitation(BuildContext context) {
    final message = AppStrings.shareInvitationMessage(referralCode);
    Clipboard.setData(ClipboardData(text: message));
    AppSnackbar.success(
      context,
      message: 'تم نسخ نص الدعوة ورابط التحميل للمشاركة مع زملائك! 📋',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      decoration: BoxDecoration(
        color: context.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(AppConstants.radiusCard),
        border: Border.all(
          color: context.primary.withOpacity(0.2),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: context.primary.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  TablerIcons.gift,
                  color: context.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppConstants.spaceSm + 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.yourReferralCode,
                      style: AppTextStyles.headlineSmall(context).copyWith(
                        color: context.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AppStrings.referralCodeDesc,
                      style: AppTextStyles.caption(context).copyWith(
                        color: context.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spaceMd),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spaceMd,
              vertical: AppConstants.spaceSm + 2,
            ),
            decoration: BoxDecoration(
              color: context.surfaceColor,
              borderRadius: BorderRadius.circular(AppConstants.radiusButton),
              border: Border.all(
                color: context.borderColor,
              ),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 280;

                return Row(
                  children: [
                    Expanded(
                      child: SelectableText(
                        referralCode.isNotEmpty ? referralCode : 'DOC-XXXXX',
                        style: (isNarrow
                                ? AppTextStyles.bodyLarge(context)
                                : AppTextStyles.headlineMedium(context))
                            .copyWith(
                          color: context.primary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: isNarrow ? 1.0 : 2.0,
                        ),
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: AppConstants.spaceSm),
                    ElevatedButton.icon(
                      onPressed: () => _copyToClipboard(context),
                      icon: const Icon(TablerIcons.copy, size: 16),
                      label: Text(AppStrings.copyCode),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.primary,
                        foregroundColor: context.onPrimary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.spaceSm + 4,
                          vertical: AppConstants.spaceSm,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppConstants.radiusSm),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: AppConstants.spaceSm + 4),
          OutlinedButton.icon(
            onPressed: () => _shareInvitation(context),
            icon: Icon(TablerIcons.share, size: 18, color: context.primary),
            label: Flexible(
              child: Text(
                'مشاركة نص الدعوة ورابط التطبيق',
                style: AppTextStyles.bodyMedium(context).copyWith(
                  color: context.primary,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 44),
              side: BorderSide(color: context.primary.withOpacity(0.4)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusSm),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

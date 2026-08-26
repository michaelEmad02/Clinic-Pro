// ─────────────────────────────────────────────────────────────────────────────
// ويدجت كارت كود الدعوة وزر النسخ والمشاركة السريعة
// يدعم التخصيص التلقائي للثيم (context color getters) وتعدد اللغات (AppStrings)
// ─────────────────────────────────────────────────────────────────────────────

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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppStrings.referralCodeCopied(referralCode),
          style: AppTextStyles.bodyMedium(context).copyWith(color: context.onPrimary),
        ),
        backgroundColor: context.accent,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _shareInvitation(BuildContext context) {
    final message = AppStrings.shareInvitationMessage(referralCode);
    Clipboard.setData(ClipboardData(text: message));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم نسخ نص الدعوة ورابط التحميل للمشاركة مع زملائك! 📋',
          style: AppTextStyles.bodyMedium(context).copyWith(color: context.onPrimary),
        ),
        backgroundColor: context.primary,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.primary.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: context.primary.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  TablerIcons.gift,
                  color: context.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
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
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppStrings.referralCodeDesc,
                      style: AppTextStyles.caption(context).copyWith(
                        color: context.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: context.surfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: context.borderColor,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SelectableText(
                  referralCode.isNotEmpty ? referralCode : 'DOC-XXXXX',
                  style: AppTextStyles.headlineMedium(context).copyWith(
                    color: context.primary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _copyToClipboard(context),
                  icon: const Icon(TablerIcons.copy, size: 18),
                  label: Text(AppStrings.copyCode),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.primary,
                    foregroundColor: context.onPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _shareInvitation(context),
            icon: Icon(TablerIcons.share, size: 18, color: context.primary),
            label: Text(
              'مشاركة نص الدعوة ورابط التطبيق',
              style: AppTextStyles.bodyMedium(context).copyWith(
                color: context.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 44),
              side: BorderSide(color: context.primary.withOpacity(0.4)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

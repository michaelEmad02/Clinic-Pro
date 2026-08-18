// ─────────────────────────────────────────
// أزرار الإجراءات السريعة بخطوط شبكية متجاوبة (Responsive GridView Layout)
// ─────────────────────────────────────────

import 'package:clinic_pro/core/constants/route_constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:clinic_pro/core/utils/responsive_helper.dart';
import 'package:clinic_pro/core/themes/app_colors.dart';
import 'package:clinic_pro/core/themes/app_text_styles.dart';
import 'package:clinic_pro/core/strings/app_strings.dart';

class QuickActionsRow extends StatelessWidget {
  const QuickActionsRow({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    final actions = [
      {
        'label': AppStrings.manageStaff,
        'icon': Icons.people_outlined,
        'onTap': () => context.push(RouteConstants.staff),
      },
      {
        'label': AppStrings.inviteStaff,
        'icon': Icons.person_add_alt_1_outlined,
        'onTap': () => context.push(RouteConstants.onboardingInvite, extra: {"isOnboarding": false}),
      },
      {
        'label': AppStrings.isArabic ? 'تسجيل مصروف' : 'Add Expense',
        'icon': Icons.account_balance_wallet_outlined,
        'onTap': () => context.push(RouteConstants.expenses),
      },
      {
        'label': AppStrings.isArabic ? 'إدارة الاشتراك' : 'Subscription',
        'icon': Icons.card_membership_outlined,
        'onTap': () => context.push(RouteConstants.settingsSubscription),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            AppStrings.quickActions,
            style: AppTextStyles.headlineSmall(context).copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: actions.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isMobile ? 2 : 4,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: isMobile ? 1.9 : 2.4,
            ),
            itemBuilder: (context, index) {
              final action = actions[index];
              return _buildActionButton(
                context: context,
                label: action['label'] as String,
                icon: action['icon'] as IconData,
                onTap: action['onTap'] as VoidCallback,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.01),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: AppColors.primaryContainer,
              size: 22,
            ),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption(context).copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.textPrimary,
                  fontSize: 10.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

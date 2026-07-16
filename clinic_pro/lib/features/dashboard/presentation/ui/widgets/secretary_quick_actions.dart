// ─────────────────────────────────────────
// هذا الملف يحتوي على ويدجت الإجراءات السريعة للسكرتير
// ─────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/route_constants.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/strings/app_strings.dart';

class SecretaryQuickActions extends StatelessWidget {
  final Function(int) onTabChanged;

  const SecretaryQuickActions({
    super.key,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
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
        SizedBox(
          height: 90,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildActionButton(
                context: context,
                label: AppStrings.appointments,
                icon: Icons.calendar_today_outlined,
                onTap: () => onTabChanged(1),
              ),
              const SizedBox(width: 12),
              _buildActionButton(
                context: context,
                label: AppStrings.waitingQueueTitle,
                icon: Icons.people_outline,
                onTap: () => context.push(RouteConstants.waitingQueue),
              ),
              const SizedBox(width: 12),
              _buildActionButton(
                context: context,
                label: AppStrings.invoices,
                icon: Icons.receipt_long_outlined,
                onTap: () => onTabChanged(2),
              ),
            ],
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
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 110,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: AppColors.primaryContainer,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTextStyles.caption(context).copyWith(
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

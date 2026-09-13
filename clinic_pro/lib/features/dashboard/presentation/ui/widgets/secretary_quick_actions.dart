import 'package:clinic_pro/core/utils/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
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
    final isDesktop = ResponsiveHelper.isDesktop(context);

    final actions = [
      {
        'label': AppStrings.appointments,
        'icon': Icons.calendar_today_outlined,
        'onTap': () => onTabChanged(1),
      },
      {
        'label': AppStrings.waitingQueueTitle,
        'icon': Icons.people_outline,
        'onTap': () => context.push(RouteConstants.waitingQueue),
      },
      {
        'label': AppStrings.invoices,
        'icon': Icons.receipt_long_outlined,
        'onTap': () => onTabChanged(2),
      },
      {
        'label': AppStrings.expenses,
        'icon': Icons.account_balance_wallet_outlined,
        'onTap': () => context.push(RouteConstants.expenses),
      },
      {
        'label': AppStrings.patients,
        'icon': TablerIcons.users,
        'onTap': () => onTabChanged(3),
      },
      {
        'label': AppStrings.isArabic ? 'حجز موعد' : 'Book Appointment',
        'icon': Icons.add_circle_outline,
        'onTap': () => onTabChanged(1),
      },
    ];

    // ── Desktop Sidebar Card Layout ──
    if (isDesktop) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: context.primaryLightColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    TablerIcons.bolt,
                    color: context.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  AppStrings.quickActions,
                  style: AppTextStyles.headlineSmall(context).copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final int crossAxisCount = constraints.maxWidth > 300 ? 2 : 1;
                final double childAspectRatio = crossAxisCount == 2 ? 2.5 : 4.6;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: childAspectRatio,
                  ),
                  itemCount: actions.length,
                  itemBuilder: (context, index) {
                    final action = actions[index];
                    return _buildActionCard(
                      context: context,
                      label: action['label'] as String,
                      icon: action['icon'] as IconData,
                      onTap: action['onTap'] as VoidCallback,
                      isDesktop: true,
                    );
                  },
                );
              },
            ),
          ],
        ),
      );
    }

    // ── Mobile & Tablet Layout (Horizontal Scrolling List) ──
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            AppStrings.quickActions,
            style: AppTextStyles.headlineSmall(context).copyWith(
              color: context.primary,
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
              const SizedBox(width: 12),
              _buildActionButton(
                context: context,
                label: AppStrings.expenses,
                icon: Icons.account_balance_wallet_outlined,
                onTap: () => context.push(RouteConstants.expenses),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    bool isDesktop = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.015),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: context.primaryLightColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: context.primary,
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.caption(context).copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                  fontSize: 13,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
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
              color: context.primaryContainer,
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

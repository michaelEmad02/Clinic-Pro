// ────────────────────────────────────────────────────────
// InvoicesTabSelector — مكون اختيار التبويب النشط (سجل الفواتير / مواعيد بانتظار التفوتر)
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/strings/app_strings.dart';
import 'package:clinic_pro/core/themes/app_colors.dart';
import 'package:clinic_pro/core/themes/app_text_styles.dart';
import 'package:clinic_pro/core/utils/responsive_helper.dart';
import 'package:flutter/material.dart';

class InvoicesTabSelector extends StatelessWidget {
  final String activeTab; // 'invoices' | 'unbilled'
  final int invoicesCount;
  final int unbilledCount;
  final ValueChanged<String> onTabChanged;

  const InvoicesTabSelector({
    super.key,
    required this.activeTab,
    required this.invoicesCount,
    required this.unbilledCount,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveHelper.responsiveCenter(
      maxWidth: 800,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: context.borderColor.withOpacity(0.35),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: context.borderColor),
          ),
          child: Row(
            children: [
              Expanded(
                child: _TabButton(
                  icon: Icons.receipt_long_rounded,
                  label: AppStrings.isArabic ? 'الفواتير الصادرة' : 'Issued Invoices',
                  badgeCount: invoicesCount,
                  isSelected: activeTab == 'invoices',
                  onTap: () => onTabChanged('invoices'),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _TabButton(
                  icon: Icons.hourglass_bottom_rounded,
                  label: AppStrings.isArabic ? 'بانتظار التفوتر' : 'Unbilled Visits',
                  badgeCount: unbilledCount,
                  badgeColor: context.warning,
                  isSelected: activeTab == 'unbilled',
                  onTap: () => onTabChanged('unbilled'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final int badgeCount;
  final Color? badgeColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.icon,
    required this.label,
    required this.badgeCount,
    this.badgeColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeBg = context.primary;
    const activeFg = Colors.white;
    final inactiveFg = context.textSecondary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? activeBg : context.surfaceColor.withOpacity(0.5),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? activeBg : Colors.transparent,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: activeBg.withOpacity(0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? activeFg : inactiveFg,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium(context).copyWith(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected ? activeFg : inactiveFg,
                    fontSize: 13,
                  ),
                ),
              ),
              if (badgeCount > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withOpacity(0.25)
                        : (badgeColor ?? context.primary).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$badgeCount',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? activeFg : (badgeColor ?? context.primary),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

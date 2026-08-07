// ────────────────────────────────────────────────────────
// شريط تبويبات شاشة المواعيد (اليوم / القادمة / السجل)
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../manager/appointments_state.dart';

class AppointmentsTabBar extends StatelessWidget {
  final AppointmentsTab activeTab;
  final ValueChanged<AppointmentsTab> onTabChanged;

  const AppointmentsTabBar({
    super.key,
    required this.activeTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tabs = [
      (AppointmentsTab.today, AppStrings.tabToday),
      (AppointmentsTab.upcoming, AppStrings.tabUpcoming),
      (AppointmentsTab.history, AppStrings.tabHistory),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMd),
      padding: const EdgeInsets.all(AppConstants.spaceXs),
      decoration: BoxDecoration(
        color: context.isDarkMode ? context.surface : context.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppConstants.radiusButton),
        border: Border.all(color: context.borderColor),
      ),
      child: Row(
        children: tabs.map((tab) {
          final isSelected = activeTab == tab.$1;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTabChanged(tab.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: AppConstants.spaceSm + 2),
                decoration: BoxDecoration(
                  color: isSelected ? context.surfaceColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppConstants.radiusInput),
                  boxShadow: isSelected ? AppConstants.cardShadow : null,
                ),
                child: Text(
                  tab.$2,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium(context).copyWith(
                    color: isSelected ? context.primary : context.textSecondary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

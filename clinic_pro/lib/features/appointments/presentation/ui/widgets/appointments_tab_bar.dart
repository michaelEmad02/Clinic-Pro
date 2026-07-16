// ────────────────────────────────────────────────────────
// شريط تبويبات شاشة المواعيد (اليوم / القادمة / السجل)
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
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

  static final _tabs = [
    (AppointmentsTab.today, AppStrings.tabToday),
    (AppointmentsTab.upcoming, AppStrings.tabUpcoming),
    (AppointmentsTab.history, AppStrings.tabHistory),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: context.isDarkMode ? const Color(0xFF2A2A2A) : AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.borderColor),
      ),
      child: Row(
        children: _tabs.map((tab) {
          final isSelected = activeTab == tab.$1;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTabChanged(tab.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? context.surfaceColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  tab.$2,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium(context).copyWith(
                    color: isSelected ? AppColors.primary : context.textSecondary,
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

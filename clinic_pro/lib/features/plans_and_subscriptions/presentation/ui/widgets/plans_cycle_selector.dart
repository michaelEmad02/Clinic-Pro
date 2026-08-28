// ────────────────────────────────────────────────────────
// ودجت اختيار دورة الفوترة (PlansCycleSelector)
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../../core/constants/supabase_constants.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';


class PlansCycleSelector extends StatelessWidget {
  final String selectedCycle;
  final ValueChanged<String> onCycleChanged;

  const PlansCycleSelector({
    super.key,
    required this.selectedCycle,
    required this.onCycleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceContainerLow.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildCycleButton(context, SubscriptionType.monthly, AppStrings.monthlyLabel),
            _buildCycleButton(context, SubscriptionType.yearly, AppStrings.yearlyDiscount),
            _buildCycleButton(context, SubscriptionType.lifetime, AppStrings.lifetimeLabel),
          ],
        ),
      ),
    );
  }

  Widget _buildCycleButton(BuildContext context, String key, String label) {
    final active = selectedCycle == key;
    return GestureDetector(
      onTap: () => onCycleChanged(key),
      child: Container(
        decoration: BoxDecoration(
          color: active ? context.surfaceColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(
          label,
          style: AppTextStyles.bodyMedium(context).copyWith(
            color: active ? context.primary : context.textPrimary,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ),
    );
  }
}

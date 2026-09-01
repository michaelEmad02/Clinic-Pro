import 'package:clinic_pro/core/strings/app_strings.dart';
import 'package:clinic_pro/core/themes/app_colors.dart';
import 'package:clinic_pro/core/themes/app_text_styles.dart';
import 'package:clinic_pro/features/settings/presentation/manager/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ExpensesTargetChips extends StatelessWidget {
  final String activeTargetFilter;
  final ValueChanged<String> onChanged;

  const ExpensesTargetChips({
    super.key,
    required this.activeTargetFilter,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final settingsState = context.watch<SettingsCubit>().state;
    final doctorName = settingsState.currentDoctorName;
    final doctorLabel = (doctorName != null && doctorName.trim().isNotEmpty)
        ? 'طبيب: $doctorName'
        : (AppStrings.isArabic ? 'الطبيب الحالي' : 'Current Doctor');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildChip(
              context: context,
              label: AppStrings.isArabic ? 'مصروفات العيادة' : 'Clinic Expenses',
              icon: Icons.local_hospital_outlined,
              isSelected: activeTargetFilter == 'clinic',
              onTap: () => onChanged('clinic'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildChip(
              context: context,
              label: doctorLabel,
              icon: Icons.person_outline,
              isSelected: activeTargetFilter == 'doctor',
              onTap: () => onChanged('doctor'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip({
    required BuildContext context,
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? context.primary.withOpacity(0.12)
              : context.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? context.primary : context.borderColor,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? context.primary : context.textSecondary,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption(context).copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? context.primary : context.textPrimary,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

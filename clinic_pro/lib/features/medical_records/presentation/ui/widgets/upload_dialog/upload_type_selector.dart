// ────────────────────────────────────────────────────────
// محدد نوع الفحص الطبي (UploadTypeSelector)
// يتيح التبديل السلس والتفاعلي بين التحاليل المخبرية والأشعة
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:clinic_pro/core/constants/app_constants.dart';
import 'package:clinic_pro/core/constants/supabase_constants.dart';
import 'package:clinic_pro/core/strings/app_strings.dart';
import 'package:clinic_pro/core/themes/app_colors.dart';
import 'package:clinic_pro/core/themes/app_text_styles.dart';

class UploadTypeSelector extends StatelessWidget {
  final String selectedType;
  final ValueChanged<String> onTypeChanged;

  const UploadTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isLab = selectedType == MedicalRecordType.labTest;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: context.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppConstants.radiusButton),
        border: Border.all(color: context.borderColor.withOpacity(0.6)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TypeOptionTile(
              title: AppStrings.labTest,
              icon: Icons.science_outlined,
              selectedIcon: Icons.science_rounded,
              isSelected: isLab,
              activeColor: const Color(0xFF0D9488),
              onTap: () => onTypeChanged(MedicalRecordType.labTest),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _TypeOptionTile(
              title: AppStrings.radiology,
              icon: Icons.camera_alt_outlined,
              selectedIcon: Icons.camera_alt_rounded,
              isSelected: !isLab,
              activeColor: const Color(0xFF6366F1),
              onTap: () => onTypeChanged(MedicalRecordType.radiology),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeOptionTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final IconData selectedIcon;
  final bool isSelected;
  final Color activeColor;
  final VoidCallback onTap;

  const _TypeOptionTile({
    required this.title,
    required this.icon,
    required this.selectedIcon,
    required this.isSelected,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      child: Material(
        color: isSelected ? context.surfaceColor : Colors.transparent,
        borderRadius: BorderRadius.circular(AppConstants.radiusButton - 2),
        elevation: isSelected ? 2 : 0,
        shadowColor: Colors.black.withOpacity(0.08),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppConstants.radiusButton - 2),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    isSelected ? selectedIcon : icon,
                    key: ValueKey(isSelected),
                    size: 18,
                    color: isSelected ? activeColor : context.textSecondary,
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    title,
                    style: AppTextStyles.caption(context).copyWith(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? activeColor : context.textSecondary,
                      fontSize: 12.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

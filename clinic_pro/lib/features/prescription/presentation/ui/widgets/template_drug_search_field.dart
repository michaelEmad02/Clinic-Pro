import 'package:flutter/material.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';

class TemplateDrugSearchField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onSearchChanged;
  final List<Map<String, dynamic>> filteredDrugs;
  final bool showDropdown;
  final void Function(Map<String, dynamic> drug) onDrugSelected;

  const TemplateDrugSearchField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onSearchChanged,
    required this.filteredDrugs,
    required this.showDropdown,
    required this.onDrugSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'الأدوية',
          style: AppTextStyles.headlineSmall(context).copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          focusNode: focusNode,
          style: AppTextStyles.bodyMedium(context),
          onChanged: onSearchChanged,
          decoration: InputDecoration(
            hintText: 'ابحث عن دواء لإضافته...',
            hintStyle: AppTextStyles.bodyMedium(context).copyWith(color: AppColors.textHint),
            prefixIcon: const Icon(Icons.search, color: AppColors.textHint),
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        if (showDropdown && filteredDrugs.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: filteredDrugs.length,
              itemBuilder: (context, index) {
                final drug = filteredDrugs[index];
                return ListTile(
                  title: Text(
                    drug['trade_name'] ?? '',
                    style: AppTextStyles.bodyMedium(context).copyWith(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    drug['generic_name'] ?? '',
                    style: AppTextStyles.caption(context),
                  ),
                  trailing: const Icon(Icons.add, color: AppColors.primary),
                  onTap: () => onDrugSelected(drug),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

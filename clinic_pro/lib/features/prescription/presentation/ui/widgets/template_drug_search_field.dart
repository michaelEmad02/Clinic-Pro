import 'package:flutter/material.dart';
import '../../../../../core/strings/app_strings.dart';
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
          AppStrings.drugs,
          style: AppTextStyles.headlineSmall(context).copyWith(
            fontWeight: FontWeight.w600,
            color: context.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          focusNode: focusNode,
          style: AppTextStyles.bodyMedium(context),
          onChanged: onSearchChanged,
          decoration: InputDecoration(
            hintText: AppStrings.searchDrugs,
            hintStyle: AppTextStyles.bodyMedium(context)
                .copyWith(color: context.textHint),
            prefixIcon: Icon(Icons.search, color: context.textHint),
            filled: true,
            fillColor: context.background,
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
              borderSide: BorderSide(color: context.primary),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        if (showDropdown && filteredDrugs.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: context.surface,
              border: Border.all(color: context.border),
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
                    style: AppTextStyles.bodyMedium(context)
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    drug['generic_name'] ?? '',
                    style: AppTextStyles.caption(context),
                  ),
                  trailing: Icon(Icons.add, color: context.primary),
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

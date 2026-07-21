// ────────────────────────────────────────────────────────
// VisitTypeFormSection — نموذج إضافة تسعيرة زيارة جديدة
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';

class VisitTypeFormSection extends StatefulWidget {
  final List<Map<String, dynamic>> availableTypes;
  final bool hasEntries;
  final Function(String typeId, String typeName, double price) onAdd;

  const VisitTypeFormSection({
    super.key,
    required this.availableTypes,
    required this.hasEntries,
    required this.onAdd,
  });

  @override
  State<VisitTypeFormSection> createState() => _VisitTypeFormSectionState();
}

class _VisitTypeFormSectionState extends State<VisitTypeFormSection> {
  String? _selectedTypeId;
  final _priceController = TextEditingController();


  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  void _submit() {
    final typeId = _selectedTypeId;
    if (typeId == null || typeId.isEmpty) return;

    final priceText = _priceController.text.trim();
    final price = double.tryParse(priceText) ?? 0.0;

    final type = widget.availableTypes.firstWhere((t) => t['id'] == typeId);
    final typeName = type['name'] as String? ?? '';

    widget.onAdd(typeId, typeName, price);

    setState(() {
      _selectedTypeId = null;
      _priceController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
  var test = widget.availableTypes;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.screenEdgeH),
          child: Text(
            !widget.hasEntries ? AppStrings.addVisitTypeLabel : AppStrings.addNewTypeLabel,
            style: AppTextStyles.labelChip(context).copyWith(color: context.textSecondary),
          ),
        ),
        const SizedBox(height: AppConstants.spaceSm),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.screenEdgeH),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: DropdownButtonFormField<String>(
                  value: _selectedTypeId,
                  hint: Text(
                    AppStrings.selectTypeHint,
                    style: AppTextStyles.bodyMedium(context).copyWith(color: context.textHint),
                  ),
                  items: widget.availableTypes.map((t) {
                    return DropdownMenuItem(
                      value: t['id'] as String,
                      child: Text(t['name'] as String, style: AppTextStyles.bodyMedium(context)),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedTypeId = val),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: context.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusInput),
                      borderSide: BorderSide(color: context.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: context.border),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMd, vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.spaceMd),
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: AppStrings.priceHint,
                    hintStyle: AppTextStyles.bodyMedium(context).copyWith(color: context.textHint),
                    filled: true,
                    fillColor: context.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusInput),
                      borderSide: BorderSide(color: context.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: context.border),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMd, vertical: 14),
                  ),
                  style: AppTextStyles.dataNumeric(context),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppConstants.spaceMd),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.screenEdgeH),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _selectedTypeId != null ? _submit : null,
              icon: const Icon(Icons.add, size: 18),
              label: Text(AppStrings.add, style: AppTextStyles.bodyLarge(context)),
              style: OutlinedButton.styleFrom(
                foregroundColor: context.primary,
                side: BorderSide(color: context.primary.withAlpha(76)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusButton),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

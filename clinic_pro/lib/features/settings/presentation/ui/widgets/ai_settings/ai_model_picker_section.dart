// ────────────────────────────────────────────────────────
// هذا الملف مسؤول عن ودجت اختيار موديل الذكاء الاصطناعي
// يدعم النظام الهجين: قائمة منسدلة ذكية، شرائح اقتراحات، وإدخال يدوي
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/services/ai/ai_provider_config.dart';
import 'package:clinic_pro/core/strings/app_strings.dart';
import 'package:clinic_pro/core/themes/app_colors.dart';
import 'package:clinic_pro/core/themes/app_text_styles.dart';
import 'package:clinic_pro/core/widgets/app_loading.dart';
import 'package:clinic_pro/features/settings/presentation/manager/ai_settings_state.dart';
import 'package:flutter/material.dart';

class AiModelPickerSection extends StatelessWidget {
  final AiSettingsState state;
  final TextEditingController modelTextController;
  final bool manualModelEntry;
  final VoidCallback onToggleManualEntry;
  final VoidCallback onRefreshModels;
  final ValueChanged<String> onSelectModel;

  const AiModelPickerSection({
    super.key,
    required this.state,
    required this.modelTextController,
    required this.manualModelEntry,
    required this.onToggleManualEntry,
    required this.onRefreshModels,
    required this.onSelectModel,
  });

  @override
  Widget build(BuildContext context) {
    final supportsFetching =
        AiProviderConfig.supportsModelFetching(state.selectedProvider);
    final requiresManualInput = !supportsFetching;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ─── Header: العنوان وأزرار التبديل والتحديث ───
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.selectModel,
              style: AppTextStyles.bodyMedium(context).copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (supportsFetching) ...[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: manualModelEntry
                        ? 'اختيار من القائمة'
                        : 'كتابة اسم الموديل يدوياً',
                    icon: Icon(
                      manualModelEntry ? Icons.list_rounded : Icons.edit_note_rounded,
                      size: 20,
                      color: context.primary,
                    ),
                    onPressed: onToggleManualEntry,
                  ),
                  TextButton.icon(
                    onPressed: state.modelsFetchStatus ==
                            AiModelsFetchStatus.fetching
                        ? null
                        : onRefreshModels,
                    icon: state.modelsFetchStatus ==
                            AiModelsFetchStatus.fetching
                        ? const AppLoadingWidget(size: AppLoadingSize.small)
                        : const Icon(Icons.sync_rounded, size: 16),
                    label: Text(
                      AppStrings.refreshModels,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),

        // ─── حقل الإدخال اليدوي أو القائمة المنسدلة ───
        if (requiresManualInput || manualModelEntry) ...[
          TextField(
            controller: modelTextController,
            decoration: InputDecoration(
              hintText: state.selectedProvider == AiProviderType.claude
                  ? 'مثال: claude-3-5-sonnet-20241022'
                  : 'أدخل اسم الموديل بالضبط',
              prefixIcon: const Icon(Icons.model_training_rounded, size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            onChanged: (val) => onSelectModel(val.trim()),
          ),
          _buildSuggestionChips(context),
        ] else ...[
          _buildDropdown(context),
        ],
      ],
    );
  }

  Widget _buildSuggestionChips(BuildContext context) {
    final defaultModels = AiProviderConfig.defaultModels(state.selectedProvider);
    if (defaultModels.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'أو اختر من الموديلات المقترحة:',
            style: AppTextStyles.caption(context).copyWith(
              color: context.textSecondary,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: defaultModels.map((m) {
              final isCurrent = state.selectedModel == m.id;
              return ActionChip(
                label: Text(
                  '${m.displayName}${m.isRecommended ? " ⭐" : ""}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                    color: isCurrent ? Colors.white : context.textPrimary,
                  ),
                ),
                backgroundColor:
                    isCurrent ? context.primary : context.surfaceColor,
                onPressed: () {
                  modelTextController.text = m.id;
                  onSelectModel(m.id);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(BuildContext context) {
    final defaultModels =
        AiProviderConfig.defaultModels(state.selectedProvider);

    final List<String> allModelIds = [];
    for (final m in defaultModels) {
      if (!allModelIds.contains(m.id)) allModelIds.add(m.id);
    }
    for (final m in state.availableModels) {
      if (!allModelIds.contains(m)) allModelIds.add(m);
    }
    if (state.selectedModel.isNotEmpty &&
        !allModelIds.contains(state.selectedModel)) {
      allModelIds.insert(0, state.selectedModel);
    }

    if (allModelIds.isEmpty) return const SizedBox.shrink();

    final selectedValue = allModelIds.contains(state.selectedModel)
        ? state.selectedModel
        : allModelIds.first;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.borderColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedValue,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down),
          items: allModelIds.map((modelId) {
            final defaultInfo = defaultModels
                .cast<AiModelInfo?>()
                .firstWhere((d) => d?.id == modelId, orElse: () => null);

            final isRecommended = defaultInfo?.isRecommended ?? false;
            final label = defaultInfo != null
                ? '${defaultInfo.displayName}${isRecommended ? " ⭐ (${AppStrings.recommended})" : ""}'
                : modelId;

            return DropdownMenuItem<String>(
              value: modelId,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight:
                      isRecommended ? FontWeight.bold : FontWeight.normal,
                  color: context.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) {
              onSelectModel(val);
              modelTextController.text = val;
            }
          },
        ),
      ),
    );
  }
}

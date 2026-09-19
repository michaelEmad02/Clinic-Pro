// ────────────────────────────────────────────────────────
// هذا الملف مسؤول عن شبكة اختيار مزود الذكاء الاصطناعي
// متجاوبة تلقائياً مع حجم الشاشة (Responsive Grid)
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/services/ai/ai_provider_config.dart';
import 'package:flutter/material.dart';

import 'ai_provider_card.dart';

class AiProviderPicker extends StatelessWidget {
  final AiProviderType selectedProvider;
  final ValueChanged<AiProviderType> onSelectProvider;

  const AiProviderPicker({
    super.key,
    required this.selectedProvider,
    required this.onSelectProvider,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 520 ? 3 : 2;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisExtent: 66,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: AiProviderType.values.length,
          itemBuilder: (context, index) {
            final provider = AiProviderType.values[index];
            return AiProviderCard(
              provider: provider,
              isSelected: selectedProvider == provider,
              onTap: () => onSelectProvider(provider),
            );
          },
        );
      },
    );
  }
}

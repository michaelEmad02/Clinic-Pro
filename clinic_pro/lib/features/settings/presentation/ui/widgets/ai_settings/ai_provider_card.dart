// ────────────────────────────────────────────────────────
// هذا الملف مسؤول عن كرت عرض واختيار مزود الذكاء الاصطناعي
// يحتوي على الشعار الرسمي للمزود ولونه المميز وتأثير الاختيار
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/services/ai/ai_provider_config.dart';
import 'package:clinic_pro/core/themes/app_colors.dart';
import 'package:clinic_pro/core/themes/app_text_styles.dart';
import 'package:flutter/material.dart';

import 'ai_provider_logo.dart';

class AiProviderCard extends StatelessWidget {
  final AiProviderType provider;
  final bool isSelected;
  final VoidCallback onTap;

  const AiProviderCard({
    super.key,
    required this.provider,
    required this.isSelected,
    required this.onTap,
  });

  Color _getBrandColor() {
    switch (provider) {
      case AiProviderType.openai:
        return const Color(0xFF10A37F);
      case AiProviderType.claude:
        return const Color(0xFFCC785C);
      case AiProviderType.gemini:
        return const Color(0xFF2563EB);
      case AiProviderType.deepseek:
        return const Color(0xFF0066FF);
      case AiProviderType.groq:
        return const Color(0xFFF55036);
      case AiProviderType.qwen:
        return const Color(0xFF7C3AED);
      case AiProviderType.gimi:
        return const Color(0xFF9333EA);
      case AiProviderType.custom:
        return const Color(0xFF64748B);
    }
  }

  String _getProviderTagline() {
    switch (provider) {
      case AiProviderType.openai:
        return 'الأكثر دقة وشهرة';
      case AiProviderType.claude:
        return 'تحليل ونصوص متقدمة';
      case AiProviderType.gemini:
        return 'استجابة سريعة وذكية';
      case AiProviderType.deepseek:
        return 'استدلال وكفاءة عالية';
      case AiProviderType.groq:
        return 'سرعة معالجة فائقة';
      case AiProviderType.qwen:
        return 'سحابي متعدد اللغات';
      case AiProviderType.gimi:
        return 'مساعد طبي تفاعلي';
      case AiProviderType.custom:
        return 'عنوان URL خاص';
    }
  }

  @override
  Widget build(BuildContext context) {
    final brandColor = _getBrandColor();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? brandColor.withOpacity(0.08)
                : context.surfaceColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? brandColor : context.borderColor.withOpacity(0.4),
              width: isSelected ? 1.8 : 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: brandColor.withOpacity(0.16),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              AiProviderLogo(provider: provider, size: 36),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            AiProviderConfig.displayName(provider),
                            style: AppTextStyles.bodyMedium(context).copyWith(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                              color: isSelected ? brandColor : context.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getProviderTagline(),
                      style: AppTextStyles.caption(context).copyWith(
                        color: isSelected
                            ? brandColor.withOpacity(0.85)
                            : context.textSecondary,
                        fontSize: 10.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: brandColor,
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

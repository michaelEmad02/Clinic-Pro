// ────────────────────────────────────────────────────────
// AppVoiceInputButton — زر الإدخال الصوتي الموحد للتطبيق بأكمله
// يُستخدم في أي شاشة (المرضى، المصاريف، الفواتير...)
// يختفي تلقائياً على نظام Windows ويفتح حوار التسجيل على الأجهزة المدعومة
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/services/i_voice_extraction_service.dart';
import 'package:clinic_pro/core/strings/app_strings.dart';
import 'package:clinic_pro/core/themes/app_colors.dart';
import 'package:clinic_pro/core/widgets/voice_input/app_voice_input_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppVoiceInputButton extends StatelessWidget {
  final ExtractionTarget target;
  final Map<String, dynamic>? extraContext;
  final ValueChanged<Map<String, dynamic>> onDataExtracted;

  const AppVoiceInputButton({
    super.key,
    required this.target,
    this.extraContext,
    required this.onDataExtracted,
  });

  @override
  Widget build(BuildContext context) {
    // إخفاء الزر تلقائياً على بيئة Windows
    if (defaultTargetPlatform == TargetPlatform.windows) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: 40,
      height: 40,
      child: IconButton(
        icon: Icon(
          Icons.mic_outlined,
          color: context.primary,
          size: 22,
        ),
        tooltip: AppStrings.voiceInput,
        onPressed: () async {
          final result = await AppVoiceInputDialog.show(
            context,
            target: target,
            extraContext: extraContext,
          );
          if (result != null) {
            onDataExtracted(result);
          }
        },
      ),
    );
  }
}

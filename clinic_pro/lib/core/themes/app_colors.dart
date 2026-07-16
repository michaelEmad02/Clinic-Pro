// ────────────────────────────────────────────────────────
// هذا الملف مسؤول عن تعريف الألوان المستخدمة في التطبيق
// يحتوي على باليت الألوان للوضع الفاتح (Light) والداكن (Dark)
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

class AppColors {
  // ألوان باليت الوضع الفاتح (Light Palette)
  static const Color primary = Color(0xFF00526D); // HTML 'primary'
  static const Color primaryContainer =
      Color(0xFF1A6B8A); // HTML 'primary-container'
  static const Color primaryLight = Color(0xFFEAF4F8); // HTML 'primary-light'

  static const Color accent = Color(0xFF2ECC9A);
  static const Color warning = Color(0xFFF5A623);
  static const Color danger = Color(0xFFE84C4C);

  // ألوان الخلفيات والأسطح
  static const Color background = Color(0xFFF7F9FC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF2F4F7);
  static const Color surfaceContainerHigh = Color(0xFFE6E8EB);
  static const Color border = Color(0xFFE2E8F0);
  static const Color outline = Color(0xFF70787E);
  static const Color outlineVariant = Color(0xFFBFC8CE);

  // ألوان النصوص
  static const Color textPrimary = Color(0xFF1A202C);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textHint = Color(0xFFA0AEC0);
  static const Color onSurface = Color(0xFF191C1E);
  static const Color onSurfaceVariant = Color(0xFF40484D);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFFBCE7FF);

  // ألوان ثنائية النغمة (Semantic Badges)
  static const Color icon = Color(0xFF7C3AED);
  static const Color iconBg = Color(0xFFF3E8FF);
  static const Color successBg = Color(0xFFD1FAE5);
  static const Color successText = Color(0xFF065F46);
  static const Color warningBg = Color(0xFFFEF3C7);
  static const Color warningText = Color(0xFF92400E);
  static const Color dangerBg = Color(0xFFFEE2E2);
  static const Color dangerText = Color(0xFF991B1B);
  static const Color dangerLight = Color(0xFFFEE2E2); // خلفية خفيفة للخطر
  static const Color surfaceAlt = Color(0xFFF1F5F9); // سطح بديل للرقاقات
  static const Color surfaceVariant = Color(0xFFE0E3E6);
  static const Color surfaceBright = Color(0xFFF7F9FC);
  static const Color surfaceContainer =
      Color(0xFFECEEF1); // DESIGN.md surface-container
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color primaryFixedDim = Color(0xFF8BCFF2);
  static const Color surfaceTint = Color(0xFF106685); // DESIGN.md surface-tint
  static const Color warningLight = Color(0xFFFEF3C7); // خلفية خفيفة للتحذير

  // ────────────────────────────────────────────────────────
  // ألوان باليت الوضع الداكن (Dark Palette)
  // ────────────────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkBorder = Color(0xFF2D3748);
  static const Color darkTextPrimary = Color(0xFFEDF2F7);
  static const Color darkTextSecondary = Color(0xFFA0AEC0);
  static const Color darkPrimaryLight = Color(0xFF1A2D35);
}

// ────────────────────────────────────────────────────────
// امتداد (Extension) لتسهيل الوصول للألوان الديناميكية
// بناءً على وضع المظهر الحالي (Light vs Dark)
// ────────────────────────────────────────────────────────
extension ThemeColors on BuildContext {
  // معرفة هل المظهر الحالي داكن أم لا
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  // لون الخلفية الأساسي
  Color get backgroundColor =>
      isDarkMode ? AppColors.darkBackground : AppColors.background;

  // لون الأسطح والبطاقات (Surfaces)
  Color get surfaceColor =>
      isDarkMode ? AppColors.darkSurface : AppColors.surface;

  Color get primaryFixedDim => AppColors.primaryFixedDim;

  // لون الحدود والفواصل
  Color get borderColor => isDarkMode ? AppColors.darkBorder : AppColors.border;

  // لون النصوص الأساسية
  Color get textPrimary =>
      isDarkMode ? AppColors.darkTextPrimary : AppColors.textPrimary;

  // لون النصوص الثانوية والتوضيحية
  Color get textSecondary =>
      isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary;

  // لون الخفيفة الأساسية (مثل خلفيات الأزرار أو الرقاقات النشطة)
  Color get primaryLightColor =>
      isDarkMode ? AppColors.darkPrimaryLight : AppColors.primaryLight;

  // لون النص فوق اللون الأساسي (أبيض دائماً)
  Color get onPrimary => AppColors.onPrimary;

  // لون الخطر (أحمر)
  Color get danger => AppColors.danger;

  // خلفية الخطر (أحمر فاتح)
  Color get dangerBg => AppColors.dangerBg;

  // نص الخطر (أحمر داكن)
  Color get dangerText => AppColors.dangerText;

  // لون النجاح (أخضر)
  Color get success => AppColors.successText;

  // لون التحذير (برتقالي)
  Color get warning => AppColors.warning;

  // لون الأساسي (ثابت)
  Color get primary => AppColors.primary;

  // لون السطح (Surface)
  Color get surface => isDarkMode ? AppColors.darkSurface : AppColors.surface;

  // لون الحدود
  Color get border => isDarkMode ? AppColors.darkBorder : AppColors.border;

  // لون الخلفية (Background)
  Color get background =>
      isDarkMode ? AppColors.darkBackground : AppColors.background;

  // لون النص التلميحي
  Color get textHint => AppColors.textHint;

  // لون حاوية الأساسي (primaryContainer)
  Color get primaryContainer => AppColors.primaryContainer;

  // اللون المميز (accent)
  Color get accent => AppColors.accent;

  // لون النص فوق حاوية الأساسي (onPrimaryContainer)
  Color get onPrimaryContainer => AppColors.onPrimaryContainer;

  // لون سطح حاوية منخفض (surfaceContainerLow)
  Color get surfaceContainerLow => AppColors.surfaceContainerLow;

  // لون سطح ساطع (surfaceBright)
  Color get surfaceBright => AppColors.surfaceBright;

  Color get surfaceTint => AppColors.surfaceTint;

  // لون خط خارجي (outline)
  Color get outline => AppColors.outline;

  // لون نص التحذير
  Color get warningText => AppColors.warningText;

  // لون خلفية التحذير
  Color get warningBg => AppColors.warningBg;

  // لون نص النجاح
  Color get successText => AppColors.successText;

  // لون خلفية النجاح
  Color get successBg => AppColors.successBg;
}

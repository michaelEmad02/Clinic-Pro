// ────────────────────────────────────────────────────────
// هذا الملف مسؤول عن تعريف الألوان المستخدمة في التطبيق
// يحتوي على باليت الألوان للوضع الفاتح (Light) والداكن (Dark)
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

class AppColors {
  // ألوان باليت الوضع الفاتح (Light Palette)
  static const Color primary = Color(0xFF1A6B8A);
  static const Color primaryDark = Color(0xFF00526D);
  static const Color primaryLight = Color(0xFFEAF4F8);
  static const Color accent = Color(0xFF2ECC9A); // للنجاح والحضور المؤكد
  static const Color warning = Color(0xFFF5A623); // للحالات الطارئة/الانتظار
  static const Color danger = Color(0xFFE84C4C); // للخطأ أو الإلغاء

  // ألوان الخلفيات والأسطح
  static const Color background = Color(0xFFF7F9FC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE2E8F0);

  // ألوان النصوص
  static const Color textPrimary = Color(0xFF1A202C);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textHint = Color(0xFFA0AEC0);

  // ألوان ثنائية النغمة (Semantic Badges)
  static const Color successBg = Color(0xFFD1FAE5);
  static const Color successText = Color(0xFF065F46);
  static const Color warningBg = Color(0xFFFEF3C7);
  static const Color warningText = Color(0xFF92400E);
  static const Color dangerBg = Color(0xFFFEE2E2);
  static const Color dangerText = Color(0xFF991B1B);

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

// ────────────────────────────────────────────────────────
// هذا الملف مسؤول عن دوال المساعدة للتصميم المتجاوب (Responsive)
// يستخدم Breakpoints: mobile < 600, tablet < 900, desktop >= 900
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

class ResponsiveHelper {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 900;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 900;

  /// عدد الأعمدة في Grid بناءً على عرض الشاشة
  static int gridColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 900) return 3;
    if (width >= 600) return 2;
    return 1;
  }
}

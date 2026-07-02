// ────────────────────────────────────────────────────────
// هذا الملف يحتوي على الثوابت التصميمية للتطبيق
// يشمل ذلك أقطار الحواف (Radius) والمسافات الهامشية (Spacing)
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

class AppConstants {
  // أقطار الحواف الدائرية للبطاقات والأزرار والحقول (Border Radius)
  static const double radiusCard = 16.0;
  static const double radiusButton = 12.0;
  static const double radiusChip = 20.0;
  static const double radiusInput = 10.0;
  static const double radiusSheet = 24.0;
  static const double radiusSm = 8.0;
  static const double radiusXs = 4.0;
  static const double radiusFull = 100.0;

  // المسافات البينية والهوامش (Spacing Scale)
  static const double spaceXs = 4.0;
  static const double spaceSm = 8.0;
  static const double spaceMd = 16.0;
  static const double spaceLg = 24.0;
  static const double spaceXl = 32.0;

  // هوامش الشاشة الافتراضية
  static const double screenEdgeH = 16.0;
  static const double screenEdgeV = 20.0;

  // ارتفاع عناصر القوائم الافتراضي
  static const double listItemHeight = 72.0;

  // أيقونات
  static const double iconSizeSm = 14.0;
  static const double iconSizeMd = 16.0;
  static const double iconSizeLg = 18.0;
  static const double iconSizeXl = 20.0;

  // الصور الرمزية والشعارات
  static const double avatarSizeSm = 48.0;
  static const double avatarSizeLg = 128.0;

  // ظل البطاقة الافتراضي
  static List<BoxShadow> get cardShadow => const [
        BoxShadow(
          color: Color(0x08000000),
          blurRadius: 4,
          offset: Offset(0, 1),
        ),
      ];
}

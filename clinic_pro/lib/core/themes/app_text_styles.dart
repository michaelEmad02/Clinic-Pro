// ────────────────────────────────────────────────────────
// هذا الملف مسؤول عن تعريف الخطوط وأنماط النصوص في التطبيق
// يدمج بين خط Cairo للنصوص العربية و خط Inter للأرقام والأسعار
// يدعم تحجيم الخطوط المتجاوب تلقائياً على سطح المكتب
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/responsive_helper.dart';

class AppTextStyles {
  // أنماط العناوين الرئيسية (Headlines)
  static TextStyle headlineLarge(BuildContext context) => GoogleFonts.cairo(
        fontSize: ResponsiveHelper.isDesktop(context) ? 32 : 28,
        fontWeight: FontWeight.bold,
        height: 1.2,
      );

  static TextStyle headlineMedium(BuildContext context) => GoogleFonts.cairo(
        fontSize: ResponsiveHelper.isDesktop(context) ? 25 : 22,
        fontWeight: FontWeight.w600,
        height: 1.3,
      );

  static TextStyle headlineSmall(BuildContext context) => GoogleFonts.cairo(
        fontSize: ResponsiveHelper.isDesktop(context) ? 18 : 16,
        fontWeight: FontWeight.w600,
        height: 1.4,
      );

  // أنماط النصوص العادية (Body Text)
  static TextStyle bodyLarge(BuildContext context) => GoogleFonts.cairo(
        fontSize: ResponsiveHelper.isDesktop(context) ? 17 : 15,
        fontWeight: FontWeight.normal,
        height: 1.5,
      );

  static TextStyle bodyMedium(BuildContext context) => GoogleFonts.cairo(
        fontSize: ResponsiveHelper.isDesktop(context) ? 16 : 14,
        fontWeight: FontWeight.normal,
        height: 1.5,
      );

  static TextStyle caption(BuildContext context) => GoogleFonts.cairo(
        fontSize: ResponsiveHelper.isDesktop(context) ? 13.5 : 12,
        fontWeight: FontWeight.normal,
        height: 1.4,
      );

  static TextStyle labelChip(BuildContext context) => GoogleFonts.cairo(
        fontSize: ResponsiveHelper.isDesktop(context) ? 13 : 11,
        fontWeight: FontWeight.w500,
        height: 1.0,
      );

  // نمط الأرقام والأسعار والتواريخ (Inter Font)
  static TextStyle dataNumeric(BuildContext context) => GoogleFonts.inter(
        fontSize: ResponsiveHelper.isDesktop(context) ? 15 : 13,
        fontWeight: FontWeight.bold,
        height: 1.0,
      );
}

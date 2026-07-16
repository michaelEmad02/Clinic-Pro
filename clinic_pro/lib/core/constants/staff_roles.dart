// ────────────────────────────────────────────────────────
// تعريف أدوار الموظفين في النظام
// يُستخدم في شاشات الدعوة وإدارة الصلاحيات
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../strings/app_strings.dart';

/// أدوار الموظفين المتاحة في العيادة
enum StaffRoles {
  doctor,
  secretary,
  owner;

  /// الاسم المعروض حسب اللغة
  String get label {
    switch (this) {
      case StaffRoles.doctor:
        return AppStrings.roleLabel('doctor');
      case StaffRoles.secretary:
        return AppStrings.roleLabel('secretary');
      case StaffRoles.owner:
        return AppStrings.roleLabel('owner');
    }
  }

  /// الأيقونة المرتبطة بالدور
  IconData get icon {
    switch (this) {
      case StaffRoles.doctor:
        return Icons.medical_services_outlined;
      case StaffRoles.secretary:
        return Icons.front_hand_outlined;
      case StaffRoles.owner:
        return Icons.admin_panel_settings_outlined;
    }
  }
}

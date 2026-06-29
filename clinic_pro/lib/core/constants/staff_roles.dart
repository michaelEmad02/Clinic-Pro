// ────────────────────────────────────────────────────────
// تعريف أدوار الموظفين في النظام
// يُستخدم في شاشات الدعوة وإدارة الصلاحيات
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

/// أدوار الموظفين المتاحة في العيادة
enum StaffRoles {
  doctor,
  secretary,
  owner;

  /// الاسم المعروض بالعربية
  String get label {
    switch (this) {
      case StaffRoles.doctor:
        return 'طبيب';
      case StaffRoles.secretary:
        return 'سكرتير';
      case StaffRoles.owner:
        return 'مالك';
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

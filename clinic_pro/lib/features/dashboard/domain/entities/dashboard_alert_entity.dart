// ─────────────────────────────────────────
// Entity للتنبيهات المعروضة في لوحة التحكم
// يمثل تنبيهة واحدة (تحذير أو معلومة)
// ─────────────────────────────────────────

import 'package:equatable/equatable.dart';

class DashboardAlertEntity extends Equatable {
  final String id;
  final String title;
  final String message;
  final DashboardAlertType type;

  const DashboardAlertEntity({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
  });

  @override
  List<Object?> get props => [id, title, message, type];
}

enum DashboardAlertType {
  warning,
  info,
}

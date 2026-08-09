// ────────────────────────────────────────────────────────
// PrintingSettingsState — حالة إدارة إعدادات الطباعة للمالك
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/features/settings/domain/entities/printing_settings_entity.dart';
import 'package:equatable/equatable.dart';

enum PrintingSettingsStatus { initial, loading, success, error, saving, saved }

class PrintingSettingsState extends Equatable {
  final PrintingSettingsStatus status;
  final PrintingSettingsEntity settings;
  final String? errorMessage;

  const PrintingSettingsState({
    this.status = PrintingSettingsStatus.initial,
    this.settings = const PrintingSettingsEntity(),
    this.errorMessage,
  });

  PrintingSettingsState copyWith({
    PrintingSettingsStatus? status,
    PrintingSettingsEntity? settings,
    String? errorMessage,
  }) {
    return PrintingSettingsState(
      status: status ?? this.status,
      settings: settings ?? this.settings,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, settings, errorMessage];
}

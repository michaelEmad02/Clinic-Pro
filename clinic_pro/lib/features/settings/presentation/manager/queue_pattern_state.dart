// ────────────────────────────────────────────────────────
// QueuePatternState — حالة نمط ترتيب طابور الطبيب
// تحتوي على قائمة الخانات (slots) المستخرجة من doctor_queue_rules.slots
// ────────────────────────────────────────────────────────

import 'package:equatable/equatable.dart';

class QueuePatternState extends Equatable {
  final String queueSystem; // 'arrival', 'booking', 'pattern', 'scheduled'
  final List<String> slots;
  final List<String> slotLabels;
  final int cycleLength;
  final int? avgVisitMinutes;
  final bool isActive;
  final bool isLoading;
  final bool isSaving;
  final String? error;
  final bool isDirty;

  const QueuePatternState({
    this.queueSystem = 'arrival',
    this.slots = const [],
    this.slotLabels = const [],
    this.cycleLength = 0,
    this.avgVisitMinutes,
    this.isActive = false,
    this.isLoading = false,
    this.isSaving = false,
    this.error,
    this.isDirty = false,
  });

  QueuePatternState copyWith({
    String? queueSystem,
    List<String>? slots,
    List<String>? slotLabels,
    int? cycleLength,
    int? avgVisitMinutes,
    bool? isActive,
    bool? isLoading,
    bool? isSaving,
    String? error,
    bool? isDirty,
  }) {
    return QueuePatternState(
      queueSystem: queueSystem ?? this.queueSystem,
      slots: slots ?? this.slots,
      slotLabels: slotLabels ?? this.slotLabels,
      cycleLength: cycleLength ?? this.cycleLength,
      avgVisitMinutes: avgVisitMinutes ?? this.avgVisitMinutes,
      isActive: isActive ?? this.isActive,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: error,
      isDirty: isDirty ?? this.isDirty,
    );
  }

  @override
  List<Object?> get props => [
        queueSystem,
        slots,
        slotLabels,
        cycleLength,
        avgVisitMinutes,
        isActive,
        isLoading,
        isSaving,
        error,
        isDirty,
      ];
}

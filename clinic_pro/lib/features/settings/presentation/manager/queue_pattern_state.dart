// ────────────────────────────────────────────────────────
// QueuePatternState — حالة نمط ترتيب طابور الطبيب
// تحتوي على قائمة الخانات (slots) المستخرجة من doctor_queue_rules.slots
// ────────────────────────────────────────────────────────

import 'package:equatable/equatable.dart';

class QueuePatternState extends Equatable {
  final List<String> slots;
  final int cycleLength;
  final bool isActive;
  final bool isLoading;
  final bool isSaving;
  final String? error;
  final bool isDirty;

  const QueuePatternState({
    this.slots = const [],
    this.cycleLength = 0,
    this.isActive = false,
    this.isLoading = false,
    this.isSaving = false,
    this.error,
    this.isDirty = false,
  });

  QueuePatternState copyWith({
    List<String>? slots,
    int? cycleLength,
    bool? isActive,
    bool? isLoading,
    bool? isSaving,
    String? error,
    bool? isDirty,
  }) {
    return QueuePatternState(
      slots: slots ?? this.slots,
      cycleLength: cycleLength ?? this.cycleLength,
      isActive: isActive ?? this.isActive,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: error,
      isDirty: isDirty ?? this.isDirty,
    );
  }

  @override
  List<Object?> get props => [slots, cycleLength, isActive, isLoading, isSaving, error, isDirty];
}

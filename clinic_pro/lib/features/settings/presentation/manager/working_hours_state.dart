// ────────────────────────────────────────────────────────
// WorkingHoursState — يمثل حالة تعديل ساعات عمل العيادة
// ────────────────────────────────────────────────────────

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class WorkingPeriod extends Equatable {
  final TimeOfDay start;
  final TimeOfDay end;

  const WorkingPeriod({required this.start, required this.end});

  @override
  List<Object?> get props => [start, end];
}

class WorkingHoursDay extends Equatable {
  final String dayKey;
  final String dayName;
  final String keyChar;
  final bool isOpen;
  final List<WorkingPeriod> periods;

  const WorkingHoursDay({
    required this.dayKey,
    required this.dayName,
    required this.keyChar,
    this.isOpen = true,
    required this.periods,
  });

  WorkingHoursDay copyWith({
    bool? isOpen,
    List<WorkingPeriod>? periods,
  }) {
    return WorkingHoursDay(
      dayKey: dayKey,
      dayName: dayName,
      keyChar: keyChar,
      isOpen: isOpen ?? this.isOpen,
      periods: periods ?? this.periods,
    );
  }

  @override
  List<Object?> get props => [dayKey, dayName, keyChar, isOpen, periods];
}

class WorkingHoursState extends Equatable {
  final bool isLoading;
  final bool isSaving;
  final String? error;
  final List<WorkingHoursDay> schedule;

  const WorkingHoursState({
    this.isLoading = false,
    this.isSaving = false,
    this.error,
    this.schedule = const [],
  });

  WorkingHoursState copyWith({
    bool? isLoading,
    bool? isSaving,
    String? error,
    List<WorkingHoursDay>? schedule,
  }) {
    return WorkingHoursState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: error,
      schedule: schedule ?? this.schedule,
    );
  }

  @override
  List<Object?> get props => [isLoading, isSaving, error, schedule];
}

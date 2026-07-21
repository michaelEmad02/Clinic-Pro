// ────────────────────────────────────────────────────────
// WorkingHoursCubit — يدير منطق وحالة ساعات عمل العيادة
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/features/settings/domain/entities/doctor_schedule_entity.dart';
import 'package:clinic_pro/features/settings/domain/usecases/get_doctor_schedules_usecase.dart';
import 'package:clinic_pro/features/settings/domain/usecases/upsert_doctor_schedule_usecase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'working_hours_state.dart';

class WorkingHoursCubit extends Cubit<WorkingHoursState> {
  final GetDoctorSchedulesUseCase getDoctorSchedulesUseCase;
  final UpsertDoctorScheduleUseCase upsertDoctorScheduleUseCase;

  WorkingHoursCubit(
    this.getDoctorSchedulesUseCase,
    this.upsertDoctorScheduleUseCase,
  ) : super(const WorkingHoursState());

  static const _dayConfigs = [
    {'key': 'saturday', 'name': 'السبت', 'char': 'S', 'dayOfWeek': 0},
    {'key': 'sunday', 'name': 'الأحد', 'char': 'S', 'dayOfWeek': 1},
    {'key': 'monday', 'name': 'الاثنين', 'char': 'M', 'dayOfWeek': 2},
    {'key': 'tuesday', 'name': 'الثلاثاء', 'char': 'T', 'dayOfWeek': 3},
    {'key': 'wednesday', 'name': 'الأربعاء', 'char': 'W', 'dayOfWeek': 4},
    {'key': 'thursday', 'name': 'الخميس', 'char': 'T', 'dayOfWeek': 5},
    {'key': 'friday', 'name': 'الجمعة', 'char': 'F', 'dayOfWeek': 6},
  ];

  /// تحميل ساعات العمل للعيادة
  Future<void> load(String doctorId, String clinicId) async {
    emit(state.copyWith(isLoading: true, error: null));

    final result =
        await getDoctorSchedulesUseCase(doctorId: doctorId, clinicId: clinicId);

    result.fold(
      (failure) =>
          emit(state.copyWith(isLoading: false, error: failure.message)),
      (data) {
        final schedule = _dayConfigs.map((cfg) {
          final key = cfg['key'] as String;
          final name = cfg['name'] as String;
          final char = cfg['char'] as String;
          final dayOfWeek = cfg['dayOfWeek'] as int;

          final daySchedules = data
              .where((item) => item.dayOfWeek == dayOfWeek)
              .toList();

          if (daySchedules.isEmpty) {
            return WorkingHoursDay(
              dayKey: key,
              dayName: name,
              keyChar: char,
              isOpen: false,
              periods: const [],
            );
          }

          final periods = daySchedules.map((s) {
            final start = _parseTime(s.startTime) ?? const TimeOfDay(hour: 9, minute: 0);
            final end = _parseTime(s.endTime) ?? const TimeOfDay(hour: 17, minute: 0);
            return WorkingPeriod(start: start, end: end);
          }).toList();

          return WorkingHoursDay(
            dayKey: key,
            dayName: name,
            keyChar: char,
            isOpen: true,
            periods: periods,
          );
        }).toList();

        emit(state.copyWith(
          isLoading: false,
          schedule: schedule,
        ));
      },
    );
  }

  /// تغيير حالة اليوم (مفتوح / مغلق)
  void toggleDayOpen(String dayKey, bool isOpen) {
    final updatedSchedule = state.schedule.map((day) {
      if (day.dayKey == dayKey) {
        // إذا فُتح اليوم ولا يوجد فترات، نضع فترة افتراضية من 9 إلى 5
        final periods = isOpen && day.periods.isEmpty
            ? const [
                WorkingPeriod(
                    start: TimeOfDay(hour: 9, minute: 0),
                    end: TimeOfDay(hour: 17, minute: 0))
              ]
            : day.periods;
        return day.copyWith(isOpen: isOpen, periods: periods);
      }
      return day;
    }).toList();

    emit(state.copyWith(schedule: updatedSchedule));
  }

  /// إضافة فترة عمل لليوم
  void addPeriod(String dayKey, WorkingPeriod period) {
    final updatedSchedule = state.schedule.map((day) {
      if (day.dayKey == dayKey) {
        final updatedPeriods = [...day.periods, period];
        return day.copyWith(periods: updatedPeriods);
      }
      return day;
    }).toList();

    emit(state.copyWith(schedule: updatedSchedule));
  }

  /// تحديث فترة عمل معينة
  void updatePeriod(String dayKey, int index, WorkingPeriod period) {
    final updatedSchedule = state.schedule.map((day) {
      if (day.dayKey == dayKey && index >= 0 && index < day.periods.length) {
        final updatedPeriods = [...day.periods]..[index] = period;
        return day.copyWith(periods: updatedPeriods);
      }
      return day;
    }).toList();

    emit(state.copyWith(schedule: updatedSchedule));
  }

  /// حذف فترة عمل لليوم
  void removePeriod(String dayKey, int index) {
    final updatedSchedule = state.schedule.map((day) {
      if (day.dayKey == dayKey && index >= 0 && index < day.periods.length) {
        final updatedPeriods = [...day.periods]..removeAt(index);
        final isOpen = updatedPeriods.isNotEmpty;
        return day.copyWith(periods: updatedPeriods, isOpen: isOpen);
      }
      return day;
    }).toList();

    emit(state.copyWith(schedule: updatedSchedule));
  }

  /// حفظ البيانات للعيادة
  Future<void> save(String doctorId, String clinicId) async {
    emit(state.copyWith(isSaving: true, error: null));

    final List<DoctorScheduleEntity> schedulesToSave = [];

    for (final day in state.schedule) {
      final cfg = _dayConfigs.firstWhere((c) => c['key'] == day.dayKey);
      final dayOfWeek = cfg['dayOfWeek'] as int;

      if (!day.isOpen || day.periods.isEmpty) {
        continue;
      }

      for (final period in day.periods) {
        schedulesToSave.add(
          DoctorScheduleEntity(
            id: '', // Supabase auto-generates ID if empty/new
            doctorId: doctorId,
            clinicId: clinicId,
            dayOfWeek: dayOfWeek,
            startTime: _formatTime(period.start),
            endTime: _formatTime(period.end),
          ),
        );
      }
    }

    final result = await upsertDoctorScheduleUseCase(schedulesToSave);

    result.fold(
      (failure) =>
          emit(state.copyWith(isSaving: false, error: failure.message)),
      (_) => emit(state.copyWith(isSaving: false)),
    );
  }

  TimeOfDay? _parseTime(String time) {
    final parts = time.split(':');
    if (parts.length == 2) {
      final hour = int.tryParse(parts[0]);
      final minute = int.tryParse(parts[1]);
      if (hour != null && minute != null) {
        return TimeOfDay(hour: hour, minute: minute);
      }
    }
    return null;
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

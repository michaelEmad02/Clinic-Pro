// ────────────────────────────────────────────────────────
// QueuePatternCubit — يدير نمط ترتيب طابور الطبيب
// يحمل البيانات من MockData.doctorQueueRules وفقاً للمخطط doctor_queue_rules.slots
// ────────────────────────────────────────────────────────

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/mocks/mock_data.dart';
import 'queue_pattern_state.dart';

class QueuePatternCubit extends Cubit<QueuePatternState> {
  QueuePatternCubit() : super(const QueuePatternState());

  // معرف الطبيب الحالي (محاكاة)
  static const _currentDoctorId = 'u-doc-1';
  static const _currentClinicId = 'c-1';

  // معرف قاعدة الطابور المُحمَّلة (لتحديثها عند الحفظ)
  String? _loadedRuleId;

  /// تحميل النمط الحالي من MockData
  void loadPattern() {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final rules = MockData.doctorQueueRules.where((r) =>
        r['doctor_id'] == _currentDoctorId && r['clinic_id'] == _currentClinicId
      ).toList();

      if (rules.isEmpty) {
        emit(state.copyWith(
          slots: [],
          cycleLength: 0,
          isActive: false,
          isLoading: false,
          isDirty: false,
        ));
        return;
      }

      final rule = rules.first;
      _loadedRuleId = rule['id'] as String;

      final slots = (rule['slots'] as List<dynamic>?)?.cast<String>() ?? [];
      final isActive = rule['is_active'] as bool? ?? false;

      emit(state.copyWith(
        slots: List.from(slots),
        cycleLength: slots.length,
        isActive: isActive,
        isLoading: false,
        isDirty: false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  /// إضافة نوع كشف إلى نهاية النمط
  void addSlot(String slotType) {
    final updated = [...state.slots, slotType];
    emit(state.copyWith(slots: updated, cycleLength: updated.length, isDirty: true, error: null));
  }

  /// حذف نوع كشف من النمط باستخدام الفهرس
  void removeSlot(int index) {
    if (index < 0 || index >= state.slots.length) return;
    final updated = [...state.slots]..removeAt(index);
    emit(state.copyWith(slots: updated, cycleLength: updated.length, isDirty: true, error: null));
  }

  /// إعادة ترتيب الخانات (سحب وإفلات)
  void reorderSlots(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= state.slots.length) return;
    if (newIndex < 0 || newIndex >= state.slots.length) return;

    final updated = [...state.slots];
    final item = updated.removeAt(oldIndex);
    updated.insert(newIndex, item);
    emit(state.copyWith(slots: updated, cycleLength: updated.length, isDirty: true, error: null));
  }

  /// حفظ النمط في MockData.doctorQueueRules
  Future<void> savePattern() async {
    if (!state.isDirty) return;
    emit(state.copyWith(isSaving: true, error: null));

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      if (_loadedRuleId != null) {
        final index = MockData.doctorQueueRules.indexWhere((r) => r['id'] == _loadedRuleId);
        if (index != -1) {
          MockData.doctorQueueRules[index] = {
            ...MockData.doctorQueueRules[index],
            'slots': List.from(state.slots),
            'cycle_length': state.slots.length,
          };
        }
      } else {
        final newRule = {
          'id': 'dqr-${DateTime.now().millisecondsSinceEpoch}',
          'doctor_id': _currentDoctorId,
          'clinic_id': _currentClinicId,
          'slots': List.from(state.slots),
          'cycle_length': state.slots.length,
          'is_active': true,
        };
        MockData.doctorQueueRules.add(newRule);
        _loadedRuleId = newRule['id'] as String;
      }

      emit(state.copyWith(isSaving: false, isDirty: false, isActive: true));
    } catch (e) {
      emit(state.copyWith(isSaving: false, error: e.toString()));
    }
  }
}

// ────────────────────────────────────────────────────────
// QueuePatternCubit — يدير نمط ترتيب طابور الطبيب عبر ICloudService
// ────────────────────────────────────────────────────────

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/services/i_cloud_service.dart';
import 'queue_pattern_state.dart';

@injectable
class QueuePatternCubit extends Cubit<QueuePatternState> {
  final ICloudService _cloudService;

  QueuePatternCubit(this._cloudService) : super(const QueuePatternState());

  // معرف الطبيب الحالي (محاكاة)
  static const _currentDoctorId = 'u-doc-1';
  static const _currentClinicId = 'c-1';

  // معرف قاعدة الطابور المُحمَّلة
  String? _loadedRuleId;

  /// تحميل النمط الحالي من ICloudService
  Future<void> loadPattern() async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final rules = await _cloudService.select(
        table: 'doctor_queue_rules',
        eq: {'doctor_id': _currentDoctorId, 'clinic_id': _currentClinicId},
      );

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
        slotLabels: List.filled(slots.length, ''),
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
  void addSlot(String slotType, {String label = ''}) {
    final updatedSlots = [...state.slots, slotType];
    final updatedLabels = [...state.slotLabels, label.isEmpty ? slotType : label];
    emit(state.copyWith(slots: updatedSlots, slotLabels: updatedLabels, cycleLength: updatedSlots.length, isDirty: true, error: null));
  }

  /// حذف نوع كشف من النمط باستخدام الفهرس
  void removeSlot(int index) {
    if (index < 0 || index >= state.slots.length) return;
    final updatedSlots = [...state.slots]..removeAt(index);
    final updatedLabels = [...state.slotLabels];
    if (index < updatedLabels.length) updatedLabels.removeAt(index);
    emit(state.copyWith(slots: updatedSlots, slotLabels: updatedLabels, cycleLength: updatedSlots.length, isDirty: true, error: null));
  }

  /// إعادة ترتيب الخانات (سحب وإفلات)
  void reorderSlots(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= state.slots.length) return;
    if (newIndex < 0 || newIndex >= state.slots.length) return;

    final updatedSlots = [...state.slots];
    final item = updatedSlots.removeAt(oldIndex);
    updatedSlots.insert(newIndex, item);

    final updatedLabels = [...state.slotLabels];
    if (oldIndex < updatedLabels.length) {
      final label = updatedLabels.removeAt(oldIndex);
      updatedLabels.insert(newIndex, newIndex < updatedLabels.length ? label : '');
    }

    emit(state.copyWith(slots: updatedSlots, slotLabels: updatedLabels, cycleLength: updatedSlots.length, isDirty: true, error: null));
  }

  /// حفظ النمط في ICloudService
  Future<void> savePattern() async {
    if (!state.isDirty) return;
    emit(state.copyWith(isSaving: true, error: null));

    try {
      if (_loadedRuleId != null) {
        await _cloudService.update(
          table: 'doctor_queue_rules',
          data: {
            'slots': List.from(state.slots),
            'cycle_length': state.slots.length,
          },
          matchColumn: 'id',
          matchValue: _loadedRuleId,
        );
      } else {
        final newRule = {
          'doctor_id': _currentDoctorId,
          'clinic_id': _currentClinicId,
          'slots': List.from(state.slots),
          'cycle_length': state.slots.length,
          'is_active': true,
        };
        final inserted = await _cloudService.insert(
          table: 'doctor_queue_rules',
          data: newRule,
        );
        _loadedRuleId = inserted['id'] as String;
      }

      emit(state.copyWith(isSaving: false, isDirty: false, isActive: true));
    } catch (e) {
      emit(state.copyWith(isSaving: false, error: e.toString()));
    }
  }
}

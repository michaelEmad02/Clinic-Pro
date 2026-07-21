// ────────────────────────────────────────────────────────
// QueuePatternCubit — يدير نمط ترتيب طابور الطبيب عبر الـ UseCases
// ────────────────────────────────────────────────────────

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecases/get_doctor_appointment_types_usecase.dart';
import '../../domain/usecases/get_global_appointment_types_usecase.dart';
import '../../domain/usecases/get_queue_rule_usecase.dart';
import '../../domain/usecases/upsert_queue_rule_usecase.dart';
import 'queue_pattern_state.dart';

@injectable
class QueuePatternCubit extends Cubit<QueuePatternState> {
  final GetQueueRuleUseCase _getQueueRuleUseCase;
  final UpsertQueueRuleUseCase _upsertQueueRuleUseCase;
  final GetDoctorAppointmentTypesUseCase _getDoctorAppointmentTypesUseCase;
  final GetGlobalAppointmentTypesUseCase _getGlobalAppointmentTypesUseCase;

  QueuePatternCubit(
    this._getQueueRuleUseCase,
    this._upsertQueueRuleUseCase,
    this._getDoctorAppointmentTypesUseCase,
    this._getGlobalAppointmentTypesUseCase,
  ) : super(const QueuePatternState());

  // معرفات الطبيب والعيادة (يمكن جلبها ديناميكياً من Cubit الإعدادات الرئيسي أو الـ Auth)
  String _doctorId = 'u-doc-1';
  String _clinicId = 'c-1';

  /// إعداد المعرفات وتعيينها قبل تحميل النمط
  void init(String doctorId, String clinicId) {
    _doctorId = doctorId;
    _clinicId = clinicId;
  }

  /// جلب أنواع الزيارات المتاحة للطبيب عبر الـ UseCases
  Future<List<Map<String, String>>> fetchAvailableVisitTypes() async {
    final List<Map<String, String>> resultTypes = [];

    final doctorResult = await _getDoctorAppointmentTypesUseCase(
      doctorId: _doctorId,
      clinicId: _clinicId,
    );
    final globalResult = await _getGlobalAppointmentTypesUseCase();

    doctorResult.fold(
      (_) {},
      (doctorTypes) {
        for (final dt in doctorTypes) {
          if (dt.name != null && dt.name!.isNotEmpty) {
            resultTypes.add({
              'id': dt.appointmentTypeId,
              'name': dt.name!,
            });
          }
        }
      },
    );

    // إذا لم تكن هناك أنواع مخصصة للطبيب، جلب أنواع الزيارات العامة
    if (resultTypes.isEmpty) {
      globalResult.fold(
        (_) {},
        (globalTypes) {
          for (final gt in globalTypes) {
            final name = gt['name'] as String? ?? '';
            final id = gt['id'] as String? ?? '';
            if (name.isNotEmpty) {
              resultTypes.add({'id': id, 'name': name});
            }
          }
        },
      );
    }

    return resultTypes;
  }

  /// تحميل النمط الحالي من قاعدة البيانات
  Future<void> loadPattern() async {
    emit(state.copyWith(isLoading: true, error: null));

    final result = await _getQueueRuleUseCase(
      doctorId: _doctorId,
      clinicId: _clinicId,
    );

    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, error: failure.message)),
      (rule) {
        if (rule == null) {
          emit(state.copyWith(
            queueSystem: 'arrival',
            slots: const [],
            cycleLength: 0,
            avgVisitMinutes: null,
            isActive: false,
            isLoading: false,
            isDirty: false,
          ));
          return;
        }

        emit(state.copyWith(
          queueSystem: rule.queueSystem,
          slots: List.from(rule.slots),
          slotLabels: List.filled(rule.slots.length, ''),
          cycleLength: rule.slots.length,
          avgVisitMinutes: rule.avgVisitMinutes,
          isActive: true, // القوانين المسجلة في السيرفر نشطة افتراضياً
          isLoading: false,
          isDirty: false,
        ));
      },
    );
  }

  /// تغيير نظام قائمة الانتظار
  void setQueueSystem(String system) {
    emit(state.copyWith(
      queueSystem: system,
      isDirty: true,
      error: null,
    ));
  }

  /// تغيير متوسط وقت الكشف بالدقائق (لنظام scheduled)
  void setAvgVisitMinutes(int? minutes) {
    emit(state.copyWith(
      avgVisitMinutes: minutes,
      isDirty: true,
      error: null,
    ));
  }

  /// إضافة نوع كشف إلى نهاية النمط
  void addSlot(String slotType, {String label = ''}) {
    final updatedSlots = [...state.slots, slotType];
    final updatedLabels = [...state.slotLabels, label.isEmpty ? slotType : label];
    emit(state.copyWith(
      slots: updatedSlots,
      slotLabels: updatedLabels,
      cycleLength: updatedSlots.length,
      isDirty: true,
      error: null,
    ));
  }

  /// حذف نوع كشف من النمط باستخدام الفهرس
  void removeSlot(int index) {
    if (index < 0 || index >= state.slots.length) return;
    final updatedSlots = [...state.slots]..removeAt(index);
    final updatedLabels = [...state.slotLabels];
    if (index < updatedLabels.length) updatedLabels.removeAt(index);
    emit(state.copyWith(
      slots: updatedSlots,
      slotLabels: updatedLabels,
      cycleLength: updatedSlots.length,
      isDirty: true,
      error: null,
    ));
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

    emit(state.copyWith(
      slots: updatedSlots,
      slotLabels: updatedLabels,
      cycleLength: updatedSlots.length,
      isDirty: true,
      error: null,
    ));
  }

  /// حفظ النمط في قاعدة البيانات
  Future<void> savePattern() async {
    if (!state.isDirty) return;
    emit(state.copyWith(isSaving: true, error: null));

    final result = await _upsertQueueRuleUseCase(
      doctorId: _doctorId,
      clinicId: _clinicId,
      queueSystem: state.queueSystem,
      slots: state.slots,
      cycleLength: state.slots.length,
      avgVisitMinutes: state.avgVisitMinutes,
    );

    result.fold(
      (failure) => emit(state.copyWith(isSaving: false, error: failure.message)),
      (_) {
        emit(state.copyWith(
          isSaving: false,
          isDirty: false,
          isActive: true,
        ));
      },
    );
  }
}

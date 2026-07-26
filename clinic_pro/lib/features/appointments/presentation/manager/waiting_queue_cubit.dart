// ────────────────────────────────────────────────────────
// Cubit طابور الانتظار — يستخدم SortQueueUseCase لترتيب المرضى
// ────────────────────────────────────────────────────────

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/strings/app_strings.dart';
import '../../../settings/domain/usecases/get_queue_rule_usecase.dart';
import '../../domain/usecases/appointments/get_appointments_usecase.dart';
import '../../domain/usecases/appointments/call_patient_usecase.dart';
import '../../domain/usecases/appointments/sort_queue_usecase.dart';
import 'waiting_queue_state.dart';

@injectable
class WaitingQueueCubit extends Cubit<WaitingQueueState> {
  final GetAppointmentsUseCase _getAppointmentsUseCase;
  final CallPatientUseCase _callPatientUseCase;
  final GetQueueRuleUseCase _getQueueRuleUseCase;
  final SortQueueUseCase _sortQueueUseCase;

  String _doctorId = '';
  String _clinicId = '';
  String _doctorName = '';

  WaitingQueueCubit(
    this._getAppointmentsUseCase,
    this._callPatientUseCase,
    this._getQueueRuleUseCase,
    this._sortQueueUseCase,
  ) : super(WaitingQueueInitial());

  Future<void> loadQueue({
    required String doctorId,
    required String clinicId,
    required String doctorName,
  }) async {
    _doctorId = doctorId;
    _clinicId = clinicId;
    _doctorName = doctorName;

    emit(WaitingQueueLoading());

    try {
      final today = DateTime.now().toIso8601String().substring(0, 10);
      
      // 1. جلب المواعيد
      final appointmentsResult = await _getAppointmentsUseCase(
        GetAppointmentsParams(
          clinicId: _clinicId,
          doctorId: _doctorId,
          date: today,
        ),
      );

      // 2. جلب قاعدة ترتيب الدور للطبيب
      final ruleResult = await _getQueueRuleUseCase(
        doctorId: _doctorId,
        clinicId: _clinicId,
      );

      appointmentsResult.fold(
        (failure) => emit(WaitingQueueError(AppStrings.isArabic ? 'تعذّر تحميل طابور الانتظار' : 'Failed to load queue')),
        (appointments) {
          ruleResult.fold(
            (failure) {
              // إذا فشل جلب القاعدة، نرتب بالترتيب الافتراضي بدون قاعدة
              final sorted = _sortQueueUseCase(appointments: appointments);
              emit(WaitingQueueLoaded(
                queue: _mapEntitiesToQueuePatients(sorted),
                doctorName: _doctorName,
              ));
            },
            (rule) {
              // ترتيب الطابور بناءً على قاعدة الطبيب
              final sorted = _sortQueueUseCase(appointments: appointments, rule: rule);
              emit(WaitingQueueLoaded(
                queue: _mapEntitiesToQueuePatients(sorted),
                doctorName: _doctorName,
              ));
            },
          );
        },
      );
    } catch (e) {
      emit(WaitingQueueError(AppStrings.isArabic ? 'تعذّر تحميل طابور الانتظار' : 'Failed to load queue'));
    }
  }

  /// استدعاء المريض التالي في الطابور
  Future<void> callNext() async {
    if (state is! WaitingQueueLoaded) return;
    final loaded = state as WaitingQueueLoaded;

    final nextIndex = loaded.queue.indexWhere((p) => p.status == 'confirmed');
    if (nextIndex == -1) return;

    try {
      final apptId = loaded.queue[nextIndex].id;
      final result = await _callPatientUseCase(apptId);
      result.fold(
        (failure) => emit(WaitingQueueError(AppStrings.isArabic ? 'تعذّر استدعاء المريض التالي' : 'Failed to call next patient')),
        (_) => loadQueue(doctorId: _doctorId, clinicId: _clinicId, doctorName: _doctorName),
      );
    } catch (_) {
      emit(WaitingQueueError(AppStrings.isArabic ? 'تعذّر استدعاء المريض التالي' : 'Failed to call next patient'));
    }
  }

  /// ... باقي العمليات
  Future<void> callPatient(String appointmentId) async {
    if (state is! WaitingQueueLoaded) return;

    try {
      final result = await _callPatientUseCase(appointmentId);
      result.fold(
        (failure) => emit(WaitingQueueError(AppStrings.isArabic ? 'تعذّر استدعاء المريض' : 'Failed to call patient')),
        (_) => loadQueue(doctorId: _doctorId, clinicId: _clinicId, doctorName: _doctorName),
      );
    } catch (_) {
      emit(WaitingQueueError(AppStrings.isArabic ? 'تعذّر استدعاء المريض' : 'Failed to call patient'));
    }
  }

  List<QueuePatient> _mapEntitiesToQueuePatients(List<dynamic> sortedEntities) {
    return sortedEntities.asMap().entries.map((entry) {
      final index = entry.key;
      final entity = entry.value;
      return QueuePatient(
        id: entity.id,
        patientName: entity.patientName ?? AppStrings.patient,
        typeName: entity.typeName ?? AppStrings.normalCheckup,
        displayTime: _formatTime(entity.time ?? '00:00:00'),
        status: entity.status,
        isUrgent: entity.isUrgent,
        queueNumber: index + 1,
      );
    }).toList();
  }

  String _formatTime(String raw) {
    final parts = raw.split(':');
    if (parts.length < 2) return raw;
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = parts[1];
    final period = hour >= 12 ? (AppStrings.isArabic ? 'م' : 'PM') : (AppStrings.isArabic ? 'ص' : 'AM');
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }
}

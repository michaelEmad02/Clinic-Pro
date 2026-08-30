// ────────────────────────────────────────────────────────
// Cubit طابور الانتظار — يستخدم SortQueueUseCase لترتيب المرضى
// ────────────────────────────────────────────────────────

import 'dart:async';
import 'package:clinic_pro/core/constants/supabase_constants.dart';
import 'package:clinic_pro/features/appointments/domain/entities/appointment_entity.dart';
import 'package:clinic_pro/features/settings/domain/entities/queue_rule_entity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/strings/app_strings.dart';
import '../../../settings/domain/usecases/get_queue_rule_usecase.dart';
import '../../domain/usecases/appointments/get_appointments_usecase.dart';
import '../../domain/usecases/appointments/call_patient_usecase.dart';
import '../../domain/usecases/appointments/sort_queue_usecase.dart';
import '../../domain/usecases/appointments/subscribe_appointments_usecase.dart';
import 'waiting_queue_state.dart';

@injectable
class WaitingQueueCubit extends Cubit<WaitingQueueState> {
  final GetAppointmentsUseCase _getAppointmentsUseCase;
  final CallPatientUseCase _callPatientUseCase;
  final GetQueueRuleUseCase _getQueueRuleUseCase;
  final SortQueueUseCase _sortQueueUseCase;
  final SubscribeAppointmentsUseCase _subscribeAppointmentsUseCase;

  StreamSubscription<List<AppointmentEntity>>? _queueSubscription;

  String _doctorId = '';
  String _clinicId = '';
  String _doctorName = '';

  /// كاش قاعدة ترتيب الدور — تُجلب مرة واحدة ثم تُستخدم في كل تحديث realtime
  QueueRuleEntity? _cachedRule;
  bool _ruleLoaded = false;

  WaitingQueueCubit(
    this._getAppointmentsUseCase,
    this._callPatientUseCase,
    this._getQueueRuleUseCase,
    this._sortQueueUseCase,
    this._subscribeAppointmentsUseCase,
  ) : super(WaitingQueueInitial());

  Future<void> loadQueue({
    required String doctorId,
    required String clinicId,
    required String doctorName,
    bool isSilent = false,
  }) async {
    _doctorId = doctorId;
    _clinicId = clinicId;
    _doctorName = doctorName;

    if (!isSilent) {
      emit(WaitingQueueLoading());
    }

    _subscribeToQueueChanges();

    try {
      final now = DateTime.now();
      final today = now.toIso8601String().substring(0, 10);

      // 1. جلب المواعيد (بدون تقييد قاسي باليوم لمراعاة شيفتات منتصف الليل)
      final appointmentsResult = await _getAppointmentsUseCase(
        GetAppointmentsParams(
          clinicId: _clinicId,
          doctorId: _doctorId,
        ),
      );

      // 2. جلب قاعدة ترتيب الدور للطبيب (وتخزينها مؤقتاً)
      await _ensureRuleLoaded();

      appointmentsResult.fold(
        (failure) => emit(WaitingQueueError(AppStrings.isArabic
            ? 'تعذّر تحميل طابور الانتظار'
            : 'Failed to load queue')),
        (allAppointments) {
          final activeCandidates = _filterActiveQueueCandidates(allAppointments, today, now);
          
          final currentPatient = activeCandidates
              .where((a) => a.status == AppointmentStatus.inProgress)
              .firstOrNull;

          final sorted = _sortQueueUseCase(appointments: activeCandidates, rule: _cachedRule);

          final waitingQueue = sorted
              .where((a) => a.status == AppointmentStatus.confirmed && a.arrivedAt != null)
              .toList();

          emit(WaitingQueueLoaded(
            queue: _mapEntitiesToQueuePatients(waitingQueue),
            rawQueue: waitingQueue,
            currentPatient: currentPatient,
            doctorName: _doctorName,
          ));
        },
      );
    } catch (e) {
      emit(WaitingQueueError(AppStrings.isArabic
          ? 'تعذّر تحميل طابور الانتظار'
          : 'Failed to load queue'));
    }
  }

  /// جلب قاعدة الترتيب مرة واحدة فقط وتخزينها
  Future<void> _ensureRuleLoaded() async {
    if (_ruleLoaded) return;
    final ruleResult = await _getQueueRuleUseCase(
      doctorId: _doctorId,
      clinicId: _clinicId,
    );
    ruleResult.fold(
      (_) => _cachedRule = null,
      (rule) => _cachedRule = rule,
    );
    _ruleLoaded = true;
  }

  /// فلترة المرشحين الفعالين في طابور الانتظار (تشمل المرضى الحاضرين في آخر 24 ساعة)
  List<AppointmentEntity> _filterActiveQueueCandidates(
    List<AppointmentEntity> allAppointments,
    String today,
    DateTime now,
  ) {
    return allAppointments.where((a) {
      if (_doctorId.isNotEmpty && a.doctorId != _doctorId) return false;
      if (a.status == AppointmentStatus.cancelled) return false;

      final isToday = a.date == today;
      final isArrivedRecently = a.arrivedAt != null &&
          now.difference(a.arrivedAt!.toLocal()).inHours.abs() < 24;

      return isToday || isArrivedRecently;
    }).toList();
  }

  /// استدعاء المريض التالي في الطابور
  Future<void> callNext() async {
    if (state is! WaitingQueueLoaded) return;
    final loaded = state as WaitingQueueLoaded;

    final nextIndex = loaded.queue.indexWhere((p) => p.status == AppointmentStatus.confirmed);
    if (nextIndex == -1) return;

    try {
      final apptId = loaded.queue[nextIndex].id;
      final result = await _callPatientUseCase(apptId);
      result.fold(
        (failure) => emit(WaitingQueueError(AppStrings.isArabic
            ? 'تعذّر استدعاء المريض التالي'
            : 'Failed to call next patient')),
        (_) => loadQueue(
            doctorId: _doctorId, clinicId: _clinicId, doctorName: _doctorName),
      );
    } catch (_) {
      emit(WaitingQueueError(AppStrings.isArabic
          ? 'تعذّر استدعاء المريض التالي'
          : 'Failed to call next patient'));
    }
  }

  Future<void> callPatient(String appointmentId) async {
    if (state is! WaitingQueueLoaded) return;

    try {
      final result = await _callPatientUseCase(appointmentId);
      result.fold(
        (failure) => emit(WaitingQueueError(AppStrings.isArabic
            ? 'تعذّر استدعاء المريض'
            : 'Failed to call patient')),
        (_) => loadQueue(
            doctorId: _doctorId, clinicId: _clinicId, doctorName: _doctorName),
      );
    } catch (_) {
      emit(WaitingQueueError(AppStrings.isArabic
          ? 'تعذّر استدعاء المريض'
          : 'Failed to call patient'));
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
        arrivedAt: entity.arrivedAt,
        patientPhone: entity.patientPhone,
        patientId: entity.patientId,
        doctorName: entity.doctorName,
      );
    }).toList();
  }

  void _subscribeToQueueChanges() {
    if (_queueSubscription != null || _clinicId.isEmpty) return;

    _queueSubscription = _subscribeAppointmentsUseCase(
      clinicId: _clinicId,
      doctorId: _doctorId,
    ).listen((allAppointments) {
      final now = DateTime.now();
      final today = now.toIso8601String().substring(0, 10);
      final activeCandidates = _filterActiveQueueCandidates(allAppointments, today, now);

      final currentPatient = activeCandidates
          .where((a) => a.status == AppointmentStatus.inProgress)
          .firstOrNull;

      final sorted = _sortQueueUseCase(appointments: activeCandidates, rule: _cachedRule);

      final waitingQueue = sorted
          .where((a) => a.status == AppointmentStatus.confirmed && a.arrivedAt != null)
          .toList();

      if (!isClosed) {
        emit(WaitingQueueLoaded(
          queue: _mapEntitiesToQueuePatients(waitingQueue),
          rawQueue: waitingQueue,
          currentPatient: currentPatient,
          doctorName: _doctorName,
        ));
      }
    });
  }

  @override
  Future<void> close() {
    _queueSubscription?.cancel();
    return super.close();
  }

  String _formatTime(String raw) {
    final parts = raw.split(':');
    if (parts.length < 2) return raw;
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = parts[1];
    final period = hour >= 12
        ? (AppStrings.isArabic ? 'م' : 'PM')
        : (AppStrings.isArabic ? 'ص' : 'AM');
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }
}

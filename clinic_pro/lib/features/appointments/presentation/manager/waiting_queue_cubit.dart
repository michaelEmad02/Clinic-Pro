// ────────────────────────────────────────────────────────
// Cubit طابور الانتظار — يستخدم QueueSorter لترتيب المرضى
// ────────────────────────────────────────────────────────

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'waiting_queue_state.dart';
import 'appointments_repository.dart';

@injectable
class WaitingQueueCubit extends Cubit<WaitingQueueState> {
  final AppointmentsRepository _repository;

  WaitingQueueCubit(this._repository) : super(WaitingQueueInitial());

  // معرف الطبيب الحالي (Mock — د. ياسر)
  static const _doctorId = 'u-doc-1';
  Future<void> loadQueue() async {
    emit(WaitingQueueLoading());

    try {
      final today = DateTime.now().toIso8601String().substring(0, 10);
      final sorted = await _repository.loadQueue(_doctorId, today);
      
      final queuePatients = sorted.asMap().entries.map((entry) {
        final index = entry.key;
        final raw = entry.value;
        final patient = raw['patients'] as Map<String, dynamic>? ?? {};
        final type = raw['appointment_types'] as Map<String, dynamic>? ?? {};
        final timeRaw = raw['time'] as String? ?? '00:00:00';

        return QueuePatient(
          id: raw['id'] as String,
          patientName: patient['name'] as String? ?? 'مريض',
          typeName: type['name'] as String? ?? 'كشف',
          displayTime: _formatTime(timeRaw),
          status: raw['status'] as String,
          isUrgent: raw['is_urgent'] as bool? ?? false,
          queueNumber: index + 1,
        );
      }).toList();

      emit(WaitingQueueLoaded(
        queue: queuePatients,
        doctorName: 'د. ياسر مصطفى',
      ));
    } catch (e) {
      emit(const WaitingQueueError('تعذّر تحميل طابور الانتظار'));
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
      await _repository.callPatient(apptId);
      await loadQueue();
    } catch (_) {
      emit(const WaitingQueueError('تعذّر استدعاء المريض التالي'));
    }
  }

  /// استدعاء مريض محدد
  Future<void> callPatient(String appointmentId) async {
    if (state is! WaitingQueueLoaded) return;

    try {
      await _repository.callPatient(appointmentId);
      await loadQueue();
    } catch (_) {
      emit(const WaitingQueueError('تعذّر استدعاء المريض'));
    }
  }

  String _formatTime(String raw) {
    final parts = raw.split(':');
    if (parts.length < 2) return raw;
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = parts[1];
    final period = hour >= 12 ? 'م' : 'ص';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }
}

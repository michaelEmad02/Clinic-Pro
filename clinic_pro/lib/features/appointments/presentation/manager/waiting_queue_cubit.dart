// ────────────────────────────────────────────────────────
// Cubit طابور الانتظار — يستخدم QueueSorter لترتيب المرضى
// ────────────────────────────────────────────────────────

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/mocks/mock_data.dart';
import '../../../../core/utils/queue_sorter.dart';
import 'waiting_queue_state.dart';

class WaitingQueueCubit extends Cubit<WaitingQueueState> {
  WaitingQueueCubit() : super(WaitingQueueInitial());

  // معرف الطبيب الحالي (Mock — د. ياسر)
  static const _doctorId = 'u-doc-1';

  Future<void> loadQueue() async {
    emit(WaitingQueueLoading());
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final sorted = _buildSortedQueue();
      final doctor = MockData.users.firstWhere((u) => u['id'] == _doctorId);
      emit(WaitingQueueLoaded(
        queue: sorted,
        doctorName: doctor['name'] as String,
      ));
    } catch (e) {
      emit(const WaitingQueueError('تعذّر تحميل طابور الانتظار'));
    }
  }

  /// استدعاء المريض التالي في الطابور
  void callNext() {
    if (state is! WaitingQueueLoaded) return;
    final loaded = state as WaitingQueueLoaded;

    // أول مريض في الانتظار (confirmed) وليس in_progress أو done
    final nextIndex = loaded.queue.indexWhere((p) => p.status == 'confirmed');
    if (nextIndex == -1) return;

    final updated = loaded.queue.map((p) {
      if (p.id == loaded.queue[nextIndex].id) {
        return p.copyWith(status: 'in_progress');
      }
      return p;
    }).toList();

    emit(loaded.copyWith(queue: updated));
  }

  /// استدعاء مريض محدد
  void callPatient(String appointmentId) {
    if (state is! WaitingQueueLoaded) return;
    final loaded = state as WaitingQueueLoaded;

    final updated = loaded.queue.map((p) {
      if (p.id == appointmentId && p.status == 'confirmed') {
        return p.copyWith(status: 'in_progress');
      }
      return p;
    }).toList();

    emit(loaded.copyWith(queue: updated));
  }

  List<QueuePatient> _buildSortedQueue() {
    final today = DateTime.now().toIso8601String().substring(0, 10);

    // فلترة مواعيد اليوم التي وصلت (arrived_at != null)
    final todayAppointments = MockData.appointments.where((a) {
      return a['doctor_id'] == _doctorId &&
          a['date'] == today &&
          a['arrived_at'] != null &&
          a['status'] != 'cancelled';
    }).toList();

    // جلب نمط الترتيب من doctor_queue_rules
    final rule = MockData.doctorQueueRules.firstWhere(
      (r) => r['doctor_id'] == _doctorId,
      orElse: () => {'slots': <String>[]},
    );
    final slots = (rule['slots'] as List?)?.cast<String>();

    final sorted = QueueSorter.sort(
      appointments: todayAppointments,
      ruleSlots: slots,
    );

    return sorted.asMap().entries.map((entry) {
      final index = entry.key;
      final raw = entry.value;
      final patient = raw['patients'] as Map<String, dynamic>? ?? {};
      final type = raw['appointment_types'] as Map<String, dynamic>? ?? {};
      final timeRaw = raw['time'] as String;

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

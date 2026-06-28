// ────────────────────────────────────────────────────────
// Bloc شاشة المواعيد — يدير تحميل وفلترة وإجراءات المواعيد (Mock)
// ────────────────────────────────────────────────────────

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/mocks/mock_data.dart';
import 'appointments_event.dart';
import 'appointments_state.dart';

class AppointmentsBloc extends Bloc<AppointmentsEvent, AppointmentsState> {
  AppointmentsBloc() : super(AppointmentsInitial()) {
    on<LoadAppointmentsEvent>(_onLoad);
    on<ChangeAppointmentsTabEvent>(_onChangeTab);
    on<ChangeStatusFilterEvent>(_onChangeFilter);
    on<ConfirmArrivalEvent>(_onConfirmArrival);
    on<CancelAppointmentEvent>(_onCancel);
    on<ToggleUrgentEvent>(_onToggleUrgent);
    on<AddAppointmentEvent>(_onAdd);
  }

  Future<void> _onLoad(
    LoadAppointmentsEvent event,
    Emitter<AppointmentsState> emit,
  ) async {
    emit(AppointmentsLoading());
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final items = _mapMockData();
      emit(AppointmentsLoaded(allAppointments: items));
    } catch (e) {
      emit(const AppointmentsError('تعذّر تحميل المواعيد. حاول مرة أخرى.'));
    }
  }

  void _onChangeTab(
    ChangeAppointmentsTabEvent event,
    Emitter<AppointmentsState> emit,
  ) {
    if (state is AppointmentsLoaded) {
      final loaded = state as AppointmentsLoaded;
      emit(loaded.copyWith(activeTab: event.tab, statusFilter: 'all'));
    }
  }

  void _onChangeFilter(
    ChangeStatusFilterEvent event,
    Emitter<AppointmentsState> emit,
  ) {
    if (state is AppointmentsLoaded) {
      final loaded = state as AppointmentsLoaded;
      emit(loaded.copyWith(statusFilter: event.filter));
    }
  }

  Future<void> _onConfirmArrival(
    ConfirmArrivalEvent event,
    Emitter<AppointmentsState> emit,
  ) async {
    if (state is! AppointmentsLoaded) return;
    final loaded = state as AppointmentsLoaded;
    await Future.delayed(const Duration(milliseconds: 300));

    final updated = loaded.allAppointments.map((a) {
      if (a.id == event.appointmentId && a.status == 'scheduled') {
        return a.copyWith(
          status: 'confirmed',
          arrivedAt: DateTime.now(),
        );
      }
      return a;
    }).toList();

    emit(loaded.copyWith(allAppointments: updated));
  }

  Future<void> _onCancel(
    CancelAppointmentEvent event,
    Emitter<AppointmentsState> emit,
  ) async {
    if (state is! AppointmentsLoaded) return;
    final loaded = state as AppointmentsLoaded;
    await Future.delayed(const Duration(milliseconds: 300));

    final updated = loaded.allAppointments.map((a) {
      if (a.id == event.appointmentId && a.status != 'done') {
        return a.copyWith(status: 'cancelled');
      }
      return a;
    }).toList();

    emit(loaded.copyWith(allAppointments: updated));
  }

  Future<void> _onToggleUrgent(
    ToggleUrgentEvent event,
    Emitter<AppointmentsState> emit,
  ) async {
    if (state is! AppointmentsLoaded) return;
    final loaded = state as AppointmentsLoaded;

    final updated = loaded.allAppointments.map((a) {
      if (a.id == event.appointmentId) {
        return a.copyWith(isUrgent: !a.isUrgent);
      }
      return a;
    }).toList();

    emit(loaded.copyWith(allAppointments: updated));
  }

  Future<void> _onAdd(
    AddAppointmentEvent event,
    Emitter<AppointmentsState> emit,
  ) async {
    if (state is! AppointmentsLoaded) return;
    final loaded = state as AppointmentsLoaded;
    await Future.delayed(const Duration(milliseconds: 400));

    final patient = MockData.patients.firstWhere((p) => p['id'] == event.patientId);
    final doctor = MockData.users.firstWhere((u) => u['id'] == event.doctorId);
    final type = MockData.appointmentTypes.firstWhere((t) => t['id'] == event.typeId);

    final newItem = AppointmentItem(
      id: 'appt-new-${DateTime.now().millisecondsSinceEpoch}',
      patientId: event.patientId,
      patientName: patient['name'] as String,
      patientPhone: patient['phone'] as String,
      doctorId: event.doctorId,
      doctorName: doctor['name'] as String,
      typeId: event.typeId,
      typeName: type['name'] as String,
      date: event.date,
      displayTime: _formatTime(event.time),
      status: 'scheduled',
      price: (type['price'] as num).toDouble(),
      isUrgent: event.isUrgent,
      notes: event.notes,
    );

    emit(loaded.copyWith(
      allAppointments: [...loaded.allAppointments, newItem],
    ));
  }

  /// تحويل بيانات MockData إلى AppointmentItem
  List<AppointmentItem> _mapMockData() {
    return MockData.appointments.map((raw) {
      final patient = raw['patients'] as Map<String, dynamic>? ?? {};
      final type = raw['appointment_types'] as Map<String, dynamic>? ?? {};
      final doctorId = raw['doctor_id'] as String;
      final doctor = MockData.users.firstWhere(
        (u) => u['id'] == doctorId,
        orElse: () => {'name': 'طبيب'},
      );

      final apptId = raw['id'] as String;
      final prescription = MockData.prescriptions
          .where((p) => p['appointment_id'] == apptId)
          .toList();
      final invoice = MockData.invoices
          .where((i) => i['appointment_id'] == apptId)
          .toList();

      return AppointmentItem(
        id: apptId,
        patientId: raw['patient_id'] as String,
        patientName: patient['name'] as String? ?? 'مريض',
        patientPhone: patient['phone'] as String? ?? '',
        doctorId: doctorId,
        doctorName: doctor['name'] as String,
        typeId: raw['appointment_type_id'] as String,
        typeName: type['name'] as String? ?? 'كشف',
        date: raw['date'] as String,
        displayTime: _formatTime(raw['time'] as String),
        status: raw['status'] as String,
        price: (raw['price'] as num).toDouble(),
        isUrgent: raw['is_urgent'] as bool? ?? false,
        notes: raw['notes'] as String?,
        arrivedAt: raw['arrived_at'] != null
            ? DateTime.parse(raw['arrived_at'] as String)
            : null,
        calledAt: raw['called_at'] != null
            ? DateTime.parse(raw['called_at'] as String)
            : null,
        hasPrescription: prescription.isNotEmpty,
        hasInvoice: invoice.isNotEmpty,
        prescriptionDiagnosis: prescription.isNotEmpty
            ? prescription.first['diagnosis'] as String?
            : null,
        invoiceAmount: invoice.isNotEmpty
            ? '${invoice.first['amount']}'
            : null,
        invoiceStatus: invoice.isNotEmpty
            ? invoice.first['status'] as String?
            : null,
        invoiceNumber: invoice.isNotEmpty
            ? '#INV-${apptId.length > 4 ? apptId.substring(apptId.length - 4) : apptId}'
            : null,
      );
    }).toList();
  }

  /// تنسيق الوقت للعرض (مثال: 16:30 → 4:30 م)
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

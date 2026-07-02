// ────────────────────────────────────────────────────────
// Bloc شاشة المواعيد — يدير تحميل وفلترة وإجراءات المواعيد
// ────────────────────────────────────────────────────────

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'appointments_event.dart';
import 'appointments_state.dart';
import 'appointments_repository.dart';

@injectable
class AppointmentsBloc extends Bloc<AppointmentsEvent, AppointmentsState> {
  final AppointmentsRepository _repository;

  AppointmentsBloc(this._repository) : super(AppointmentsInitial()) {
    on<LoadAppointmentsEvent>(_onLoad);
    on<ChangeAppointmentsTabEvent>(_onChangeTab);
    on<ChangeStatusFilterEvent>(_onChangeFilter);
    on<ConfirmArrivalEvent>(_onConfirmArrival);
    on<CancelAppointmentEvent>(_onCancel);
    on<ToggleUrgentEvent>(_onToggleUrgent);
    on<AddAppointmentEvent>(_onAdd);
    on<UpdateAppointmentEvent>(_onUpdate);
    on<DeleteAppointmentEvent>(_onDelete);
  }

  Future<void> _onLoad(
    LoadAppointmentsEvent event,
    Emitter<AppointmentsState> emit,
  ) async {
    emit(AppointmentsLoading());

    try {
      final items = await _repository.loadAppointments();
      emit(AppointmentsLoaded(allAppointments: _mapAppointments(items)));
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

    try {
      await _repository.confirmArrival(event.appointmentId);
      final items = await _repository.loadAppointments();
      emit(loaded.copyWith(allAppointments: _mapAppointments(items)));
    } catch (_) {
      emit(const AppointmentsError('تعذّر تأكيد الوصول'));
    }
  }

  Future<void> _onCancel(
    CancelAppointmentEvent event,
    Emitter<AppointmentsState> emit,
  ) async {
    if (state is! AppointmentsLoaded) return;
    final loaded = state as AppointmentsLoaded;

    try {
      await _repository.cancelAppointment(event.appointmentId);
      final items = await _repository.loadAppointments();
      emit(loaded.copyWith(allAppointments: _mapAppointments(items)));
    } catch (_) {
      emit(const AppointmentsError('تعذّر إلغاء الموعد'));
    }
  }

  Future<void> _onToggleUrgent(
    ToggleUrgentEvent event,
    Emitter<AppointmentsState> emit,
  ) async {
    if (state is! AppointmentsLoaded) return;
    final loaded = state as AppointmentsLoaded;

    try {
      final appt = loaded.allAppointments.firstWhere((a) => a.id == event.appointmentId);
      await _repository.toggleUrgent(event.appointmentId, !appt.isUrgent);
      final items = await _repository.loadAppointments();
      emit(loaded.copyWith(allAppointments: _mapAppointments(items)));
    } catch (_) {
      emit(const AppointmentsError('تعذّر تعديل حالة الاستعجال'));
    }
  }

  Future<void> _onAdd(
    AddAppointmentEvent event,
    Emitter<AppointmentsState> emit,
  ) async {
    if (state is! AppointmentsLoaded) return;
    final loaded = state as AppointmentsLoaded;

    try {
      await _repository.addAppointment(
        patientId: event.patientId,
        doctorId: event.doctorId,
        typeId: event.typeId,
        date: event.date,
        time: event.time,
        isUrgent: event.isUrgent,
        notes: event.notes,
      );
      final items = await _repository.loadAppointments();
      emit(loaded.copyWith(allAppointments: _mapAppointments(items)));
    } catch (_) {
      emit(const AppointmentsError('تعذّر إضافة الموعد'));
    }
  }

  /// معالجة حدث تعديل موعد قائم
  Future<void> _onUpdate(
    UpdateAppointmentEvent event,
    Emitter<AppointmentsState> emit,
  ) async {
    if (state is! AppointmentsLoaded) return;
    final loaded = state as AppointmentsLoaded;

    try {
      await _repository.updateAppointment(
        appointmentId: event.appointmentId,
        doctorId: event.doctorId,
        typeId: event.typeId,
        date: event.date,
        time: event.time,
        isUrgent: event.isUrgent,
        notes: event.notes,
      );
      final items = await _repository.loadAppointments();
      emit(loaded.copyWith(allAppointments: _mapAppointments(items)));
    } catch (_) {
      emit(const AppointmentsError('تعذّر تعديل الموعد'));
    }
  }

  Future<void> _onDelete(
    DeleteAppointmentEvent event,
    Emitter<AppointmentsState> emit,
  ) async {
    if (state is! AppointmentsLoaded) return;
    final loaded = state as AppointmentsLoaded;

    try {
      await _repository.deleteAppointment(event.appointmentId);
      final items = await _repository.loadAppointments();
      emit(loaded.copyWith(allAppointments: _mapAppointments(items)));
    } catch (_) {
      emit(const AppointmentsError('تعذّر حذف الموعد'));
    }
  }

  /// تحويل بيانات الـ Map المجلوبة من المستودع إلى AppointmentItem
  List<AppointmentItem> _mapAppointments(List<Map<String, dynamic>> rawList) {
    return rawList.map((raw) {
      final patient = raw['patients'] as Map<String, dynamic>? ?? {};
      final type = raw['appointment_types'] as Map<String, dynamic>? ?? {};
      final doctorId = raw['doctor_id'] as String;

      final prescriptions = raw['prescriptions'] as List<dynamic>? ?? [];
      final invoices = raw['invoices'] as List<dynamic>? ?? [];

      final apptId = raw['id'] as String;

      return AppointmentItem(
        id: apptId,
        patientId: raw['patient_id'] as String,
        patientName: patient['name'] as String? ?? 'مريض',
        patientPhone: patient['phone'] as String? ?? '',
        doctorId: doctorId,
        doctorName: 'طبيب معالج',
        typeId: raw['appointment_type_id'] as String,
        typeName: type['name'] as String? ?? 'كشف',
        date: raw['date'] as String,
        displayTime: _formatTime(raw['time'] as String? ?? '00:00:00'),
        rawTime: raw['time'] as String? ?? '00:00:00',
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
        hasPrescription: prescriptions.isNotEmpty,
        hasInvoice: invoices.isNotEmpty,
        prescriptionDiagnosis: prescriptions.isNotEmpty
            ? prescriptions.first['diagnosis'] as String?
            : null,
        invoiceAmount: invoices.isNotEmpty
            ? '${invoices.first['amount']}'
            : null,
        invoiceStatus: invoices.isNotEmpty
            ? invoices.first['status'] as String?
            : null,
        invoiceNumber: invoices.isNotEmpty
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

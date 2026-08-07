import 'dart:async';
import 'package:clinic_pro/core/constants/app_constants.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/strings/app_strings.dart';
import '../../../../core/constants/supabase_constants.dart';
import '../../domain/entities/appointment_entity.dart';
import '../../domain/usecases/appointments/get_appointments_usecase.dart';
import '../../domain/usecases/appointments/confirm_arrival_usecase.dart';
import '../../domain/usecases/appointments/cancel_appointment_usecase.dart';
import '../../domain/usecases/appointments/toggle_urgent_usecase.dart';
import '../../domain/usecases/appointments/add_appointment_usecase.dart';
import '../../domain/usecases/appointments/update_appointment_usecase.dart';
import '../../domain/usecases/appointments/delete_appointment_usecase.dart';
import '../../domain/usecases/appointments/get_appointment_by_id_usecase.dart';
import '../../domain/usecases/appointments/subscribe_appointments_usecase.dart';
import 'appointments_event.dart';
import 'appointments_state.dart';

@injectable
class AppointmentsBloc extends Bloc<AppointmentsEvent, AppointmentsState> {
  final GetAppointmentsUseCase _getAppointmentsUseCase;
  final ConfirmArrivalUseCase _confirmArrivalUseCase;
  final CancelAppointmentUseCase _cancelAppointmentUseCase;
  final ToggleUrgentUseCase _toggleUrgentUseCase;
  final AddAppointmentUseCase _addAppointmentUseCase;
  final UpdateAppointmentUseCase _updateAppointmentUseCase;
  final DeleteAppointmentUseCase _deleteAppointmentUseCase;
  final GetAppointmentByIdUseCase _getAppointmentByIdUseCase;
  final SubscribeAppointmentsUseCase _subscribeAppointmentsUseCase;

  StreamSubscription<List<AppointmentEntity>>? _appointmentsSubscription;

  String? _subscribedDoctorId;

  // معرف العيادة النشطة حالياً (ديناميكي)
  String get _clinicId => AppConstants.activeClinicId;

  AppointmentsBloc(
    this._getAppointmentsUseCase,
    this._confirmArrivalUseCase,
    this._cancelAppointmentUseCase,
    this._toggleUrgentUseCase,
    this._addAppointmentUseCase,
    this._updateAppointmentUseCase,
    this._deleteAppointmentUseCase,
    this._getAppointmentByIdUseCase,
    this._subscribeAppointmentsUseCase,
  ) : super(AppointmentsInitial()) {
    on<LoadAppointmentsEvent>(_onLoad);
    on<SubscribeAppointmentsEvent>(_onSubscribe);
    on<RefreshAppointmentsEvent>(_onRefresh);
    on<ChangeAppointmentsTabEvent>(_onChangeTab);
    on<ChangeStatusFilterEvent>(_onChangeFilter);
    on<ConfirmArrivalEvent>(_onConfirmArrival);
    on<CancelAppointmentEvent>(_onCancel);
    on<ToggleUrgentEvent>(_onToggleUrgent);
    on<AddAppointmentEvent>(_onAdd);
    on<UpdateAppointmentEvent>(_onUpdate);
    on<DeleteAppointmentEvent>(_onDelete);
    on<GetAppointmentDetailsEvent>(_onGetDetails);
    on<CompleteAppointmentEvent>(_onComplete);
  }

  Future<void> _onSubscribe(
    SubscribeAppointmentsEvent event,
    Emitter<AppointmentsState> emit,
  ) async {
    final activeClinicId = (event.clinicId != null && event.clinicId!.isNotEmpty)
        ? event.clinicId!
        : _clinicId;

    _subscribedDoctorId = event.doctorId;

    // 1. التكيف مع التحميل الأولي
    add(LoadAppointmentsEvent(doctorId: event.doctorId, clinicId: activeClinicId));

    // 2. إلغاء أي اشتراك فرعي سابق
    await _appointmentsSubscription?.cancel();

    // 3. إنشاء اشتراك realtime stream جديد يُرجع AppointmentEntity جاهزة مباشرة!
    _appointmentsSubscription = _subscribeAppointmentsUseCase(
      clinicId: activeClinicId,
      doctorId: _subscribedDoctorId,
    ).listen((items) {
      if (!isClosed) {
        add(RefreshAppointmentsEvent(items));
      }
    });
  }

  void _onRefresh(
    RefreshAppointmentsEvent event,
    Emitter<AppointmentsState> emit,
  ) {
    if (state is AppointmentsLoaded) {
      final loaded = state as AppointmentsLoaded;
      emit(loaded.copyWith(allAppointments: event.appointments));
    } else {
      emit(AppointmentsLoaded(allAppointments: event.appointments));
    }
  }

  Future<void> _onLoad(
    LoadAppointmentsEvent event,
    Emitter<AppointmentsState> emit,
  ) async {
    emit(AppointmentsLoading());

    final activeClinicId = (event.clinicId != null && event.clinicId!.isNotEmpty)
        ? event.clinicId!
        : _clinicId;

    final result = await _getAppointmentsUseCase(
      GetAppointmentsParams(clinicId: activeClinicId, doctorId: event.doctorId),
    );

    result.fold(
      (failure) => emit(AppointmentsError(AppStrings.loadAppointmentsFailed)),
      (items) =>
          emit(AppointmentsLoaded(allAppointments: items)),
    );
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

    final result = await _confirmArrivalUseCase(event.appointmentId);

    await result.fold(
      (failure) async => emit(AppointmentsError(AppStrings.isArabic
          ? 'تعذّر تأكيد الوصول'
          : 'Failed to confirm arrival')),
      (_) async {
        final loadResult = await _getAppointmentsUseCase(
            GetAppointmentsParams(clinicId: _clinicId,));
        loadResult.fold(
          (failure) =>
              emit(AppointmentsError(AppStrings.loadAppointmentsFailed)),
          (items) => emit(
              loaded.copyWith(allAppointments: items)),
        );
      },
    );
  }

  Future<void> _onCancel(
    CancelAppointmentEvent event,
    Emitter<AppointmentsState> emit,
  ) async {
    if (state is! AppointmentsLoaded) return;
    final loaded = state as AppointmentsLoaded;

    final result = await _cancelAppointmentUseCase(event.appointmentId);

    await result.fold(
      (failure) async => emit(AppointmentsError(AppStrings.isArabic
          ? 'تعذّر إلغاء الموعد'
          : 'Failed to cancel appointment')),
      (_) async {
        final loadResult = await _getAppointmentsUseCase(
            GetAppointmentsParams(clinicId: _clinicId));
        loadResult.fold(
          (failure) =>
              emit(AppointmentsError(AppStrings.loadAppointmentsFailed)),
          (items) => emit(
              loaded.copyWith(allAppointments: items)),
        );
      },
    );
  }

  Future<void> _onToggleUrgent(
    ToggleUrgentEvent event,
    Emitter<AppointmentsState> emit,
  ) async {
    if (state is! AppointmentsLoaded) return;
    final loaded = state as AppointmentsLoaded;

    try {
      final appt =
          loaded.allAppointments.firstWhere((a) => a.id == event.appointmentId);
      final result = await _toggleUrgentUseCase(
        appointmentId: event.appointmentId,
        isUrgent: !appt.isUrgent,
      );

      await result.fold(
        (failure) async => emit(AppointmentsError(AppStrings.isArabic
            ? 'تعذّر تعديل حالة الاستعجال'
            : 'Failed to update urgency')),
        (_) async {
          final loadResult = await _getAppointmentsUseCase(
              GetAppointmentsParams(clinicId: _clinicId));
          loadResult.fold(
            (failure) =>
                emit(AppointmentsError(AppStrings.loadAppointmentsFailed)),
            (items) => emit(
                loaded.copyWith(allAppointments: items)),
          );
        },
      );
    } catch (_) {
      emit(AppointmentsError(
          AppStrings.isArabic ? 'الموعد غير موجود' : 'Appointment not found'));
    }
  }

  Future<void> _onAdd(
    AddAppointmentEvent event,
    Emitter<AppointmentsState> emit,
  ) async {
    final activeClinicId = event.doctorId.isNotEmpty
        ? _clinicId
        : AppConstants.activeClinicId;

    final tempEntity = AppointmentEntity(
      id: '',
      clinicId: activeClinicId,
      doctorId: event.doctorId,
      patientId: event.patientId,
      typeId: event.typeId,
      date: event.date,
      time: event.time,
      status: 'scheduled',
      price: 0.0, // سيتم تحديد السعر وتعيينه في المستودع
      isUrgent: event.isUrgent,
      notes: event.notes,
      createdBy: event.currentUser,
      createdAt: DateTime.now(),
    );

    final result = await _addAppointmentUseCase(tempEntity);

    await result.fold(
      (failure) async => emit(AppointmentsError(failure.message)),
      (_) async {
        final loadResult = await _getAppointmentsUseCase(
            GetAppointmentsParams(clinicId: activeClinicId));
        loadResult.fold(
          (failure) =>
              emit(AppointmentsError(AppStrings.loadAppointmentsFailed)),
          (items) {
            if (state is AppointmentsLoaded) {
              final loaded = state as AppointmentsLoaded;
              emit(loaded.copyWith(allAppointments: items));
            } else {
              emit(AppointmentsLoaded(allAppointments: items));
            }
          },
        );
      },
    );
  }

  Future<void> _onUpdate(
    UpdateAppointmentEvent event,
    Emitter<AppointmentsState> emit,
  ) async {
    final currentAppointments = state is AppointmentsLoaded
        ? (state as AppointmentsLoaded).allAppointments
        : <AppointmentEntity>[];

    final existingList =
        currentAppointments.where((a) => a.id == event.appointmentId).toList();
    final existing = existingList.isNotEmpty ? existingList.first : null;

    final tempEntity = AppointmentEntity(
      id: event.appointmentId,
      clinicId: existing?.clinicId ?? _clinicId,
      doctorId: event.doctorId,
      patientId: existing?.patientId ?? '',
      typeId: event.typeId,
      date: event.date,
      time: event.time,
      status: existing?.status ?? 'scheduled',
      price: existing?.price ?? 0.0,
      isUrgent: event.isUrgent,
      notes: event.notes,
      createdBy: existing?.createdBy ?? '',
      createdAt: existing?.createdAt ?? DateTime.now(),
      arrivedAt: existing?.arrivedAt,
      calledAt: existing?.calledAt,
    );

    final result = await _updateAppointmentUseCase(tempEntity);

    await result.fold(
      (failure) async => emit(AppointmentsError(failure.message)),
      (_) async {
        final activeClinicId = tempEntity.clinicId.isNotEmpty ? tempEntity.clinicId : _clinicId;
        final loadResult = await _getAppointmentsUseCase(
            GetAppointmentsParams(clinicId: activeClinicId));
        loadResult.fold(
          (failure) =>
              emit(AppointmentsError(AppStrings.loadAppointmentsFailed)),
          (items) {
            if (state is AppointmentsLoaded) {
              final loaded = state as AppointmentsLoaded;
              emit(loaded.copyWith(allAppointments: items));
            } else {
              emit(AppointmentsLoaded(allAppointments: items));
            }
          },
        );
      },
    );
  }

  Future<void> _onDelete(
    DeleteAppointmentEvent event,
    Emitter<AppointmentsState> emit,
  ) async {
    if (state is! AppointmentsLoaded) return;
    final loaded = state as AppointmentsLoaded;

    final result = await _deleteAppointmentUseCase(event.appointmentId);

    await result.fold(
      (failure) async => emit(AppointmentsError(AppStrings.isArabic
          ? 'تعذّر حذف الموعد'
          : 'Failed to delete appointment')),
      (_) async {
        final loadResult = await _getAppointmentsUseCase(
            GetAppointmentsParams(clinicId: _clinicId));
        loadResult.fold(
          (failure) =>
              emit(AppointmentsError(AppStrings.loadAppointmentsFailed)),
          (items) => emit(
              loaded.copyWith(allAppointments: items)),
        );
      },
    );
  }

  Future<void> _onGetDetails(
    GetAppointmentDetailsEvent event,
    Emitter<AppointmentsState> emit,
  ) async {
    emit(AppointmentsLoading());
    final result = await _getAppointmentByIdUseCase(event.appointmentId);
    result.fold(
      (failure) => emit(AppointmentsError(failure.message)),
      (appointment) => emit(AppointmentsLoaded(allAppointments: [appointment])),
    );
  }

  /// إنهاء الزيارة بعد حفظ الروشتة — تغيير الحالة إلى done وتعيين called_at إذا كانت فارغة
  Future<void> _onComplete(
    CompleteAppointmentEvent event,
    Emitter<AppointmentsState> emit,
  ) async {
    // جلب بيانات الموعد الحالية من قاعدة البيانات
    final detailsResult = await _getAppointmentByIdUseCase(event.appointmentId);

    await detailsResult.fold(
      (failure) async {
        // لا نوقف عملية الحفظ إذا فشل جلب بيانات الموعد
      },
      (appointment) async {
        final updatedEntity = appointment.copyWith(
          status: AppointmentStatus.done,
          calledAt: appointment.calledAt ?? event.calledAt ?? DateTime.now(),
        );

        final result = await _updateAppointmentUseCase(updatedEntity);

        result.fold(
          (failure) {
            // لا نوقف العملية إذا فشل التحديث
          },
          (_) {
            if (state is AppointmentsLoaded) {
              final loaded = state as AppointmentsLoaded;
              final updatedList = loaded.allAppointments.map((a) {
                return a.id == event.appointmentId ? updatedEntity : a;
              }).toList();
              emit(loaded.copyWith(allAppointments: updatedList));
            }
          },
        );
      },
    );
  }

  @override
  Future<void> close() {
    _appointmentsSubscription?.cancel();
    return super.close();
  }
}

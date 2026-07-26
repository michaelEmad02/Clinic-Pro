import 'package:equatable/equatable.dart';
import '../../domain/entities/appointment_entity.dart';

/// تبويبات شاشة المواعيد: اليوم / القادمة / السجل
enum AppointmentsTab { today, upcoming, history }

abstract class AppointmentsState extends Equatable {
  const AppointmentsState();

  @override
  List<Object?> get props => [];
}

class AppointmentsInitial extends AppointmentsState {}

class AppointmentsLoading extends AppointmentsState {}

class AppointmentsLoaded extends AppointmentsState {
  final List<AppointmentEntity> allAppointments;
  final AppointmentsTab activeTab;
  final String statusFilter;

  const AppointmentsLoaded({
    required this.allAppointments,
    this.activeTab = AppointmentsTab.today,
    this.statusFilter = 'all',
  });

  /// فلترة المواعيد حسب التبويب النشط
  List<AppointmentEntity> get filteredAppointments {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    List<AppointmentEntity> base;

    switch (activeTab) {
      case AppointmentsTab.today:
        base = allAppointments.where((a) => a.date == today).toList();
      case AppointmentsTab.upcoming:
        base = allAppointments
            .where((a) => a.date.compareTo(today) > 0 && a.status != 'cancelled')
            .toList();
      case AppointmentsTab.history:
        base = allAppointments
            .where((a) => a.date.compareTo(today) < 0 || a.status == 'done' || a.status == 'cancelled')
            .where((a) => a.date != today || a.status == 'done' || a.status == 'cancelled')
            .toList();
    }

    if (statusFilter == 'all') return base;
    return base.where((a) => a.status == statusFilter).toList();
  }

  AppointmentsLoaded copyWith({
    List<AppointmentEntity>? allAppointments,
    AppointmentsTab? activeTab,
    String? statusFilter,
  }) {
    return AppointmentsLoaded(
      allAppointments: allAppointments ?? this.allAppointments,
      activeTab: activeTab ?? this.activeTab,
      statusFilter: statusFilter ?? this.statusFilter,
    );
  }

  @override
  List<Object?> get props => [allAppointments, activeTab, statusFilter];
}

class AppointmentsError extends AppointmentsState {
  final String message;

  const AppointmentsError(this.message);

  @override
  List<Object?> get props => [message];
}

class AppointmentsActionSuccess extends AppointmentsState {
  final String message;
  final AppointmentsLoaded previousState;

  const AppointmentsActionSuccess({
    required this.message,
    required this.previousState,
  });

  @override
  List<Object?> get props => [message, previousState];
}

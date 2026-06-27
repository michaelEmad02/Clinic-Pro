import 'package:flutter_bloc/flutter_bloc.dart';
import 'secretary_dashboard_state.dart';

class SecretaryDashboardCubit extends Cubit<SecretaryDashboardState> {
  SecretaryDashboardCubit() : super(SecretaryDashboardInitial());

  void loadDashboardData() async {
    emit(SecretaryDashboardLoading());
    await Future.delayed(const Duration(milliseconds: 600));

    emit(const SecretaryDashboardLoaded(
      secretaryName: 'أ. مريم العتيبي',
      liveQueue: [
        AppointmentMock(
          id: 'a1',
          patientName: 'يوسف سليم الأحمد',
          doctorName: 'د. أحمد العلي',
          time: '١٠:٣٠ ص',
          type: 'normal',
          status: 'in_progress',
        ),
        AppointmentMock(
          id: 'a2',
          patientName: 'فاطمة عمر القحطاني',
          doctorName: 'د. أحمد العلي',
          time: '١٠:٤٥ ص',
          type: 'urgent',
          status: 'confirmed',
        ),
        AppointmentMock(
          id: 'a3',
          patientName: 'خالد عبد الله الحربي',
          doctorName: 'د. أحمد العلي',
          time: '١١:٠٠ ص',
          type: 'normal',
          status: 'confirmed',
        ),
      ],
      todayAppointments: [
        AppointmentMock(
          id: 'a1',
          patientName: 'يوسف سليم الأحمد',
          doctorName: 'د. أحمد العلي',
          time: '١٠:٣٠ ص',
          type: 'normal',
          status: 'in_progress',
        ),
        AppointmentMock(
          id: 'a2',
          patientName: 'فاطمة عمر القحطاني',
          doctorName: 'د. أحمد العلي',
          time: '١٠:٤٥ ص',
          type: 'urgent',
          status: 'confirmed',
        ),
        AppointmentMock(
          id: 'a3',
          patientName: 'خالد عبد الله الحربي',
          doctorName: 'د. أحمد العلي',
          time: '١١:٠٠ ص',
          type: 'normal',
          status: 'confirmed',
        ),
        AppointmentMock(
          id: 'a4',
          patientName: 'منى عبد العزيز الفهد',
          doctorName: 'د. ليلى الشريف',
          time: '١١:٣٠ ص',
          type: 'normal',
          status: 'scheduled',
        ),
        AppointmentMock(
          id: 'a5',
          patientName: 'فيصل عمر الدوسري',
          doctorName: 'د. أحمد العلي',
          time: '١٢:٠٠ م',
          type: 'normal',
          status: 'scheduled',
        ),
      ],
      totalInvoiced: '4,800',
      totalCollected: '3,200',
      totalAppointmentsCount: 18,
    ));
  }

  void confirmArrival(String appointmentId) {
    if (state is SecretaryDashboardLoaded) {
      final loaded = state as SecretaryDashboardLoaded;
      final newToday = loaded.todayAppointments.map((app) {
        if (app.id == appointmentId) {
          return AppointmentMock(
            id: app.id,
            patientName: app.patientName,
            doctorName: app.doctorName,
            time: app.time,
            type: app.type,
            status: 'confirmed',
          );
        }
        return app;
      }).toList();

      final updatedApp = newToday.firstWhere((app) => app.id == appointmentId);
      final newQueue = List<AppointmentMock>.from(loaded.liveQueue);
      if (!newQueue.any((app) => app.id == appointmentId)) {
        newQueue.add(updatedApp);
      } else {
        final idx = newQueue.indexWhere((app) => app.id == appointmentId);
        newQueue[idx] = updatedApp;
      }

      emit(SecretaryDashboardLoaded(
        secretaryName: loaded.secretaryName,
        liveQueue: newQueue,
        todayAppointments: newToday,
        totalInvoiced: loaded.totalInvoiced,
        totalCollected: loaded.totalCollected,
        totalAppointmentsCount: loaded.totalAppointmentsCount,
      ));
    }
  }

  void callPatient(String appointmentId) {
    if (state is SecretaryDashboardLoaded) {
      final loaded = state as SecretaryDashboardLoaded;
      final newQueue = loaded.liveQueue.map((app) {
        if (app.id == appointmentId) {
          return AppointmentMock(
            id: app.id,
            patientName: app.patientName,
            doctorName: app.doctorName,
            time: app.time,
            type: app.type,
            status: 'in_progress',
          );
        }
        return app;
      }).toList();

      final newToday = loaded.todayAppointments.map((app) {
        if (app.id == appointmentId) {
          return AppointmentMock(
            id: app.id,
            patientName: app.patientName,
            doctorName: app.doctorName,
            time: app.time,
            type: app.type,
            status: 'in_progress',
          );
        }
        return app;
      }).toList();

      emit(SecretaryDashboardLoaded(
        secretaryName: loaded.secretaryName,
        liveQueue: newQueue,
        todayAppointments: newToday,
        totalInvoiced: loaded.totalInvoiced,
        totalCollected: loaded.totalCollected,
        totalAppointmentsCount: loaded.totalAppointmentsCount,
      ));
    }
  }
}

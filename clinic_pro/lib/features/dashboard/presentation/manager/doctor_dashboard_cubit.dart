import 'package:flutter_bloc/flutter_bloc.dart';
import 'doctor_dashboard_state.dart';

class DoctorDashboardCubit extends Cubit<DoctorDashboardState> {
  DoctorDashboardCubit() : super(DoctorDashboardInitial());

  void loadDashboardData() async {
    emit(DoctorDashboardLoading());
    await Future.delayed(const Duration(milliseconds: 600));

    emit(const DoctorDashboardLoaded(
      doctorName: 'د. أحمد العلي',
      currentPatient: PatientMock(
        id: 'p1',
        name: 'يوسف سليم الأحمد',
        age: '٣٤ سنة',
        condition: 'مراجعة نتائج تحاليل السكري',
        type: 'normal',
        time: '١٠:٣٠ ص',
      ),
      waitingQueue: [
        PatientMock(
          id: 'p2',
          name: 'فاطمة عمر القحطاني',
          age: '٢٨ سنة',
          condition: 'ألم حاد في الأذن اليمنى',
          type: 'urgent',
          time: '١٠:٤٥ ص',
        ),
        PatientMock(
          id: 'p3',
          name: 'خالد عبد الله الحربي',
          age: '٤٥ سنة',
          condition: 'فحص دوري وضغط دم',
          type: 'normal',
          time: '١١:٠٠ ص',
        ),
        PatientMock(
          id: 'p4',
          name: 'سارة منصور الشمري',
          age: '٥٢ سنة',
          condition: 'متابعة سنوية وغدة درقية',
          type: 'normal',
          time: '١١:١٥ ص',
        ),
      ],
      completedCount: 8,
      waitingCount: 3,
      avgWaitingTime: '١٨ دقيقة',
    ));
  }

  void callNextPatient() {
    if (state is DoctorDashboardLoaded) {
      final loaded = state as DoctorDashboardLoaded;
      if (loaded.waitingQueue.isNotEmpty) {
        final next = loaded.waitingQueue.first;
        final newQueue = List<PatientMock>.from(loaded.waitingQueue)..removeAt(0);
        emit(DoctorDashboardLoaded(
          doctorName: loaded.doctorName,
          currentPatient: next,
          waitingQueue: newQueue,
          completedCount: loaded.completedCount + (loaded.currentPatient != null ? 1 : 0),
          waitingCount: newQueue.length,
          avgWaitingTime: loaded.avgWaitingTime,
        ));
      }
    }
  }
}

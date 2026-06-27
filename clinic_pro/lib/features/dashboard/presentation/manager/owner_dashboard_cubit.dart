import 'package:flutter_bloc/flutter_bloc.dart';
import 'owner_dashboard_state.dart';

class OwnerDashboardCubit extends Cubit<OwnerDashboardState> {
  OwnerDashboardCubit() : super(OwnerDashboardInitial());

  void loadDashboardData() async {
    emit(OwnerDashboardLoading());
    // محاكاة تحميل البيانات
    await Future.delayed(const Duration(milliseconds: 800));

    emit(const OwnerDashboardLoaded(
      ownerName: 'د. عبد الرحمن محمد',
      totalRevenue: '14,500',
      totalPatients: 1240,
      todayAppointments: 42,
      activeClinics: 3,
      clinics: [
        ClinicMock(
          id: '1',
          name: 'عيادة الأمل التخصصية',
          location: 'الرياض، السليمانية',
          doctorsCount: 4,
          patientsCount: 650,
          isActive: true,
        ),
        ClinicMock(
          id: '2',
          name: 'مجمع صحة الأسنان الدولي',
          location: 'جدة، الحمراء',
          doctorsCount: 3,
          patientsCount: 410,
          isActive: true,
        ),
        ClinicMock(
          id: '3',
          name: 'عيادة الأطفال الاستشارية',
          location: 'الدمام، الحزام الذهبي',
          doctorsCount: 2,
          patientsCount: 180,
          isActive: true,
        ),
      ],
      alerts: [
        DashboardAlertMock(
          id: 'a1',
          title: 'انتهاء الفترة التجريبية قريباً',
          message: 'متبقي 4 أيام فقط على انتهاء الفترة التجريبية المجانية. يرجى الترقية للحفاظ على استمرار الخدمة.',
          type: 'warning',
        ),
        DashboardAlertMock(
          id: 'a2',
          title: 'دعوة طاقم معلقة',
          message: 'هناك 2 من الموظفين لم يقبلوا الدعوات بعد للإرسال مجدداً.',
          type: 'info',
        ),
      ],
      weeklyRevenue: [1200, 2500, 1800, 3100, 2200, 2800, 900], // Sun - Sat
    ));
  }
}

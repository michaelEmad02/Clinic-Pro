// ─────────────────────────────────────────
// هذا الملف مسؤول عن جلب بيانات لوحة تحكم المالك
// يقوم بجلب البيانات من جميع العيادات المرتبطة بالمالك
// وتحساب الإحصائيات المجمعة
// ─────────────────────────────────────────

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/services/i_cloud_service.dart';
import '../../../../core/constants/supabase_constants.dart';
import '../../domain/entities/owner_dashboard_entity.dart';
import '../../domain/entities/clinic_summary_entity.dart';
import '../../domain/entities/dashboard_alert_entity.dart';
import 'owner_dashboard_state.dart';

@injectable
class OwnerDashboardCubit extends Cubit<OwnerDashboardState> {
  final ICloudService _cloudService;

  OwnerDashboardCubit(this._cloudService) : super(OwnerDashboardInitial());

  /// معرف المالك الحالي — في مرحلة الـ Mock يُستخدم固定
  /// عند الربط بـ Supabase سيتم جلبه من AuthState
  static const String _currentOwnerId = 'u-owner-1';

  /// جلب جميع بيانات لوحة التحكم
  void loadDashboardData() async {
    emit(OwnerDashboardLoading());
    try {
      // 1. جلب بيانات المالك
      final ownerData = await _fetchOwnerData();

      // 2. جلب العيادات المرتبطة بالمالك
      final clinics = await _fetchOwnerClinics();

      // 3. جلب إحصائيات كل عيادة وحساب المجاميع
      final stats = await _aggregateClinicStats(clinics);

      // 4. جلب تنبيهات الاشتراك والدعوات المعلقة
      final alerts = await _fetchAlerts();

      // 5. جلب بيانات الإيرادات الأسبوعية
      final weeklyRevenue = await _fetchWeeklyRevenue(clinics);

      final dashboard = OwnerDashboardEntity(
        ownerName: ownerData['name'] ?? 'المالك',
        totalRevenue: stats['totalRevenue'],
        totalPatients: stats['totalPatients'],
        todayAppointments: stats['todayAppointments'],
        activeClinics: clinics.where((c) => c['is_active'] == true).length,
        clinics: clinics
            .map((c) => ClinicSummaryEntity(
                  id: c['id'],
                  name: c['name'],
                  location: c['address'] ?? '',
                  doctorsCount: stats['clinicDoctorsCount'][c['id']] ?? 0,
                  patientsCount: stats['clinicPatientsCount'][c['id']] ?? 0,
                  isActive: c['is_active'] == true,
                ))
            .toList(),
        alerts: alerts,
        weeklyRevenue: weeklyRevenue,
      );

      emit(OwnerDashboardLoaded(dashboard: dashboard));
    } catch (e) {
      emit(OwnerDashboardError('حدث خطأ أثناء تحميل البيانات: ${e.toString()}'));
    }
  }

  /// جلب بيانات المالك من جدول المستخدمين
  Future<Map<String, dynamic>> _fetchOwnerData() async {
    final results = await _cloudService.select(
      table: SupabaseTables.users,
      eq: {'id': _currentOwnerId},
    );
    if (results.isEmpty) {
      return {'name': 'المالك'};
    }
    return results.first;
  }

  /// جلب جميع العيادات المرتبطة بالمالك
  Future<List<Map<String, dynamic>>> _fetchOwnerClinics() async {
    return await _cloudService.select(
      table: SupabaseTables.clinics,
      eq: {'owner_id': _currentOwnerId},
    );
  }

  /// تجميع إحصائيات جميع العيادات
  Future<Map<String, dynamic>> _aggregateClinicStats(List<Map<String, dynamic>> clinics) async {
    int totalPatients = 0;
    int todayAppointments = 0;
    num totalRevenue = 0;
    final Map<String, int> clinicDoctorsCount = {};
    final Map<String, int> clinicPatientsCount = {};

    for (final clinic in clinics) {
      final clinicId = clinic['id'] as String;

      // جلب إحصائيات العيادة من جدول clinic_stats
      final statsResults = await _cloudService.select(
        table: 'clinic_stats',
        eq: {'clinic_id': clinicId},
      );

      if (statsResults.isNotEmpty) {
        final clinicStat = statsResults.first;
        final patients = (clinicStat['total_patients'] as num?)?.toInt() ?? 0;
        final appointments = (clinicStat['today_appointments'] as num?)?.toInt() ?? 0;
        final revenue = (clinicStat['monthly_revenue'] as num?) ?? 0;

        totalPatients += patients;
        todayAppointments += appointments;
        totalRevenue += revenue;
        clinicPatientsCount[clinicId] = patients;
      }

      // جلب عدد الأطباء في العيادة من جدول clinic_staff
      final staffResults = await _cloudService.select(
        table: SupabaseTables.clinicStaff,
        eq: {'clinic_id': clinicId, 'role': 'doctor', 'is_active': true},
      );
      clinicDoctorsCount[clinicId] = staffResults.length;
    }

    return {
      'totalPatients': totalPatients,
      'todayAppointments': todayAppointments,
      'totalRevenue': totalRevenue,
      'clinicDoctorsCount': clinicDoctorsCount,
      'clinicPatientsCount': clinicPatientsCount,
    };
  }

  /// جلب التنبيهات من حالة الاشتراك والدعوات المعلقة
  Future<List<DashboardAlertEntity>> _fetchAlerts() async {
    final alerts = <DashboardAlertEntity>[];

    // فحص حالة الاشتراك
    final subscriptions = await _cloudService.select(
      table: SupabaseTables.subscriptions,
      eq: {'owner_id': _currentOwnerId},
    );

    if (subscriptions.isNotEmpty) {
      final subscription = subscriptions.first;
      final status = subscription['status'] as String?;

      if (status == SubscriptionStatus.trial) {
        final trialEnd = subscription['trial_end_at'] as String?;
        if (trialEnd != null) {
          final endDate = DateTime.tryParse(trialEnd);
          if (endDate != null) {
            final daysLeft = endDate.difference(DateTime.now()).inDays;
            if (daysLeft <= 7 && daysLeft >= 0) {
              alerts.add(DashboardAlertEntity(
                id: 'sub-trial',
                title: 'انتهاء الفترة التجريبية قريباً',
                message: 'متبقي $daysLeft أيام فقط على انتهاء الفترة التجريبية المجانية. يرجى الترقية للحفاظ على استمرار الخدمة.',
                type: DashboardAlertType.warning,
              ));
            }
          }
        }
      } else if (status == SubscriptionStatus.expired) {
        alerts.add(const DashboardAlertEntity(
          id: 'sub-expired',
          title: 'الاشتراك منتهي',
          message: 'اشتراكك منتهي. يرجى تجديد الاشتراك للاستمرار في استخدام الخدمة.',
          type: DashboardAlertType.warning,
        ));
      }
    }

    // فحص الدعوات المعلقة
    final invitations = await _cloudService.select(
      table: 'invitations',
      eq: {'owner_id': _currentOwnerId, 'status': 'pending'},
    );

    if (invitations.isNotEmpty) {
      alerts.add(DashboardAlertEntity(
        id: 'pending-invitations',
        title: 'دعوات معلقة',
        message: 'لديك ${invitations.length} دعوة معلقة في انتظار قبول الموظفين.',
        type: DashboardAlertType.info,
      ));
    }

    return alerts;
  }

  /// جلب بيانات الإيرادات الأسبوعية من الفواتير
  Future<List<double>> _fetchWeeklyRevenue(List<Map<String, dynamic>> clinics) async {
    final now = DateTime.now();
    final weeklyRevenue = List<double>.filled(7, 0);

    for (final clinic in clinics) {
      final clinicId = clinic['id'] as String;

      // جلب فواتير آخر 7 أيام
      for (int i = 0; i < 7; i++) {
        final day = now.subtract(Duration(days: 6 - i));
        final dayStr = day.toIso8601String().substring(0, 10);

        final invoices = await _cloudService.select(
          table: SupabaseTables.invoices,
          eq: {'clinic_id': clinicId},
        );

        // تصفية الفواتير حسب اليوم
        for (final invoice in invoices) {
          final invoiceDate = (invoice['created_at'] as String?)?.substring(0, 10);
          if (invoiceDate == dayStr) {
            final amount = (invoice['paid_amount'] as num?) ?? 0;
            weeklyRevenue[i] += amount.toDouble();
          }
        }
      }
    }

    return weeklyRevenue;
  }
}

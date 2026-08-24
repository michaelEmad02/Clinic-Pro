// ─────────────────────────────────────────
// تنفيذ مصدر البيانات البعيدة الخفيف جداً والمدعوم بـ RPC مخصصة لـ Owner Dashboard (Data Layer)
// يستدعي الـ Dedicated RPC Functions (get_owner_dashboard_stats_rpc, get_owner_weekly_revenue_rpc, get_owner_clinics_overview_rpc)
// مع وجود Fallback خفيف في حال لم يتم تشغيل الـ RPC على Supabase بعد
// ─────────────────────────────────────────

import 'package:injectable/injectable.dart';
import 'package:clinic_pro/core/services/i_cloud_service.dart';
import 'package:clinic_pro/core/constants/supabase_constants.dart';
import 'package:clinic_pro/core/strings/app_strings.dart';
import '../../domain/entities/clinic_summary_entity.dart';
import '../../domain/entities/dashboard_alert_entity.dart';
import '../models/owner_summary_stats_model.dart';
import 'i_owner_dashboard_remote_data_source.dart';

@LazySingleton(as: IOwnerDashboardRemoteDataSource)
class OwnerDashboardRemoteDataSourceImpl implements IOwnerDashboardRemoteDataSource {
  final ICloudService _cloudService;

  OwnerDashboardRemoteDataSourceImpl(this._cloudService);

  @override
  Future<OwnerSummaryStatsModel> fetchSummaryStats(
    String ownerId, {
    bool forceRefresh = false,
  }) async {
    // 1. محاولة استدعاء الـ RPC المخصصة لـ Owner Dashboard
    try {
      final response = await _cloudService.rpc('get_owner_dashboard_stats_rpc', params: {
        'p_owner_id': ownerId,
      });

      final Map<String, dynamic> data = (response is Map<String, dynamic>)
          ? response
          : ((response is List && response.isNotEmpty) ? response.first as Map<String, dynamic> : {});

      if (data.isNotEmpty) {
        return OwnerSummaryStatsModel(
          todayNetRevenue: ((data['today_net_revenue'] ?? 0) as num).toDouble(),
          todayAppointments: (data['today_appointments'] as num? ?? 0).toInt(),
          todayCompletedAppointments: (data['today_completed_appointments'] as num? ?? 0).toInt(),
          totalPatients: (data['total_patients'] as num? ?? 0).toInt(),
        );
      }
    } catch (_) {}

    // Fallback خفيف ومستهدف ومفلتر حسب عيادات المالك (Owner Clinics)
    final now = DateTime.now();
    final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    num todayNetRevenue = 0;
    int todayAppointments = 0;
    int todayCompletedAppointments = 0;
    int totalPatients = 0;

    try {
      // 1. جلب قائمة العيادات الخاصة بهذا المالك فقط
      final ownerClinics = await _cloudService.select(
        table: SupabaseTables.clinics,
        eq: {'owner_id': ownerId},
      );

      final clinicIds = ownerClinics
          .map((c) => c['id'] as String?)
          .where((id) => id != null && id.isNotEmpty)
          .cast<String>()
          .toList();

      if (clinicIds.isNotEmpty) {
        // 2. حساب المواعيد الخاصة بعيادات المالك اليوم
        final todayApptsRaw = await _cloudService.select(
          table: SupabaseTables.appointments,
          eq: {'date': todayStr},
          filterIn: {'clinic_id': clinicIds},
        );
        todayAppointments = todayApptsRaw.length;
        for (var appt in todayApptsRaw) {
          final st = appt['status'] as String?;
          if (st == 'done' || st == 'confirmed') {
            todayCompletedAppointments++;
          }
        }

        // 3. حساب فواتير وإيرادات اليوم الخاصة بعيادات المالك فقط
        final todayInvoicesRaw = await _cloudService.select(
          table: SupabaseTables.invoices,
          gte: {'created_at': '${todayStr}T00:00:00'},
          lte: {'created_at': '${todayStr}T23:59:59'},
          filterIn: {'clinic_id': clinicIds},
        );
        for (var inv in todayInvoicesRaw) {
          todayNetRevenue += ((inv['paid_amount'] ?? 0) as num).toDouble();
        }

        // 4. حساب إجمالي عدد المرضى لعيادات هذا المالك فقط
        final patientsRaw = await _cloudService.select(
          table: SupabaseTables.patients,
          filterIn: {'clinic_id': clinicIds},
        );
        totalPatients = patientsRaw.length;
      }
    } catch (_) {}

    return OwnerSummaryStatsModel(
      todayNetRevenue: todayNetRevenue,
      todayAppointments: todayAppointments,
      todayCompletedAppointments: todayCompletedAppointments,
      totalPatients: totalPatients,
    );
  }

  @override

  Future<List<double>> fetchWeeklyRevenue(
    String ownerId, {
    bool forceRefresh = false,
  }) async {
    // 1. محاولة استدعاء الـ RPC المخصصة لإيرادات الأسبوع
    try {
      final response = await _cloudService.rpc('get_owner_weekly_revenue_rpc', params: {
        'p_owner_id': ownerId,
      });

      final List rawList = (response is List) ? response : [];
      if (rawList.isNotEmpty) {
        return rawList
            .map((e) => (((e as Map<String, dynamic>)['collected'] ?? 0) as num).toDouble())
            .toList();
      }
    } catch (_) {}

    // Fallback خفيف ومفلتر حسب عيادات الـ Owner فقط
    final now = DateTime.now();
    final weeklyRevenue = List<double>.filled(7, 0.0);

    try {
      final ownerClinics = await _cloudService.select(
        table: SupabaseTables.clinics,
        eq: {'owner_id': ownerId},
      );

      final clinicIds = ownerClinics
          .map((c) => c['id'] as String?)
          .where((id) => id != null && id.isNotEmpty)
          .cast<String>()
          .toList();

      if (clinicIds.isNotEmpty) {
        final sevenDaysAgo = now.subtract(const Duration(days: 6));
        final startDateStr = '${sevenDaysAgo.year}-${sevenDaysAgo.month.toString().padLeft(2, '0')}-${sevenDaysAgo.day.toString().padLeft(2, '0')}T00:00:00';

        final invoices = await _cloudService.select(
          table: SupabaseTables.invoices,
          gte: {'created_at': startDateStr},
          filterIn: {'clinic_id': clinicIds},
        );

        for (int i = 0; i < 7; i++) {
          final day = now.subtract(Duration(days: 6 - i));
          final dayStr = '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';

          for (final invoice in invoices) {
            final createdAt = invoice['created_at'] as String?;
            if (createdAt != null && createdAt.startsWith(dayStr)) {
              final amt = ((invoice['paid_amount'] ?? 0) as num).toDouble();
              weeklyRevenue[i] += amt;
            }
          }
        }
      }
    } catch (_) {}

    return weeklyRevenue;
  }


  @override
  Future<List<ClinicSummaryEntity>> fetchClinicsOverview(
    String ownerId, {
    bool forceRefresh = false,
  }) async {
    // 1. محاولة استدعاء الـ RPC المخصصة لقائمة العيادات
    try {
      final response = await _cloudService.rpc('get_owner_clinics_overview_rpc', params: {
        'p_owner_id': ownerId,
      });

      final List rawList = (response is List) ? response : [];
      if (rawList.isNotEmpty) {
        return rawList.map((c) {
          final map = c as Map<String, dynamic>;
          return ClinicSummaryEntity(
            id: map['id'] as String? ?? '',
            name: map['name'] as String? ?? 'عيادة',
            location: map['address'] as String? ?? '',
            doctorsCount: (map['doctors_count'] as num? ?? 0).toInt(),
            patientsCount: (map['patients_count'] as num? ?? 0).toInt(),
            isActive: map['is_active'] as bool? ?? true,
          );
        }).toList();
      }
    } catch (_) {}

    // Fallback خفيف
    final clinicsRaw = await _cloudService.select(
      table: SupabaseTables.clinics,
      eq: {'owner_id': ownerId},
    );

    if (clinicsRaw.isEmpty) return const [];

    final List<ClinicSummaryEntity> result = [];
    for (var c in clinicsRaw) {
      final clinicId = c['id'] as String;
      final name = c['name'] as String? ?? 'عيادة';
      final address = c['address'] as String? ?? '';
      final isActive = c['is_active'] as bool? ?? true;

      int docsCount = 0;
      try {
        final staff = await _cloudService.select(
          table: SupabaseTables.clinicStaff,
          eq: {'clinic_id': clinicId, 'role': 'doctor'},
        );
        docsCount = staff.length;
      } catch (_) {}

      result.add(ClinicSummaryEntity(
        id: clinicId,
        name: name,
        location: address,
        doctorsCount: docsCount,
        patientsCount: 0,
        isActive: isActive,
      ));
    }

    return result;
  }

  @override
  Future<List<DashboardAlertEntity>> fetchAlerts(
    String ownerId, {
    bool forceRefresh = false,
  }) async {
    final alerts = <DashboardAlertEntity>[];

    try {
      final subscriptions = await _cloudService.select(
        table: SupabaseTables.subscriptions,
        eq: {'owner_id': ownerId},
      );
      if (subscriptions.isNotEmpty) {
        final sub = subscriptions.first;
        final status = sub['status'] as String?;
        if (status == SubscriptionStatus.expired) {
          alerts.add(DashboardAlertEntity(
            id: 'sub-expired',
            title: AppStrings.isArabic ? 'الاشتراك منتهي' : 'Subscription Expired',
            message: AppStrings.isArabic
                ? 'اشتراكك منتهي. يرجى تجديد الاشتراك للاستمرار في استخدام الخدمة.'
                : 'Your subscription has expired. Please renew to continue using the service.',
            type: DashboardAlertType.warning,
          ));
        }
      }

      final invitations = await _cloudService.select(
        table: 'invitations',
        eq: {'owner_id': ownerId, 'status': 'pending'},
      );
      if (invitations.isNotEmpty) {
        alerts.add(DashboardAlertEntity(
          id: 'pending-invitations',
          title: AppStrings.pendingInvitations,
          message: AppStrings.isArabic
              ? 'لديك ${invitations.length} دعوة معلقة في انتظار قبول الموظفين.'
              : 'You have ${invitations.length} pending invitation(s) awaiting staff acceptance.',
          type: DashboardAlertType.info,
        ));
      }
    } catch (_) {}

    return alerts;
  }
}

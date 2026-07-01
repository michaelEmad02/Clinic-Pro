// ────────────────────────────────────────────────────────
// هذا الملف مسؤول عن جلب بيانات التقارير
// يستخدم ICloudService لجلب الفواتير والمصروفات وإحصائيات الأداء
// ────────────────────────────────────────────────────────

import 'package:injectable/injectable.dart';
import 'package:clinic_pro/core/services/i_cloud_service.dart';
import 'reports_state.dart';

@injectable
class ReportsRepository {
  final ICloudService _cloud;

  ReportsRepository(this._cloud);

  Future<List<Map<String, dynamic>>> loadInvoices() async {
    return _cloud.select(table: 'invoices');
  }

  Future<List<Map<String, dynamic>>> loadExpenses() async {
    return _cloud.select(table: 'expenses');
  }

  Future<List<TopServiceItem>> loadTopServices() async {
    final data = await _cloud.select(table: 'top_services');
    return data.map((s) => TopServiceItem(
      name: s['name'] as String,
      revenue: (s['revenue'] as num).toDouble(),
      icon: s['icon'] as String,
    )).toList();
  }

  Future<List<DoctorPerformanceItem>> loadDoctorPerformance() async {
    final data = await _cloud.select(table: 'doctor_performance');
    return data.map((d) => DoctorPerformanceItem(
      doctorId: d['doctor_id'] as String,
      doctorName: d['doctor_name'] as String,
      patientCount: d['patient_count'] as int,
      revenue: (d['revenue'] as num).toDouble(),
      rating: d['rating'] as int,
      trend: d['trend'] as String,
      avatarUrl: d['avatar_url'] as String?,
    )).toList();
  }

  Future<List<Map<String, dynamic>>> loadWeeklyRevenue() async {
    return _cloud.select(table: 'weekly_revenue');
  }
}

import 'package:clinic_pro/core/constants/supabase_constants.dart';
import 'package:clinic_pro/core/services/i_cloud_service.dart';
import 'package:injectable/injectable.dart';
import 'i_doctor_dashboard_remote_data_source.dart';

@LazySingleton(as: IDoctorDashboardRemoteDataSource)
class DoctorDashboardRemoteDataSourceImpl
    implements IDoctorDashboardRemoteDataSource {
  final ICloudService _cloudService;

  DoctorDashboardRemoteDataSourceImpl(this._cloudService);

  @override
  Future<Map<String, dynamic>> fetchDoctorDashboardData({
    required String doctorId,
    required String clinicId,
    String? doctorName,
    String? clinicName,
  }) async {
    String resolvedDoctorName = doctorName ?? '';
    if (resolvedDoctorName.isEmpty) {
      final doctorResults = await _cloudService.select(
        table: SupabaseTables.users,
        eq: {'id': doctorId},
      );
      resolvedDoctorName = doctorResults.isNotEmpty
          ? (doctorResults.first['name'] as String? ?? 'دكتور')
          : 'دكتور';
    }

    String resolvedClinicName = clinicName ?? '';
    if (resolvedClinicName.isEmpty) {
      final clinicResults = await _cloudService.select(
        table: SupabaseTables.clinics,
        eq: {'id': clinicId},
      );
      resolvedClinicName = clinicResults.isNotEmpty
          ? (clinicResults.first['name'] as String? ?? 'العيادة')
          : 'العيادة';
    }

    return {
      'doctor_name': resolvedDoctorName,
      'clinic_name': resolvedClinicName,
    };
  }

  @override
  Future<double> fetchTodayCollectedAmount({
    required String clinicId,
    required List<String> appointmentIds,
  }) async {
    if (appointmentIds.isEmpty) return 0.0;
    try {
      final invoices = await _cloudService.select(
        table: SupabaseTables.invoices,
        eq: {'clinic_id': clinicId , 'created_at' : DateTime.now().toIso8601String().substring(0, 10)},
      );

      final apptIdSet = appointmentIds.toSet();
      double totalCollected = 0.0;

      for (final raw in invoices) {
        final sourceId = raw['source_id'] as String?;
        if (sourceId != null && apptIdSet.contains(sourceId)) {
          final paidAmount = (raw['paid_amount'] as num?)?.toDouble() ?? 0.0;
          totalCollected += paidAmount;
        }
      }
      return totalCollected;
    } catch (_) {
      return 0.0;
    }
  }
}

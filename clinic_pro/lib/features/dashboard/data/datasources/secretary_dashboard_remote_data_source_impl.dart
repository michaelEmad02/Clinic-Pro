import 'package:clinic_pro/core/constants/supabase_constants.dart';
import 'package:clinic_pro/core/services/i_cloud_service.dart';
import 'package:injectable/injectable.dart';
import 'i_secretary_dashboard_remote_data_source.dart';

@LazySingleton(as: ISecretaryDashboardRemoteDataSource)
class SecretaryDashboardRemoteDataSourceImpl
    implements ISecretaryDashboardRemoteDataSource {
  final ICloudService _cloudService;

  SecretaryDashboardRemoteDataSourceImpl(this._cloudService);

  @override
  Future<Map<String, dynamic>> fetchSecretaryDashboardData({
    required String secretaryId,
    required String clinicId,
    String? secretaryName,
    String? clinicName,
  }) async {
    // 1. جلب اسم السكرتير
    String resolvedSecretaryName = secretaryName ?? '';
    if (resolvedSecretaryName.isEmpty) {
      final secResults = await _cloudService.select(
        table: SupabaseTables.users,
        eq: {'id': secretaryId},
      );
      resolvedSecretaryName = secResults.isNotEmpty
          ? (secResults.first['name'] as String? ?? 'سكرتير')
          : 'سكرتير';
    }

    // 2. جلب اسم العيادة
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

    // 3. جلب الطبيب النشط المرتبط بالسكرتير إن وجد من العلاقات المحددة بواسطة المالك
    String doctorName = 'دكتور العيادة';
    String? activeDoctorId;
    try {
      final docSecResults = await _cloudService.select(
        table: SupabaseTables.doctorSecretaries,
        eq: {'secretary_id': secretaryId, 'clinic_id': clinicId, 'is_active': true},
      );
      if (docSecResults.isNotEmpty) {
        activeDoctorId = docSecResults.first['doctor_id'] as String?;
      } else {
        // إذا لم يكن هناك طبيب نشط محدد، نأخذ أول طبيب مربوط بالسكرتيرة من قِبل المالك
        final anySecDoc = await _cloudService.select(
          table: SupabaseTables.doctorSecretaries,
          eq: {'secretary_id': secretaryId, 'clinic_id': clinicId},
        );
        if (anySecDoc.isNotEmpty) {
          activeDoctorId = anySecDoc.first['doctor_id'] as String?;
        }
      }

      if (activeDoctorId != null && activeDoctorId.isNotEmpty) {
        final docUserResults = await _cloudService.select(
          table: SupabaseTables.users,
          eq: {'id': activeDoctorId},
        );
        if (docUserResults.isNotEmpty) {
          doctorName = docUserResults.first['name'] as String? ?? doctorName;
        }
      }
    } catch (_) {}

    return {
      'secretary_name': resolvedSecretaryName,
      'clinic_name': resolvedClinicName,
      'doctor_name': doctorName,
      'active_doctor_id': activeDoctorId,
    };
  }
}

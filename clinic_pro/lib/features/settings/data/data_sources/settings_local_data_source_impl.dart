// ────────────────────────────────────────────────────────
// تطبيق مصدر البيانات المحلي للإعدادات (SettingsLocalDataSourceImpl)
// يقوم بتخزين العيادة والدكتور النشطين بشرط userId المستخدم الحقيقي
// ────────────────────────────────────────────────────────

import 'package:injectable/injectable.dart';
import '../../../../core/services/i_local_data_service.dart';
import 'i_settings_local_data_source.dart';

@LazySingleton(as: ISettingsLocalDataSource)
class SettingsLocalDataSourceImpl implements ISettingsLocalDataSource {
  final ILocalDataService _localDataService;

  SettingsLocalDataSourceImpl(this._localDataService);

  String _getClinicKey(String userId) => 'active_clinic_id_$userId';
  String _getDoctorKey(String userId) => 'active_doctor_id_$userId';

  @override
  Future<String?> getActiveClinicId(String userId) async {
    final clinicId = await _localDataService.getString(_getClinicKey(userId));
    return (clinicId != null && clinicId.isNotEmpty) ? clinicId : null;
  }

  @override
  Future<void> saveActiveClinicId(String userId, String clinicId) async {
    await _localDataService.setString(_getClinicKey(userId), clinicId);
  }

  @override
  Future<String?> getActiveDoctorId(String userId) async {
    final doctorId = await _localDataService.getString(_getDoctorKey(userId));
    return (doctorId != null && doctorId.isNotEmpty) ? doctorId : null;
  }

  @override
  Future<void> saveActiveDoctorId(String userId, String doctorId) async {
    await _localDataService.setString(_getDoctorKey(userId), doctorId);
  }

  @override
  Future<void> clearSettings(String userId) async {
    await _localDataService.remove(_getClinicKey(userId));
    await _localDataService.remove(_getDoctorKey(userId));
  }
}

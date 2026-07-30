// ────────────────────────────────────────────────────────
// تنفيذ مصدر بيانات المرضى البعيد (PatientsRemoteDataSourceImpl)
// يتعامل مع ICloudService لجلب وإدارة بيانات المرضى
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/features/appointments/data/models/appointment_model.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/constants/supabase_constants.dart';
import '../../../../core/services/i_cloud_service.dart';
import '../models/patient_model.dart';
import 'i_patients_remote_data_source.dart';

@LazySingleton(as: IPatientsRemoteDataSource)
class PatientsRemoteDataSourceImpl implements IPatientsRemoteDataSource {
  final ICloudService _cloud;

  PatientsRemoteDataSourceImpl(this._cloud);

  @override
  Future<List<PatientModel>> getPatients({required String clinicId}) async {
    final data = await _cloud.select(
      table: SupabaseTables.patients,
      eq: clinicId.isNotEmpty ? {'clinic_id': clinicId} : null,
    );
    return data.map((raw) => PatientModel.fromJson(raw)).toList();
  }

  @override
  Future<PatientModel> getPatientById(String id) async {
    final data = await _cloud.select(
      table: SupabaseTables.patients,
      eq: {'id': id},
    );

    if (data.isEmpty) {
      throw Exception('المريض غير موجود');
    }

    return PatientModel.fromJson(data.first);
  }

  @override
  Future<PatientModel> insertPatient(PatientModel patient) async {
    final result = await _cloud.insert(
      table: SupabaseTables.patients,
      data: patient.toJson(),
    );
    return PatientModel.fromJson(result);
  }

  @override
  Future<PatientModel> updatePatient(PatientModel patient) async {
    final result = await _cloud.update(
      table: SupabaseTables.patients,
      data: patient.toUpdateJson(),
      matchColumn: 'id',
      matchValue: patient.id,
    );

    if (result.isEmpty) {
      throw Exception('فشل تحديث بيانات المريض');
    }

    return PatientModel.fromJson(result.first);
  }

  @override
  Future<void> deletePatient(String id) async {
    await _cloud.delete(
      table: SupabaseTables.patients,
      matchColumn: 'id',
      matchValue: id,
    );
  }

  @override
  Future<List<AppointmentModel>> getVisitsForPatient(
    String patientId,
  ) async {
    // جلب المواعيد المرتبطة بالمريض (appointments WHERE patient_id = X)
    final appointments = await _cloud.select(
      table: SupabaseTables.appointments,
      eq: {'patient_id': patientId},
      order: 'created_at',
      ascending: false,
    );

    if (appointments.isEmpty) return [];

    // جلب بيانات المريض مرة واحدة بدلاً من إعادتها في كل موعد
    final patients = await _cloud.select(
      table: SupabaseTables.patients,
      eq: {'id': patientId},
    );
    final patientMap = patients.isNotEmpty
        ? patients.first
        : {'name': 'مريض غير معروف', 'phone': ''};

    final doctorCache = <String, Map<String, dynamic>>{};
    final typeCache = <String, Map<String, dynamic>>{};

    final visits = <AppointmentModel>[];
    for (final raw in appointments) {
      final doctorId = raw['doctor_id'] as String?;
      final typeId = raw['type_id'] as String?;
      final clinicId = raw['clinic_id'] as String?;

      // جلب بيانات الطبيب مع التخزين المؤقت
      Map<String, dynamic> doctorMap = {'name': 'طبيب غير معروف'};
      if (doctorId != null && doctorId.isNotEmpty) {
        if (doctorCache.containsKey(doctorId)) {
          doctorMap = doctorCache[doctorId]!;
        } else {
          final doctors = await _cloud.select(
            table: SupabaseTables.users,
            eq: {'id': doctorId},
          );
          if (doctors.isNotEmpty) doctorMap = doctors.first;
          doctorCache[doctorId] = doctorMap;
        }
      }

      // جلب نوع الموعد مع التخزين المؤقت
      Map<String, dynamic> typeMap = {'name': 'كشف عادي'};
      final typeCacheKey = '${doctorId}_${clinicId}_$typeId';
      if (typeId != null && typeId.isNotEmpty) {
        if (typeCache.containsKey(typeCacheKey)) {
          typeMap = typeCache[typeCacheKey]!;
        } else {
          try {
            final doctorTypes = await _cloud.select(
              table: SupabaseTables.doctorAppointmentTypes,
              eq: {
                if (doctorId != null) 'doctor_id': doctorId,
                if (clinicId != null) 'clinic_id': clinicId,
                'id': typeId,
              },
            );
            if (doctorTypes.isNotEmpty) {
              final types = await _cloud.select(
                table: SupabaseTables.appointmentTypes,
                eq: {'id': doctorTypes.first['appointment_type_id']},
              );
              if (types.isNotEmpty) typeMap = types.first;
            }
          } catch (_) {}
          typeCache[typeCacheKey] = typeMap;
        }
      }

      final enrichedMap = {
        ...raw,
        'patients': patientMap,
        'appointment_types': typeMap,
        'users': doctorMap,
      };

      visits.add(AppointmentModel.fromJson(enrichedMap));
    }

    return visits;
  }
}

// ────────────────────────────────────────────────────────
// تنفيذ مصدر بيانات المواعيد (AppointmentRemoteDataSourceImpl)
// يتعامل مباشرة مع ICloudService لجلب البيانات وإغنائها
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/constants/supabase_constants.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/services/i_cloud_service.dart';
import '../models/appointment_model.dart';
import 'i_appointment_remote_data_source.dart';
import '../../../prescription/data/models/drug_model.dart';

@LazySingleton(as: IAppointmentRemoteDataSource)
class AppointmentRemoteDataSourceImpl implements IAppointmentRemoteDataSource {
  final ICloudService _cloud;

  AppointmentRemoteDataSourceImpl(this._cloud);

  @override
  Future<List<AppointmentModel>> getAppointments({
    required String clinicId,
    String? doctorId,
    String? date,
    String? status,
  }) async {
    final Map<String, dynamic> eq = {'clinic_id': clinicId};
    if (doctorId != null) eq['doctor_id'] = doctorId;
    if (date != null) eq['date'] = date;
    if (status != null) eq['status'] = status;

    final appointments = await _cloud.select(
      table: SupabaseTables.appointments,
      eq: eq,
    );

    final List<AppointmentModel> models = [];

    for (final raw in appointments) {
      final enriched = await _enrichAppointmentData(raw, detailed: false);
      models.add(AppointmentModel.fromJson(enriched));
    }

    return models;
  }

  @override
  Future<AppointmentModel> getAppointmentById(String id) async {
    final appointments = await _cloud.select(
      table: SupabaseTables.appointments,
      eq: {'id': id},
    );

    if (appointments.isEmpty) {
      throw Exception('الموعد غير موجود');
    }

    final enriched = await _enrichAppointmentData(appointments.first, detailed: true);
    return AppointmentModel.fromJson(enriched);
  }

  @override
  Future<AppointmentModel> getEnrichedAppointmentById(String id) async {
    final appointments = await _cloud.select(
      table: SupabaseTables.appointments,
      eq: {'id': id},
    );

    if (appointments.isEmpty) {
      throw Exception('الموعد غير موجود');
    }

    final enriched = await _enrichAppointmentData(appointments.first, detailed: false);
    return AppointmentModel.fromJson(enriched);
  }

  @override
  Future<AppointmentModel> insertAppointment(
      AppointmentModel appointment) async {
    final data = appointment.toJson();
    
    // جلب السعر الفعلي من نوع الزيارة
    try {
      final typeResult = await _cloud.select(
        table: SupabaseTables.doctorAppointmentTypes,
        eq: {'id': appointment.typeId},
      );
      if (typeResult.isNotEmpty) {
        data['price'] = (typeResult.first['price'] as num? ?? 0.0).toDouble();
      }
    } catch (_) {}

    final result = await _cloud.insert(
      table: SupabaseTables.appointments,
      data: data,
    );
    final enriched = await _enrichAppointmentData(result, detailed: false);
    return AppointmentModel.fromJson(enriched);
  }

  @override
  Future<AppointmentModel> updateAppointment(AppointmentModel appointment) async {
    final data = appointment.toJson();

    // جلب السعر الفعلي من نوع الزيارة عند التحديث أيضاً
    try {
      final typeResult = await _cloud.select(
        table: SupabaseTables.doctorAppointmentTypes,
        eq: {'id': appointment.typeId},
      );
      if (typeResult.isNotEmpty) {
        data['price'] = (typeResult.first['price'] as num? ?? 0.0).toDouble();
      }
    } catch (_) {}

    final results = await _cloud.update(
      table: SupabaseTables.appointments,
      data: data,
      matchColumn: 'id',
      matchValue: appointment.id,
    );
    if (results.isEmpty) {
      throw Exception('فشل تحديث الموعد');
    }
    final enriched = await _enrichAppointmentData(results.first, detailed: false);
    return AppointmentModel.fromJson(enriched);
  }

  @override
  Future<List<Map<String, dynamic>>> updateFields({
    required String appointmentId,
    required Map<String, dynamic> fields,
  }) async {
    return await _cloud.update(
      table: SupabaseTables.appointments,
      data: fields,
      matchColumn: 'id',
      matchValue: appointmentId,
    );
  }

  @override
  Future<void> deleteAppointment(String appointmentId) async {
    await _cloud.delete(
      table: SupabaseTables.appointments,
      matchColumn: 'id',
      matchValue: appointmentId,
    );
  }

  @override
  Future<void> deleteRelatedInvoices(String appointmentId) async {
    await _cloud.delete(
      table: SupabaseTables.invoices,
      matchColumn: 'source_id',
      matchValue: appointmentId,
    );
  }

  @override
  Stream<List<Map<String, dynamic>>> subscribeAppointments({
    required String clinicId,
  }) {
    return _cloud.subscribe(
      table: SupabaseTables.appointments,
      primaryKey: 'id',
      clinicId: clinicId,
    );
  }

  /// دالة مساعدة لإغناء بيانات الموعد الخام ببيانات المريض، الطبيب ونوع الزيارة
  Future<Map<String, dynamic>> _enrichAppointmentData(
      Map<String, dynamic> raw, {
      required bool detailed,
  }) async {
    final patientId = raw['patient_id'];
    final typeId = raw['type_id'];
    final doctorId = raw['doctor_id'];
    final clinicId = raw['clinic_id'];

    // جلب بيانات المريض
    final patients = await _cloud.select(
      table: SupabaseTables.patients,
      eq: {'id': patientId},
    );
    final patient = patients.isNotEmpty
        ? patients.first
        : {'name': 'مريض غير معروف', 'phone': ''};

    final doctorTypes = await _cloud.select(
      table: SupabaseTables.doctorAppointmentTypes,
      eq: {'doctor_id': doctorId, 'clinic_id': clinicId, 'id': typeId},
    );

    // جلب بيانات نوع الموعد
    final types = await _cloud.select(
      table: SupabaseTables.appointmentTypes,
      eq: {'id': doctorTypes.isNotEmpty ? doctorTypes.first['appointment_type_id'] : null},
    );

    final type = types.isNotEmpty ? types.first : {'name': 'كشف عادي'};

    // جلب بيانات الطبيب
    final doctors = await _cloud.select(
      table: 'users',
      eq: {'id': doctorId},
    );
    final doctor =
        doctors.isNotEmpty ? doctors.first : {'name': 'طبيب غير معروف'};

    List<Map<String, dynamic>> prescriptions = [];
    List<Map<String, dynamic>> invoices = [];
    List<Map<String, dynamic>> prescriptionDrugs = [];

    if (detailed) {
      // جلب الروشتة المرتبطة بالزيارة إن وجدت
      prescriptions = await _cloud.select(
        table: SupabaseTables.prescriptions,
        eq: {'appointment_id': raw['id']},
      );

      if (prescriptions.isNotEmpty) {
        final prescriptionId = prescriptions.first['id'];
        
        // جلب عناصر الروشتة
        final items = await _cloud.select(
          table: SupabaseTables.prescriptionItems,
          eq: {'prescription_id': prescriptionId},
        );

        // جلب قائمة الأدوية بالكامل للمطابقة
        final drugs = await _cloud.select(table: SupabaseTables.drugs);
        final drugsMap = {for (final d in drugs) d['id']: d};

        for (final item in items) {
          final drug = drugsMap[item['drug_id']];
          
          final drugModel = drug != null ? DrugModel(
            id: drug['id'] as String,
            tradeName: drug['trade_name'] as String?,
            genericName: drug['generic_name'] as String?,
            category: drug['category'] as String?,
          ) : null;

          prescriptionDrugs.add({
            'id': item['id'],
            'prescription_id': prescriptionId,
            'drug_id': item['drug_id'],
            'frequency': item['frequency'],
            'duration': item['duration'],
            'timing': item['timing'],
            'is_prn': item['is_prn'] ?? false,
            'drugs': drugModel != null ? drugModel.toJson() : null,
          });
        }
      }

      // جلب الفواتير المرتبطة بالزيارة إن وجدت
      invoices = await _cloud.select(
        table: SupabaseTables.invoices,
        eq: {'source_id': raw['id']},
      );
    }

    return {
      ...raw,
      'patients': patient,
      'appointment_types': type,
      'users': doctor,
      'prescriptions': prescriptions,
      'invoices': invoices,
      'prescription_drugs': prescriptionDrugs,
    };
  }
}

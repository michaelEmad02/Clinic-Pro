// ────────────────────────────────────────────────────────
// تنفيذ مصدر بيانات المواعيد السريع عبر Postgres RPC (AppointmentRpcRemoteDataSourceImpl)
// يقوم بجلب كافة بيانات المواعيد والمرضى والأطباء والأسعار والفواتير والروشتات
// من خلال استدعاء دالة RPC واحدة على السيرفر، مع دعم الـ Realtime والـ Fallback التلقائي
// ────────────────────────────────────────────────────────

import 'dart:async';
import 'package:injectable/injectable.dart';
import 'package:clinic_pro/core/constants/supabase_constants.dart';
import '../../../../core/services/i_cloud_service.dart';
import '../models/appointment_model.dart';
import 'i_appointment_remote_data_source.dart';
import '../../../prescription/data/models/drug_model.dart';

@LazySingleton(as: IAppointmentRemoteDataSource)
class AppointmentRpcRemoteDataSourceImpl implements IAppointmentRemoteDataSource {
  final ICloudService _cloud;

  AppointmentRpcRemoteDataSourceImpl(this._cloud);

  @override
  Future<List<AppointmentModel>> getAppointments({
    required String clinicId,
    String? doctorId,
    String? date,
    String? status,
  }) async {
    try {
      // 1. محاولة الجلب السريع جداً عبر دالة الـ RPC من السيرفر
      final response = await _cloud.rpc(
        'get_enriched_appointments_rpc',
        params: {
          'p_clinic_id': clinicId,
          'p_doctor_id': (doctorId != null && doctorId.isNotEmpty) ? doctorId : null,
          'p_date': (date != null && date.isNotEmpty) ? date : null,
          'p_status': (status != null && status.isNotEmpty) ? status : null,
        },
      );

      if (response is List) {
        return response
            .map((e) => AppointmentModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
    } catch (_) {
      // 2. في حالة حدوث أي استثناء أو عدم توفر الـ RPC على السيرفر، نلجأ للـ Fallback الآمن
      return await _fallbackGetAppointments(
        clinicId: clinicId,
        doctorId: doctorId,
        date: date,
        status: status,
      );
    }

    return [];
  }

  @override
  Future<AppointmentModel> getAppointmentById(String id) async {
    return await _getAppointmentDetails(id, detailed: true);
  }

  @override
  Future<AppointmentModel> getEnrichedAppointmentById(String id) async {
    return await _getAppointmentDetails(id, detailed: false);
  }

  Future<AppointmentModel> _getAppointmentDetails(String id, {required bool detailed}) async {
    try {
      // محاولة جلب الموعد بالكامل عبر الـ RPC
      final response = await _cloud.rpc(
        'get_enriched_appointments_rpc',
        params: {
          'p_clinic_id': null,
          'p_appointment_id': id,
        },
      );

      if (response is List && response.isNotEmpty) {
        return AppointmentModel.fromJson(Map<String, dynamic>.from(response.first as Map));
      }
    } catch (_) {}

    // Fallback: جلب الموعد بالطريقة التقليدية
    final appointments = await _cloud.select(
      table: SupabaseTables.appointments,
      eq: {'id': id},
    );

    if (appointments.isEmpty) {
      throw Exception('الموعد غير موجود');
    }

    final enriched = await _enrichSingleAppointmentFallback(appointments.first, detailed: detailed);
    return AppointmentModel.fromJson(enriched);
  }

  @override
  Future<AppointmentModel> insertAppointment(AppointmentModel appointment) async {
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
    final enriched = await _enrichSingleAppointmentFallback(result, detailed: false);
    return AppointmentModel.fromJson(enriched);
  }

  @override
  Future<AppointmentModel> updateAppointment(AppointmentModel appointment) async {
    final data = appointment.toJson();

    // جلب السعر الفعلي من نوع الزيارة عند التحديث
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
    final enriched = await _enrichSingleAppointmentFallback(results.first, detailed: false);
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
    // استخدام قناة Realtime لمراقبة جدول المواعيد
    return _cloud.subscribe(
      table: SupabaseTables.appointments,
      primaryKey: 'id',
      clinicId: clinicId,
    );
  }

  // ────────────────────────────────────────────────────────
  // دوال الـ Fallback الاحتياطية (تضمن عمل التطبيق بنسبة 100%)
  // ────────────────────────────────────────────────────────

  Future<List<AppointmentModel>> _fallbackGetAppointments({
    required String clinicId,
    String? doctorId,
    String? date,
    String? status,
  }) async {
    final Map<String, dynamic> eq = {'clinic_id': clinicId};
    if (doctorId != null && doctorId.isNotEmpty) eq['doctor_id'] = doctorId;
    if (date != null && date.isNotEmpty) eq['date'] = date;
    if (status != null && status.isNotEmpty) eq['status'] = status;

    Map<String, dynamic>? gte;
    if (date == null || date.isEmpty) {
      final defaultStartDate = DateTime.now()
          .subtract(const Duration(days: 30))
          .toIso8601String()
          .substring(0, 10);
      gte = {'date': defaultStartDate};
    }

    final appointments = await _cloud.select(
      table: SupabaseTables.appointments,
      eq: eq,
      gte: gte,
    );

    if (appointments.isEmpty) return [];

    final enrichedList = await _enrichBatchFallback(appointments);
    return enrichedList.map((e) => AppointmentModel.fromJson(e)).toList();
  }

  Future<List<Map<String, dynamic>>> _enrichBatchFallback(
    List<Map<String, dynamic>> rawList,
  ) async {
    if (rawList.isEmpty) return [];

    final patientIds = rawList.map((r) => r['patient_id'] as String?).whereType<String>().toSet();
    final doctorIds = rawList.map((r) => r['doctor_id'] as String?).whereType<String>().toSet();
    final typeIds = rawList.map((r) => r['type_id'] as String?).whereType<String>().toSet();

    final results = await Future.wait([
      Future.wait(patientIds.map((id) => _cloud.select(table: SupabaseTables.patients, eq: {'id': id}))),
      Future.wait(doctorIds.map((id) => _cloud.select(table: 'users', eq: {'id': id}))),
      Future.wait(typeIds.map((id) => _cloud.select(table: SupabaseTables.doctorAppointmentTypes, eq: {'id': id}))),
    ]);

    final List<List<Map<String, dynamic>>> patientsRes = results[0];
    final List<List<Map<String, dynamic>>> doctorsRes = results[1];
    final List<List<Map<String, dynamic>>> doctorTypesRes = results[2];

    final Map<String, Map<String, dynamic>> patientsMap = {};
    for (final res in patientsRes) {
      if (res.isNotEmpty && res.first['id'] != null) {
        patientsMap[res.first['id'] as String] = res.first;
      }
    }

    final Map<String, Map<String, dynamic>> doctorsMap = {};
    for (final res in doctorsRes) {
      if (res.isNotEmpty && res.first['id'] != null) {
        doctorsMap[res.first['id'] as String] = res.first;
      }
    }

    final Map<String, String> doctorTypeToApptTypeIdMap = {};
    final Set<String> mainTypeIds = {};
    for (final res in doctorTypesRes) {
      if (res.isNotEmpty && res.first['id'] != null && res.first['appointment_type_id'] != null) {
        final id = res.first['id'] as String;
        final apptTypeId = res.first['appointment_type_id'] as String;
        doctorTypeToApptTypeIdMap[id] = apptTypeId;
        mainTypeIds.add(apptTypeId);
      }
    }

    final mainTypesRes = await Future.wait(
      mainTypeIds.map((id) => _cloud.select(table: SupabaseTables.appointmentTypes, eq: {'id': id})),
    );

    final Map<String, Map<String, dynamic>> typesMap = {};
    for (final res in mainTypesRes) {
      if (res.isNotEmpty && res.first['id'] != null) {
        typesMap[res.first['id'] as String] = res.first;
      }
    }

    return rawList.map((raw) {
      final pId = raw['patient_id'] as String?;
      final dId = raw['doctor_id'] as String?;
      final tId = raw['type_id'] as String?;

      final patient = (pId != null ? patientsMap[pId] : null) ?? {'name': 'مريض غير معروف', 'phone': ''};
      final doctor = (dId != null ? doctorsMap[dId] : null) ?? {'name': 'طبيب غير معروف'};

      final mainTypeId = tId != null ? doctorTypeToApptTypeIdMap[tId] : null;
      final type = (mainTypeId != null ? typesMap[mainTypeId] : null) ?? {'name': 'كشف عادي'};

      return {
        ...raw,
        'patients': patient,
        'appointment_types': type,
        'users': doctor,
        'prescriptions': <Map<String, dynamic>>[],
        'invoices': <Map<String, dynamic>>[],
        'prescription_drugs': <Map<String, dynamic>>[],
      };
    }).toList();
  }

  Future<Map<String, dynamic>> _enrichSingleAppointmentFallback(
    Map<String, dynamic> raw, {
    required bool detailed,
  }) async {
    final patientId = raw['patient_id'];
    final typeId = raw['type_id'];
    final doctorId = raw['doctor_id'];
    final clinicId = raw['clinic_id'];

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

    String appointmentTypeId = '';
    if (doctorTypes.isNotEmpty) {
      appointmentTypeId = doctorTypes.first['appointment_type_id'] ?? '';
    }

    final types = await _cloud.select(
      table: SupabaseTables.appointmentTypes,
      eq: {'id': appointmentTypeId},
    );
    final type = types.isNotEmpty ? types.first : {'name': 'كشف عادي'};

    final users = await _cloud.select(
      table: 'users',
      eq: {'id': doctorId},
    );
    final doctor = users.isNotEmpty ? users.first : {'name': 'طبيب غير معروف'};

    List<Map<String, dynamic>> prescriptions = [];
    List<Map<String, dynamic>> invoices = [];
    List<Map<String, dynamic>> prescriptionDrugs = [];

    if (detailed) {
      prescriptions = await _cloud.select(
        table: SupabaseTables.prescriptions,
        eq: {'appointment_id': raw['id']},
      );

      invoices = await _cloud.select(
        table: SupabaseTables.invoices,
        eq: {'source_id': raw['id']},
      );

      if (prescriptions.isNotEmpty) {
        final pId = prescriptions.first['id'];
        final pItems = await _cloud.select(
          table: SupabaseTables.prescriptionItems,
          eq: {'prescription_id': pId},
        );

        final allDrugs = await _cloud.select(table: SupabaseTables.drugs);
        final drugsMap = {for (var d in allDrugs) d['id']: DrugModel.fromJson(d)};

        prescriptionDrugs = pItems.map((item) {
          final dModel = drugsMap[item['drug_id']];
          return {
            ...item,
            'drug': dModel != null
                ? {
                    'id': dModel.id,
                    'trade_name': dModel.tradeName ?? '',
                    'generic_name': dModel.genericName,
                    'category': dModel.category,
                  }
                : null,
          };
        }).toList();
      }
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

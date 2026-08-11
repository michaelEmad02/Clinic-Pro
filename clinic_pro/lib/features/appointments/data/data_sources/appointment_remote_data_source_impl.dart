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
    if (doctorId != null && doctorId.isNotEmpty) eq['doctor_id'] = doctorId;
    if (date != null && date.isNotEmpty) eq['date'] = date;
    if (status != null && status.isNotEmpty) eq['status'] = status;

    Map<String, dynamic>? gte;
    if (date == null || date.isEmpty) {
      final defaultStartDate = DateTime.now().subtract(const Duration(days: 30)).toIso8601String().substring(0, 10);
      gte = {'date': defaultStartDate};
    }

    final appointments = await _cloud.select(
      table: SupabaseTables.appointments,
      eq: eq,
      gte: gte,
    );

    if (appointments.isEmpty) return [];

    final enrichedList = await _enrichAppointmentsBatch(appointments);
    return enrichedList.map((e) => AppointmentModel.fromJson(e)).toList();
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

  /// إغناء مجموعة مواعيد دفعة واحدة (Batch/Parallel Queries) متوافق تماماً مع ICloudService
  Future<List<Map<String, dynamic>>> _enrichAppointmentsBatch(
    List<Map<String, dynamic>> rawList,
  ) async {
    if (rawList.isEmpty) return [];

    final patientIds = rawList.map((r) => r['patient_id'] as String?).whereType<String>().toSet();
    final doctorIds = rawList.map((r) => r['doctor_id'] as String?).whereType<String>().toSet();
    final typeIds = rawList.map((r) => r['type_id'] as String?).whereType<String>().toSet();

    final results = await Future.wait([
      // 1. جلب مرضى المواعيد بالتوازي
      Future.wait(patientIds.map((id) => _cloud.select(table: SupabaseTables.patients, eq: {'id': id}))),
      // 2. جلب أطباء المواعيد بالتوازي
      Future.wait(doctorIds.map((id) => _cloud.select(table: 'users', eq: {'id': id}))),
      // 3. جلب أنواع المواعيد للأطباء بالتوازي
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

    // ربط البيانات الجاهزة فوراً
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

  /// دالة مساعدة لإغناء بيانات موعد واحد خام التفصيلية
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
            'drugs': drugModel?.toJson(),
          });
        }
      }

      // جلب الفواتير المرتبطة بالزيارة إن وجدت
      invoices = await _cloud.select(
        table: SupabaseTables.invoices,
        eq: {'source_id': raw['id']},
      );

      for (final inv in invoices) {
        final creatorId = inv['created_by'];
        if (creatorId != null && (creatorId as String).isNotEmpty) {
          try {
            final userRes = await _cloud.select(
              table: SupabaseTables.users,
              eq: {'id': creatorId},
            );
            if (userRes.isNotEmpty) {
              inv['creator_name'] = userRes.first['name'] as String?;
            }
          } catch (_) {}
        }
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

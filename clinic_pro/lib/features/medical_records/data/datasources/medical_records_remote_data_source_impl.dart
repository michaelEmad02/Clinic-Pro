// ────────────────────────────────────────────────────────
// تطبيق مصدر البيانات السحابي للسجلات الطبية
// يتعامل مع Supabase Database و Supabase Storage
// ────────────────────────────────────────────────────────

import 'dart:io';
import 'package:injectable/injectable.dart';
import '../../../../core/constants/supabase_constants.dart';
import '../../../../core/services/i_cloud_service.dart';
import '../../../../core/services/storage/i_image_compression_service.dart';
import '../../../../core/services/storage/i_storage_service.dart';
import '../models/medical_record_model.dart';
import 'i_medical_records_remote_data_source.dart';

@LazySingleton(as: IMedicalRecordsRemoteDataSource)
class MedicalRecordsRemoteDataSourceImpl implements IMedicalRecordsRemoteDataSource {
  final ICloudService _cloudService;
  final IStorageService _storageService;
  final IImageCompressionService _imageCompressionService;

  MedicalRecordsRemoteDataSourceImpl(
    this._cloudService,
    this._storageService,
    this._imageCompressionService,
  );

  @override
  Future<List<MedicalRecordModel>> getMedicalRecords({
    required String patientId,
    String? type,
  }) async {
    final Map<String, dynamic> eqConditions = {
      'patient_id': patientId,
    };

    if (type != null && type.isNotEmpty) {
      eqConditions['type'] = type;
    }

    final data = await _cloudService.select(
      table: SupabaseTables.medicalRecords,
      eq: eqConditions,
      order: 'record_date',
      ascending: false,
    );

    if (data.isEmpty) return [];

    final enrichedData = await _enrichMedicalRecordsWithAppointments(data);
    return enrichedData.map((json) => MedicalRecordModel.fromJson(json)).toList();
  }

  @override
  Future<List<MedicalRecordModel>> getRecordsForAppointment({
    required String appointmentId,
  }) async {
    final data = await _cloudService.select(
      table: SupabaseTables.medicalRecords,
      eq: {'appointment_id': appointmentId},
      order: 'record_date',
      ascending: false,
    );

    if (data.isEmpty) return [];

    final enrichedData = await _enrichMedicalRecordsWithAppointments(data);
    return enrichedData.map((json) => MedicalRecordModel.fromJson(json)).toList();
  }

  /// إغناء بيانات الفحوصات الطبية ببيانات الموعد المرتبط (نوع الموعد وتاريخه) وكذلك الروشتة المرتبطة إن وُجدت
  Future<List<Map<String, dynamic>>> _enrichMedicalRecordsWithAppointments(
    List<Map<String, dynamic>> rawRecords,
  ) async {
    if (rawRecords.isEmpty) return rawRecords;

    final appointmentIds = rawRecords
        .map((r) => r['appointment_id'] as String?)
        .whereType<String>()
        .where((id) => id.trim().isNotEmpty)
        .toSet();

    if (appointmentIds.isEmpty) return rawRecords;

    try {
      // 1. جلب المواعيد المرتبطة بالتوازي
      final appointmentsRes = await Future.wait(
        appointmentIds.map((id) => _cloudService.select(
              table: SupabaseTables.appointments,
              eq: {'id': id},
            )),
      );

      final Map<String, Map<String, dynamic>> appointmentsMap = {};
      for (final res in appointmentsRes) {
        if (res.isNotEmpty && res.first['id'] != null) {
          appointmentsMap[res.first['id'] as String] = res.first;
        }
      }

      // 2. فحص ما إذا كانت هناك فحوصات مرتبطة بموعد ولكن ينقصها prescription_id
      final apptIdsNeedingPrescription = rawRecords
          .where((r) {
            final apptId = r['appointment_id'] as String?;
            final prescId = r['prescription_id'] as String?;
            return apptId != null &&
                apptId.trim().isNotEmpty &&
                (prescId == null || prescId.trim().isEmpty);
          })
          .map((r) => r['appointment_id'] as String)
          .toSet();

      final Map<String, String> apptToPrescriptionMap = {};
      if (apptIdsNeedingPrescription.isNotEmpty) {
        final prescriptionsRes = await Future.wait(
          apptIdsNeedingPrescription.map((id) => _cloudService.select(
                table: SupabaseTables.prescriptions,
                eq: {'appointment_id': id},
              )),
        );
        for (int i = 0; i < apptIdsNeedingPrescription.length; i++) {
          final res = prescriptionsRes[i];
          final id = apptIdsNeedingPrescription.elementAt(i);
          if (res.isNotEmpty && res.first['id'] != null) {
            apptToPrescriptionMap[id] = res.first['id'].toString();
          }
        }
      }

      // 3. استخراج معرّفات أنواع المواعيد type_id
      final typeIds = appointmentsMap.values
          .map((appt) => appt['type_id'] as String?)
          .whereType<String>()
          .where((tId) => tId.trim().isNotEmpty)
          .toSet();

      final Map<String, String> doctorTypeToApptTypeIdMap = {};
      final Set<String> mainTypeIds = {};
      final Set<String> directLookupIds = {};

      if (typeIds.isNotEmpty) {
        // البحث في جدول doctor_appointment_types
        final doctorTypesRes = await Future.wait(
          typeIds.map((id) => _cloudService.select(
                table: SupabaseTables.doctorAppointmentTypes,
                eq: {'id': id},
              )),
        );

        for (int i = 0; i < typeIds.length; i++) {
          final res = doctorTypesRes[i];
          final tId = typeIds.elementAt(i);
          if (res.isNotEmpty && res.first['appointment_type_id'] != null) {
            final apptTypeId = res.first['appointment_type_id'] as String;
            doctorTypeToApptTypeIdMap[tId] = apptTypeId;
            mainTypeIds.add(apptTypeId);
          } else {
            // في حال كان type_id يشير مباشرة إلى appointment_types
            directLookupIds.add(tId);
          }
        }

        // جلب الأسماء من جدول appointment_types
        final allMainTypeIds = {...mainTypeIds, ...directLookupIds};
        final mainTypesRes = await Future.wait(
          allMainTypeIds.map((id) => _cloudService.select(
                table: SupabaseTables.appointmentTypes,
                eq: {'id': id},
              )),
        );

        final Map<String, String> typeNamesMap = {};
        for (final res in mainTypesRes) {
          if (res.isNotEmpty && res.first['id'] != null && res.first['name'] != null) {
            typeNamesMap[res.first['id'] as String] = res.first['name'] as String;
          }
        }

        // بناء خريطة الموعد -> تفاصيل الموعد
        final Map<String, Map<String, String>> apptInfoMap = {};
        for (final entry in appointmentsMap.entries) {
          final apptId = entry.key;
          final appt = entry.value;
          final tId = appt['type_id'] as String?;
          final date = appt['date'] as String? ?? '';

          String typeName = 'كشف عادي';
          if (tId != null) {
            final mainId = doctorTypeToApptTypeIdMap[tId] ?? tId;
            if (typeNamesMap.containsKey(mainId) && typeNamesMap[mainId]!.isNotEmpty) {
              typeName = typeNamesMap[mainId]!;
            }
          }

          apptInfoMap[apptId] = {
            'type_name': typeName,
            'date': date,
          };
        }

        // دمج البيانات في قائمة السجلات مع تصحيح الروشتة وتحديثها في قاعدة البيانات
        return rawRecords.map((record) {
          final apptId = record['appointment_id'] as String?;
          final info = (apptId != null && apptInfoMap.containsKey(apptId))
              ? apptInfoMap[apptId]
              : null;

          String? prescId = record['prescription_id'] as String?;
          if ((prescId == null || prescId.trim().isEmpty) &&
              apptId != null &&
              apptToPrescriptionMap.containsKey(apptId)) {
            prescId = apptToPrescriptionMap[apptId];
            final recordId = record['id'] as String?;
            if (recordId != null && prescId != null) {
              _cloudService.update(
                table: SupabaseTables.medicalRecords,
                data: {'prescription_id': prescId},
                matchColumn: 'id',
                matchValue: recordId,
              ).catchError((_) => <Map<String, dynamic>>[]);
            }
          }

          return {
            ...record,
            if (prescId != null && prescId.isNotEmpty) 'prescription_id': prescId,
            if (info != null) 'appointment_type_name': info['type_name'],
            if (info != null) 'appointment_date': info['date'],
          };
        }).toList();
      } else {
        // في حال لم تكن هناك أنواع مواعيد، نقوم بدمج الروشتة وتصحيحها إن وُجدت
        return rawRecords.map((record) {
          final apptId = record['appointment_id'] as String?;
          String? prescId = record['prescription_id'] as String?;
          if ((prescId == null || prescId.trim().isEmpty) &&
              apptId != null &&
              apptToPrescriptionMap.containsKey(apptId)) {
            prescId = apptToPrescriptionMap[apptId];
            final recordId = record['id'] as String?;
            if (recordId != null && prescId != null) {
              _cloudService.update(
                table: SupabaseTables.medicalRecords,
                data: {'prescription_id': prescId},
                matchColumn: 'id',
                matchValue: recordId,
              ).catchError((_) => <Map<String, dynamic>>[]);
            }
          }

          return {
            ...record,
            if (prescId != null && prescId.isNotEmpty) 'prescription_id': prescId,
          };
        }).toList();
      }
    } catch (_) {
      // في حال حدوث أي استثناء، نعيد السجلات كما هي بدون تعطيل عرض الفحوصات
    }

    return rawRecords;
  }

  @override
  Future<MedicalRecordModel> uploadMedicalRecord({
    required String clinicId,
    required String patientId,
    String? doctorId,
    String? appointmentId,
    String? prescriptionId,
    required String type,
    required String title,
    required File imageFile,
    required String recordDate,
    String? notes,
  }) async {
    // 1. ضغط الصورة للحفاظ على وضوح المستندات مع تقليل الحجم
    final compressedFile = await _imageCompressionService.compressDocumentImage(
      imageFile: imageFile,
    );

    final bytes = await compressedFile.readAsBytes();

    // 2. إنشاء مسار فريد للملف في باكت التخزين السحابي
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final cleanTitle = title.replaceAll(RegExp(r'[^\w\s]+'), '').replaceAll(' ', '_');
    final storagePath = 'patients/$patientId/${type}_${timestamp}_$cleanTitle.jpg';

    // 3. رفع الملف إلى باكت attachments في Supabase Storage
    final fileUrl = await _storageService.uploadFile(
      bucket: SupabaseBucket.attachments,
      path: storagePath,
      fileBytes: bytes,
      contentType: 'image/jpeg',
    );

    // 4. حذف الملف المضغوط المؤقت من ذاكرة الجهاز لتوفير المساحة
    if (await compressedFile.exists()) {
      try {
        await compressedFile.delete();
      } catch (_) {}
    }

    // 5. التحقق من معرف الروشتة أو البحث عنها بواسطة معرف الموعد
    String? finalPrescriptionId =
        (prescriptionId != null && prescriptionId.trim().isNotEmpty)
            ? prescriptionId.trim()
            : null;

    if (finalPrescriptionId == null &&
        appointmentId != null &&
        appointmentId.trim().isNotEmpty) {
      try {
        final existingPrescriptions = await _cloudService.select(
          table: SupabaseTables.prescriptions,
          eq: {'appointment_id': appointmentId.trim()},
        );
        if (existingPrescriptions.isNotEmpty &&
            existingPrescriptions.first['id'] != null) {
          finalPrescriptionId = existingPrescriptions.first['id'].toString();
        }
      } catch (_) {}
    }

    // 6. حفظ بيانات الفحص في جدول medical_records
    final recordData = {
      'clinic_id': clinicId,
      'patient_id': patientId,
      if (doctorId != null && doctorId.trim().isNotEmpty) 'doctor_id': doctorId.trim(),
      if (appointmentId != null && appointmentId.trim().isNotEmpty)
        'appointment_id': appointmentId.trim(),
      if (finalPrescriptionId != null && finalPrescriptionId.trim().isNotEmpty)
        'prescription_id': finalPrescriptionId.trim(),
      'type': type,
      'title': title,
      'file_url': fileUrl,
      'storage_path': storagePath,
      'record_date': recordDate,
      if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
    };

    final response = await _cloudService.insert(
      table: SupabaseTables.medicalRecords,
      data: recordData,
    );

    return MedicalRecordModel.fromJson(response);
  }

  @override
  Future<void> deleteMedicalRecord({
    required String recordId,
    required String storagePath,
  }) async {
    // 1. حذف الملف من التخزين السحابي
    try {
      await _storageService.deleteFile(
        bucket: SupabaseBucket.attachments,
        path: storagePath,
      );
    } catch (_) {
      // الاستمرار في الحذف من قاعدة البيانات حتى لو تعذر حذف الملف
    }

    // 2. حذف السجل من جدول medical_records
    await _cloudService.delete(
      table: SupabaseTables.medicalRecords,
      matchColumn: 'id',
      matchValue: recordId,
    );
  }
}

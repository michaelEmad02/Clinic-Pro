// ────────────────────────────────────────────────────────
// مصدر البيانات للإعدادات (SettingsRemoteDataSource)
// ────────────────────────────────────────────────────────

import 'dart:typed_data';
import 'package:clinic_pro/features/settings/data/models/doctor_appointment_type_model.dart';
import 'package:clinic_pro/features/settings/data/models/doctor_schedule_model.dart';
import 'package:clinic_pro/features/settings/data/models/queue_rule_model.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/constants/supabase_constants.dart';
import '../../../../core/services/i_cloud_service.dart';
import '../../../../core/services/storage/i_storage_service.dart';
import '../../../clinics/data/models/clinic_model.dart';
import '../../../subscriptions/data/models/subscription_model.dart';

import '../../../../core/services/storage/i_image_compression_service.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

abstract class ISettingsRemoteDataSource {
  Future<void> updateProfile({
    required String userId,
    required String name,
    required String phone,
    String? address,
    String? specialty,
    String? imageUrl,
  });
  Future<String> uploadAvatar({
    required String userId,
    required Uint8List fileBytes,
  });
  Future<ClinicModel> getClinicInfo(String clinicId);
  Future<void> updateClinicInfo({
    required String clinicId,
    required String name,
    required String address,
    required String phone1,
    String? phone2,
    String? logoUrl,
  });
  Future<List<ClinicModel>> getAvailableClinics(String userId);
  Future<SubscriptionModel?> getSubscription(String ownerId);

  // ──── الطبيب (Doctor) فقط ────
  Future<QueueRuleModel?> getQueueRule({
    required String doctorId,
    required String clinicId,
  });
  Future<void> upsertQueueRule({
    required String doctorId,
    required String clinicId,
    required String queueSystem,
    required List<String> slots,
    required int cycleLength,
    int? avgVisitMinutes,
  });
  Future<List<DoctorScheduleModel>> getDoctorSchedules({
    required String doctorId,
    required String clinicId,
  });
  Future<void> upsertDoctorSchedule(List<DoctorScheduleModel> schedule);
  Future<List<DoctorAppointmentTypeModel>> getDoctorAppointmentTypes({
    required String doctorId,
    required String clinicId,
  });
  Future<void> upsertDoctorAppointmentType(
      DoctorAppointmentTypeModel typePrice);
  Future<void> syncDoctorAppointmentTypes({
    required String doctorId,
    required String clinicId,
    required List<DoctorAppointmentTypeModel> types,
  });
  Future<List<Map<String, dynamic>>> getGlobalAppointmentTypes();

  // ──── السكرتير (السكرتير) فقط ────
  Future<List<Map<String, dynamic>>> getSecretaryDoctors({
    required String secretaryId,
    required String clinicId,
  });
  Future<void> setSecretaryActiveDoctor({
    required String secretaryId,
    required String clinicId,
    required String doctorId,
  });
}

@LazySingleton(as: ISettingsRemoteDataSource)
class SettingsRemoteDataSource implements ISettingsRemoteDataSource {
  final ICloudService _cloudService;
  final IStorageService _storageService;
  final IImageCompressionService _imageCompressionService;

  SettingsRemoteDataSource(
    this._cloudService,
    this._storageService,
    this._imageCompressionService,
  );

  @override
  Future<void> updateProfile({
    required String userId,
    required String name,
    required String phone,
    String? address,
    String? specialty,
    String? imageUrl,
  }) async {
    final Map<String, dynamic> data = {
      'name': name,
      'phone': phone,
    };
    if (address != null) data['address'] = address;
    if (specialty != null) data['specialty'] = specialty;
    if (imageUrl != null) data['image_url'] = imageUrl;

    await _cloudService.update(
      table: SupabaseTables.users,
      data: data,
      matchColumn: 'id',
      matchValue: userId,
    );
    await _cloudService.update(
      table: SupabaseTables.owners,
      data: {
        'name': name,
        'phone': phone,
        'address': address,
      },
      matchColumn: 'id',
      matchValue: userId,
    );
  }

  @override
  Future<String> uploadAvatar({
    required String userId,
    required Uint8List fileBytes,
  }) async {
    final path = '$userId.jpg';

    Uint8List finalBytes = fileBytes;
    try {
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/raw_$userId.jpg');
      await tempFile.writeAsBytes(fileBytes);

      final compressedFile = await _imageCompressionService.compressImage(
        imageFile: tempFile,
        targetWidth: 250, // تصغير أبعاد الصورة الشخصية
        targetHeight: 250,
        quality: 75, // ضغط متوازن للجودة لتقليل الحجم
      );

      finalBytes = await compressedFile.readAsBytes();

      // تنظيف الملفات المؤقتة
      if (await tempFile.exists()) await tempFile.delete();
      if (await compressedFile.exists()) await compressedFile.delete();
    } catch (e) {
      // إذا فشلت عملية الضغط نرفع الـ bytes الأصلية
    }

    return await _storageService.uploadFile(
      bucket: SupabaseBucket.usersAvatar,
      path: path,
      fileBytes: finalBytes,
      contentType: 'image/jpeg',
    );
  }

  @override
  Future<ClinicModel> getClinicInfo(String clinicId) async {
    final results = await _cloudService.select(
      table: SupabaseTables.clinics,
      eq: {'id': clinicId},
    );
    if (results.isEmpty) {
      throw Exception('العيادة غير موجودة');
    }
    return ClinicModel.fromJson(results.first);
  }

  @override
  Future<void> updateClinicInfo({
    required String clinicId,
    required String name,
    required String address,
    required String phone1,
    String? phone2,
    String? logoUrl,
  }) async {
    final Map<String, dynamic> data = {
      'name': name,
      'address': address,
      'phone1': phone1,
    };
    if (phone2 != null) data['phone2'] = phone2;
    if (logoUrl != null) data['logo_url'] = logoUrl;

    await _cloudService.update(
      table: SupabaseTables.clinics,
      data: data,
      matchColumn: 'id',
      matchValue: clinicId,
    );
  }

  @override
  Future<List<ClinicModel>> getAvailableClinics(String userId) async {
    // 1. جلب العيادات المرتبط بها الموظف من جدول clinic_staff
    final staffClinics = await _cloudService.select(
      table: SupabaseTables.clinicStaff,
      eq: {'user_id': userId, 'is_active': true},
    );

    final List<ClinicModel> clinics = [];

    // 2. جلب تفاصيل كل عيادة
    for (final staffRow in staffClinics) {
      final clinicId = staffRow['clinic_id'] as String;
      try {
        final clinic = await getClinicInfo(clinicId);
        clinics.add(clinic);
      } catch (_) {
        // تجاهل العيادات غير الموجودة
      }
    }

    return clinics;
  }

  @override
  Future<SubscriptionModel?> getSubscription(String ownerId) async {
    final results = await _cloudService.select(
      table: SupabaseTables.subscriptions,
      eq: {'owner_id': ownerId},
    );
    if (results.isEmpty) {
      return null;
    }
    return SubscriptionModel.fromJson(results.first);
  }

  // ──── الطبيب (Doctor) فقط ────

  @override
  Future<QueueRuleModel?> getQueueRule({
    required String doctorId,
    required String clinicId,
  }) async {
    final results = await _cloudService.select(
      table: SupabaseTables.doctorQueueRules,
      eq: {'doctor_id': doctorId, 'clinic_id': clinicId},
    );
    if (results.isEmpty) {
      return null;
    }
    return QueueRuleModel.fromJson(results.first);
  }

  @override
  Future<void> upsertQueueRule({
    required String doctorId,
    required String clinicId,
    required String queueSystem,
    required List<String> slots,
    required int cycleLength,
    int? avgVisitMinutes,
  }) async {
    final rule = {
      'doctor_id': doctorId,
      'clinic_id': clinicId,
      'queue_system': queueSystem,
      'slots': slots,
      'cycle_length': cycleLength,
      'avg_visit_minutes': avgVisitMinutes,
      'is_active': true,
    };

    // التحقق من وجود قاعدة سابقة لعمل تعديل أو إدخال جديد
    final existing = await _cloudService.select(
      table: SupabaseTables.doctorQueueRules,
      eq: {'doctor_id': doctorId, 'clinic_id': clinicId},
    );

    if (existing.isNotEmpty) {
      await _cloudService.update(
        table: SupabaseTables.doctorQueueRules,
        data: rule,
        matchColumn: 'id',
        matchValue: existing.first['id'],
      );
    } else {
      await _cloudService.insert(
        table: SupabaseTables.doctorQueueRules,
        data: rule,
      );
    }
  }

  @override
  Future<List<DoctorScheduleModel>> getDoctorSchedules({
    required String doctorId,
    required String clinicId,
  }) async {
    final results = await _cloudService.select(
      table: SupabaseTables.doctorSchedules,
      eq: {'doctor_id': doctorId, 'clinic_id': clinicId},
    );
    return results.map((json) => DoctorScheduleModel.fromJson(json)).toList();
  }

  @override
  Future<void> upsertDoctorSchedule(List<DoctorScheduleModel> schedule) async {
    if (schedule.isEmpty) return;

    final doctorId = schedule.first.doctorId;
    final clinicId = schedule.first.clinicId;

    // 1. حذف كافة مواعيد هذا الطبيب لهذه العيادة لتنظيف السجلات القديمة والمحذوفة
    await _cloudService.delete(
      table: SupabaseTables.doctorSchedules,
      matchMap: {
        'doctor_id': doctorId,
        'clinic_id': clinicId,
      },
    );

    // 2. إدخال المواعيد الجديدة
    for (final ds in schedule) {
      await _cloudService.insert(
        table: SupabaseTables.doctorSchedules,
        data: ds.toJson(),
      );
    }
  }

  @override
  Future<List<DoctorAppointmentTypeModel>> getDoctorAppointmentTypes({
    required String doctorId,
    required String clinicId,
  }) async {
    final results = await _cloudService.select(
      table: SupabaseTables.doctorAppointmentTypes,
      eq: {'doctor_id': doctorId, 'clinic_id': clinicId},
    );

    final List<DoctorAppointmentTypeModel> types = [];

    for (final row in results) {
      final typeId = row['appointment_type_id'] as String;

      // جلب اسم نوع الزيارة من جدول الأنواع العام
      String? typeName;
      try {
        final typeResult = await _cloudService.select(
          table: SupabaseTables.appointmentTypes,
          eq: {'id': typeId},
        );
        if (typeResult.isNotEmpty) {
          typeName = typeResult.first['name'] as String?;
        }
      } catch (_) {}

      final Map<String, dynamic> merged = Map<String, dynamic>.from(row);
      merged['name'] = typeName;

      types.add(DoctorAppointmentTypeModel.fromJson(merged));
    }

    return types;
  }

  @override
  Future<void> upsertDoctorAppointmentType(
      DoctorAppointmentTypeModel typePrice) async {
    final Map<String, dynamic> data = typePrice.toJson();

    final existing = await _cloudService.select(
      table: SupabaseTables.doctorAppointmentTypes,
      eq: {
        'doctor_id': typePrice.doctorId,
        'clinic_id': typePrice.clinicId,
        'appointment_type_id': typePrice.appointmentTypeId,
      },
    );

    if (existing.isNotEmpty) {
      await _cloudService.update(
        table: SupabaseTables.doctorAppointmentTypes,
        data: data,
        matchColumn: 'id',
        matchValue: existing.first['id'],
      );
    } else {
      await _cloudService.insert(
        table: SupabaseTables.doctorAppointmentTypes,
        data: data,
      );
    }
  }

  // ──── السكرتير (Secretary) فقط ────

  @override
  Future<List<Map<String, dynamic>>> getSecretaryDoctors({
    required String secretaryId,
    required String clinicId,
  }) async {
    // 1. جلب علاقات السكرتيرة بالأطباء في هذه العيادة من جدول doctor_secretary_schedule
    final schedules = await _cloudService.select(
      table: SupabaseTables.doctorSecretaries,
      eq: {'secretary_id': secretaryId, 'clinic_id': clinicId},
    );

    final List<Map<String, dynamic>> results = [];

    // 2. جلب معلومات الأطباء المقترنين بالخطة
    for (final schedule in schedules) {
      final doctorId = schedule['doctor_id'] as String;
      try {
        final docResults = await _cloudService.select(
          table: SupabaseTables.users,
          eq: {'id': doctorId},
        );
        if (docResults.isNotEmpty) {
          results.add({
            'schedule_id': schedule['id'],
            'doctor_id': doctorId,
            'is_active': schedule['is_active'] as bool? ?? false,
            'name': docResults.first['name'] as String? ?? '',
            'specialty': docResults.first['specialty'] as String? ?? '',
            'avatar_url':
                docResults.first['image_url'] ?? docResults.first['avatar_url'],
          });
        }
      } catch (_) {}
    }

    return results;
  }

  @override
  Future<void> setSecretaryActiveDoctor({
    required String secretaryId,
    required String clinicId,
    required String doctorId,
  }) async {
    // 1. جلب كل العلاقات للسكرتيرة في هذه العيادة لتعديل الحقل النشط
    final schedules = await _cloudService.select(
      table: SupabaseTables.doctorSecretaries,
      eq: {'secretary_id': secretaryId, 'clinic_id': clinicId},
    );

    for (final schedule in schedules) {
      final currentDocId = schedule['doctor_id'] as String;
      final scheduleId = schedule['id'] as String;

      await _cloudService.update(
        table: SupabaseTables.doctorSecretaries,
        data: {'is_active': currentDocId == doctorId},
        matchColumn: 'id',
        matchValue: scheduleId,
      );
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getGlobalAppointmentTypes() async {
    return await _cloudService.select(
      table: SupabaseTables.appointmentTypes,
    );
  }

  @override
  Future<void> syncDoctorAppointmentTypes({
    required String doctorId,
    required String clinicId,
    required List<DoctorAppointmentTypeModel> types,
  }) async {
    // 1. حذف جميع التسعيرات الحالية لهذا الطبيب في هذه العيادة
    final existing = await _cloudService.select(
      table: SupabaseTables.doctorAppointmentTypes,
      eq: {'doctor_id': doctorId, 'clinic_id': clinicId},
    );
    for (final e in existing) {
      await _cloudService.delete(
        table: SupabaseTables.doctorAppointmentTypes,
        matchColumn: 'id',
        matchValue: e['id'],
      );
    }

    // 2. إدخال التسعيرات الجديدة
    for (final model in types) {
      await _cloudService.insert(
        table: SupabaseTables.doctorAppointmentTypes,
        data: model.toJson(),
      );
    }
  }
}

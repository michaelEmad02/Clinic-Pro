// ────────────────────────────────────────────────────────
// تنفيذ مستودع الإعدادات (SettingsRepositoryImpl)
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/constants/supabase_constants.dart';
import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/query_failure.dart';
import '../../../../core/services/i_cloud_service.dart';
import '../../../../core/strings/app_strings.dart';
import 'package:clinic_pro/features/settings/domain/repositories/i_settings_repository.dart';

@LazySingleton(as: ISettingsRepository)
class SettingsRepositoryImpl implements ISettingsRepository {
  final ICloudService _cloudService;

  SettingsRepositoryImpl(this._cloudService);

  @override
  Future<Either<Failure, Map<String, dynamic>>> getUserProfile(String userId) async {
    try {
      final results = await _cloudService.select(
        table: 'users',
        eq: {'id': userId},
      );
      // if (results.isEmpty) {
      //   return Left(QueryFailure.fromException(Exception(AppStrings.loadFailed)));
      // }
      return Right(results.first);
    } catch (e) {
      return Left(QueryFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getClinicInfo(String clinicId) async {
    try {
      final results = await _cloudService.select(
        table: SupabaseTables.clinics,
        eq: {'id': clinicId},
      );
      if (results.isEmpty) {
        return Left(QueryFailure.fromException(Exception(AppStrings.clinicNotFound)));
      }
      return Right(results.first);
    } catch (e) {
      return Left(QueryFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getAvailableClinics() async {
    try {
      final results = await _cloudService.select(table: SupabaseTables.clinics);
      return Right(results);
    } catch (e) {
      return Left(QueryFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getSubscription(String ownerId) async {
    try {
      final results = await _cloudService.select(
        table: 'subscriptions',
        eq: {'owner_id': ownerId},
      );
      if (results.isEmpty) {
        return const Right(<String, dynamic>{});
      }
      return Right(results.first);
    } catch (e) {
      return Left(QueryFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateProfile({
    required String userId,
    required String name,
    required String phone,
    String? specialty,
  }) async {
    try {
      final Map<String, dynamic> dataToUpdate = {
        'name': name,
        'phone': phone,
      };
      if (specialty != null) {
        dataToUpdate['specialty'] = specialty;
      }

      await _cloudService.update(
        table: 'users',
        data: dataToUpdate,
        matchColumn: 'id',
        matchValue: userId,
      );
      return const Right(unit);
    } catch (e) {
      return Left(QueryFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getSecretaryDoctors(String secretaryId, String clinicId) async {
    try {
      // 1. جلب علاقات الجدول
      final schedules = await _cloudService.select(
        table: 'doctor_secretary_schedule',
        eq: {'secretary_id': secretaryId, 'clinic_id': clinicId},
      );
      
      final results = <Map<String, dynamic>>[];
      
      // 2. جلب معلومات الأطباء المقترنين بالعلاقة
      for (final schedule in schedules) {
        final doctorId = schedule['doctor_id'] as String;
        final docResults = await _cloudService.select(
          table: 'users',
          eq: {'id': doctorId},
        );
        if (docResults.isNotEmpty) {
          results.add({
            'schedule_id': schedule['id'],
            'doctor_id': doctorId,
            'is_active': schedule['is_active'] as bool? ?? false,
            'name': docResults.first['name'],
            'specialty': docResults.first['specialty'] ?? AppStrings.doctorRoleLabel,
            'avatar_url': docResults.first['avatar_url'],
          });
        }
      }
      return Right(results);
    } catch (e) {
      return Left(QueryFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> setSecretaryActiveDoctor(String secretaryId, String clinicId, String doctorId) async {
    try {
      // 1. جلب كل العلاقات للسكرتيرة في العيادة لتعديل الحقل النشط
      final schedules = await _cloudService.select(
        table: 'doctor_secretary_schedule',
        eq: {'secretary_id': secretaryId, 'clinic_id': clinicId},
      );

      for (final schedule in schedules) {
        final currentDocId = schedule['doctor_id'] as String;
        final scheduleId = schedule['id'] as String;
        await _cloudService.update(
          table: 'doctor_secretary_schedule',
          data: {'is_active': currentDocId == doctorId},
          matchColumn: 'id',
          matchValue: scheduleId,
        );
      }
      return const Right(unit);
    } catch (e) {
      return Left(QueryFailure.fromException(e));
    }
  }
}

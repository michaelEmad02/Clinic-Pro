// ────────────────────────────────────────────────────────
// SettingsCubit — يدير بيانات صفحة الإعدادات عبر الـ UseCases
// ────────────────────────────────────────────────────────

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:clinic_pro/core/constants/app_constants.dart';
import '../../../../core/constants/staff_roles.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../../domain/usecases/get_clinic_info_usecase.dart';
import '../../domain/usecases/get_available_clinics_usecase.dart';
import '../../domain/usecases/get_subscription_usecase.dart';
import '../../domain/usecases/get_secretary_doctors_usecase.dart';
import '../../domain/usecases/set_active_doctor_usecase.dart';
import '../../domain/usecases/upload_avatar_usecase.dart';
import '../../../clinics/domain/entities/clinic_entity.dart';
import '../../../staff_and_invitations/domain/use_cases/fetch_all_staff_use_case.dart';
import '../../../staff_and_invitations/domain/entities/staff_entity.dart';
import '../../../plans_and_subscriptions/domain/entities/subscription_entity.dart';
import 'settings_state.dart';
import 'dart:io';
import '../../data/data_sources/i_settings_local_data_source.dart';

@injectable
class SettingsCubit extends Cubit<SettingsState> {
  final UpdateProfileUseCase _updateProfileUseCase;
  final GetClinicInfoUseCase _getClinicInfoUseCase;
  final GetAvailableClinicsUseCase _getAvailableClinicsUseCase;
  final GetSubscriptionUseCase _getSubscriptionUseCase;
  final GetSecretaryDoctorsUseCase _getSecretaryDoctorsUseCase;
  final SetActiveDoctorUseCase _setActiveDoctorUseCase;
  final UploadAvatarUseCase _uploadAvatarUseCase;
  final FetchAllStaffUseCase _fetchAllStaffUseCase;
  final ISettingsLocalDataSource _localDataSource;

  SettingsCubit(
    this._updateProfileUseCase,
    this._getClinicInfoUseCase,
    this._getAvailableClinicsUseCase,
    this._getSubscriptionUseCase,
    this._getSecretaryDoctorsUseCase,
    this._setActiveDoctorUseCase,
    this._uploadAvatarUseCase,
    this._fetchAllStaffUseCase,
    this._localDataSource,
  ) : super(const SettingsState());

  /// تحميل الإعدادات (العيادة، العيادات المتاحة، والاشتراك)
  Future<void> loadSettings(StaffRoles role, String userId) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      // 1. القراءة المبدئية من التخزين المحلي المشروطة بـ userId
      final localClinicId = await _localDataSource.getActiveClinicId(userId);
      final localDoctorId = await _localDataSource.getActiveDoctorId(userId);

      if (localClinicId != null && localClinicId.isNotEmpty) {
        AppConstants.activeClinicId = localClinicId;
      }
      if (localDoctorId != null && localDoctorId.isNotEmpty) {
        AppConstants.activeDoctorId = localDoctorId;
      }

      if (role == StaffRoles.doctor) {
        AppConstants.activeDoctorId = userId;
        await _localDataSource.saveActiveDoctorId(userId, userId);
      }

      // 2. جلب العيادات المتاحة للمستخدم من قاعدة البيانات
      final clinicsResult = await _getAvailableClinicsUseCase(userId);

      await clinicsResult.fold(
        (failure) async =>
            emit(state.copyWith(isLoading: false, error: failure.message)),
        (clinics) async {
          String activeClinicId = AppConstants.activeClinicId;
          bool isValidLocalClinic = clinics.any((c) => c.id == activeClinicId);

          // إذا كانت العيادة النشطة محلياً فارغة، أو غير موجودة في العيادات المتاحة: نأخذ أول عيادة متاحة ونحفظها محلياً
          if ((activeClinicId.isEmpty || !isValidLocalClinic) && clinics.isNotEmpty) {
            activeClinicId = clinics.first.id;
            AppConstants.activeClinicId = activeClinicId;
            await _localDataSource.saveActiveClinicId(userId, activeClinicId);
          }

          // جلب تفاصيل العيادة النشطة
          ClinicEntity? currentClinic;
          if (activeClinicId.isNotEmpty) {
            final clinicInfoResult = await _getClinicInfoUseCase(activeClinicId);
            clinicInfoResult.fold(
              (_) {},
              (clinic) => currentClinic = clinic,
            );
          }

          // جلب الاشتراك وطاقم العمل في حالة المالك
          SubscriptionEntity? sub;
          List<StaffEntity> ownerStaff = [];
          if (role == StaffRoles.owner) {
            final subResult = await _getSubscriptionUseCase(userId);
            subResult.fold((_) {}, (s) => sub = s);

            final staffResult = await _fetchAllStaffUseCase(userId);
            staffResult.fold((_) {}, (list) => ownerStaff = list);
          }

          emit(state.copyWith(
            isLoading: false,
            subscriptionEntity: sub,
            availableClinics: clinics,
            staffList: ownerStaff,
            clinicEntity: currentClinic ?? (clinics.isNotEmpty ? clinics.first : null),
          ));

          // للسكرتيرة: تحميل الأطباء والجدول النشط
          if (role == StaffRoles.secretary && activeClinicId.isNotEmpty) {
            await loadSecretaryDoctorsList(userId, activeClinicId);
          }
        },
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  /// تحميل الأطباء المقترنين بالسكرتيرة
  Future<void> loadSecretaryDoctorsList(
      String secretaryId, String clinicId) async {
    final doctorsResult = await _getSecretaryDoctorsUseCase(
      secretaryId: secretaryId,
      clinicId: clinicId,
    );

    await doctorsResult.fold(
      (failure) async => emit(state.copyWith(error: failure.message)),
      (doctors) async {
        final savedDoctorId = await _localDataSource.getActiveDoctorId(secretaryId);
        Map<String, dynamic> activeDoc = {};

        if (savedDoctorId != null && savedDoctorId.isNotEmpty) {
          activeDoc = doctors.firstWhere(
            (d) => d['doctor_id'] == savedDoctorId,
            orElse: () => {},
          );
        }

        if (activeDoc.isEmpty) {
          activeDoc = doctors.firstWhere(
            (d) => d['is_active'] == true,
            orElse: () => doctors.isNotEmpty ? doctors.first : <String, dynamic>{},
          );
        }

        final doctorId = activeDoc['doctor_id'] as String? ?? '';
        if (doctorId.isNotEmpty) {
          AppConstants.activeDoctorId = doctorId;
          await _localDataSource.saveActiveDoctorId(secretaryId, doctorId);
        }

        StaffEntity? currentDoctor;
        if (doctorId.isNotEmpty) {
          currentDoctor = StaffEntity(
            id: doctorId,
            clinicId: clinicId,
            userId: doctorId,
            name: activeDoc['name'] as String? ?? '',
            email: activeDoc['email'] as String? ?? '',
            phone: activeDoc['phone'] as String? ?? '',
            specialty: activeDoc['specialty'] as String?,
            avatarUrl: activeDoc['avatar_url'] as String?,
            role: StaffRoles.doctor,
            isActive: activeDoc['is_active'] as bool? ?? true,
            joinedAt: DateTime.now(),
          );
        }

        emit(state.copyWith(
          secretaryDoctors: doctors,
          doctorEntity: currentDoctor,
        ));
      },
    );
  }

  /// تحديث الملف الشخصي في المستودع
  Future<void> updateProfile({
    required String userId,
    required String name,
    required String phone,
    String? address,
    String? imagePath,
  }) async {
    emit(state.copyWith(isLoading: true, error: null));

    String? imageUrl;
    if (imagePath != null && imagePath.isNotEmpty) {
      try {
        final file = File(imagePath);
        if (await file.exists()) {
          final fileBytes = await file.readAsBytes();
          final uploadResult = await _uploadAvatarUseCase(
            userId: userId,
            fileBytes: fileBytes,
          );
          uploadResult.fold(
            (failure) => emit(state.copyWith(isLoading: false, error: failure.message)),
            (url) => imageUrl = url,
          );
        }
      } catch (e) {
        emit(state.copyWith(isLoading: false, error: e.toString()));
        return;
      }
    }

    if (state.error != null) return; // توقف في حال فشل رفع الصورة

    final result = await _updateProfileUseCase(
      userId: userId,
      name: name,
      phone: phone,
      address: address,
      imageUrl: imageUrl,
    );

    result.fold(
      (failure) =>
          emit(state.copyWith(isLoading: false, error: failure.message)),
      (_) {
        emit(state.copyWith(isLoading: false));
      },
    );
  }

  /// تغيير الطبيب النشط للسكرتيرة
  Future<void> changeActiveDoctor(
      String secretaryId, String clinicId, String doctorId) async {
    final result = await _setActiveDoctorUseCase(
      secretaryId: secretaryId,
      clinicId: clinicId,
      doctorId: doctorId,
    );

    await result.fold(
      (failure) async => emit(state.copyWith(error: failure.message)),
      (_) async {
        await _localDataSource.saveActiveDoctorId(secretaryId, doctorId);
        await loadSecretaryDoctorsList(secretaryId, clinicId);
      },
    );
  }

  /// تبديل العيادة النشطة
  Future<void> changeClinic(
      String userId, String clinicId, StaffRoles role) async {
    emit(state.copyWith(isLoading: true));
    final clinicResult = await _getClinicInfoUseCase(clinicId);

    await clinicResult.fold(
      (failure) async =>
          emit(state.copyWith(isLoading: false, error: failure.message)),
      (clinic) async {
        AppConstants.activeClinicId = clinicId; // تحديث العيادة النشطة عالمياً
        await _localDataSource.saveActiveClinicId(userId, clinicId);
        emit(state.copyWith(
          isLoading: false,
          clinicEntity: clinic,
        ));

        // إذا كانت سكرتيرة، أعد تحميل قائمة الأطباء التابعة للعيادة الجديدة
        if (role == StaffRoles.secretary) {
          await loadSecretaryDoctorsList(userId, clinicId);
        }
      },
    );
  }

  /// تسجيل الخروج
  void logout() {
    emit(state.copyWith(isLoading: false));
  }
}

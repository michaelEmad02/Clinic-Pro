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
import 'settings_state.dart';
import 'dart:io';

@injectable
class SettingsCubit extends Cubit<SettingsState> {
  final UpdateProfileUseCase _updateProfileUseCase;
  final GetClinicInfoUseCase _getClinicInfoUseCase;
  final GetAvailableClinicsUseCase _getAvailableClinicsUseCase;
  final GetSubscriptionUseCase _getSubscriptionUseCase;
  final GetSecretaryDoctorsUseCase _getSecretaryDoctorsUseCase;
  final SetActiveDoctorUseCase _setActiveDoctorUseCase;
  final UploadAvatarUseCase _uploadAvatarUseCase;

  SettingsCubit(
    this._updateProfileUseCase,
    this._getClinicInfoUseCase,
    this._getAvailableClinicsUseCase,
    this._getSubscriptionUseCase,
    this._getSecretaryDoctorsUseCase,
    this._setActiveDoctorUseCase,
    this._uploadAvatarUseCase,
  ) : super(const SettingsState());

  String _getClinicId(StaffRoles role) {
    return AppConstants.activeClinicId;
  }

  /// تحميل الإعدادات (العيادة، العيادات المتاحة، والاشتراك)
  Future<void> loadSettings(StaffRoles role, String userId) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      if (role == StaffRoles.owner) {
        // إذا كان مالكاً: جلب الاشتراك + العيادات المتاحة (للتبديل كطبيب)
        final subResult = await _getSubscriptionUseCase(userId);
        final clinicsResult = await _getAvailableClinicsUseCase(userId);

        subResult.fold(
          (failure) => emit(state.copyWith(isLoading: false, error: failure.message)),
          (sub) {
            clinicsResult.fold(
              (failure) => emit(state.copyWith(
                isLoading: false,
                subscriptionEntity: sub,
                error: failure.message,
              )),
              (clinics) {
                emit(state.copyWith(
                  isLoading: false,
                  subscriptionEntity: sub,
                  availableClinics: clinics,
                  // تعيين أول عيادة كعيادة نشطة إن لم تكن موجودة
                  clinicEntity: clinics.isNotEmpty ? clinics.first : null,
                ));
              },
            );
          },
        );
      } else {
        // إذا لم يكن مالكاً (طبيب أو سكرتيرة): يتم جلب العيادة والعيادات المتاحة
        final clinicsResult = await _getAvailableClinicsUseCase(userId);

        await clinicsResult.fold(
          (failure) async => emit(state.copyWith(isLoading: false, error: failure.message)),
          (clinics) async {
            String activeClinicId = _getClinicId(role);
            
            // إذا كان معرف العيادة فارغاً، نستخدم أول عيادة متاحة ونقوم بتحديث الثابت العام
            if (activeClinicId.isEmpty && clinics.isNotEmpty) {
              activeClinicId = clinics.first.id;
              AppConstants.activeClinicId = activeClinicId;
            }

            final clinicResult = await _getClinicInfoUseCase(activeClinicId);
            
            clinicResult.fold(
              (failure) => emit(state.copyWith(
                isLoading: false,
                availableClinics: clinics,
                error: failure.message,
              )),
              (clinic) {
                emit(state.copyWith(
                  isLoading: false,
                  clinicEntity: clinic,
                  availableClinics: clinics,
                ));
              },
            );

            // للسكرتيرة: تحميل الأطباء والجدول النشط
            if (role == StaffRoles.secretary && activeClinicId.isNotEmpty) {
              await loadSecretaryDoctorsList(userId, activeClinicId);
            }
          },
        );
      }
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

    doctorsResult.fold(
      (failure) => emit(state.copyWith(error: failure.message)),
      (doctors) {
        final activeDoc = doctors.firstWhere(
          (d) => d['is_active'] == true,
          orElse: () => <String, dynamic>{},
        );
        final doctorId = activeDoc['doctor_id'] as String? ?? '';
        AppConstants.activeDoctorId = doctorId;

        emit(state.copyWith(
          secretaryDoctors: doctors,
          currentDoctorId: doctorId.isNotEmpty ? doctorId : null,
          currentDoctorName: activeDoc['name'] as String?,
          currentDoctorSpecialty: activeDoc['specialty'] as String?,
          currentDoctorAvatar: activeDoc['avatar_url'] as String?,
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

    result.fold(
      (failure) => emit(state.copyWith(error: failure.message)),
      (_) async {
        await loadSecretaryDoctorsList(secretaryId, clinicId);
      },
    );
  }

  /// تبديل العيادة النشطة
  Future<void> changeClinic(
      String userId, String clinicId, StaffRoles role) async {
    emit(state.copyWith(isLoading: true));
    final clinicResult = await _getClinicInfoUseCase(clinicId);

    clinicResult.fold(
      (failure) =>
          emit(state.copyWith(isLoading: false, error: failure.message)),
      (clinic) async {
        AppConstants.activeClinicId = clinicId; // تحديث العيادة النشطة عالمياً
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

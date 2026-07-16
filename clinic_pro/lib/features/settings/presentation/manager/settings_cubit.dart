// ────────────────────────────────────────────────────────
// SettingsCubit — يدير بيانات صفحة الإعدادات عبر الـ Repository
// ────────────────────────────────────────────────────────

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:clinic_pro/core/constants/app_constants.dart';
import '../../../../core/constants/staff_roles.dart';
import '../../../../core/strings/app_strings.dart';
import '../../domain/repositories/i_settings_repository.dart';
import 'settings_state.dart';

@injectable
class SettingsCubit extends Cubit<SettingsState> {
  final ISettingsRepository _repository;

  SettingsCubit(this._repository) : super(const SettingsState());

  String _getUserId(StaffRoles role) {
    switch (role) {
      case StaffRoles.owner:
        return 'u-owner-1';
      case StaffRoles.secretary:
        return 'u-sec-1';
      case StaffRoles.doctor:
      default:
        return 'u-doc-1';
    }
  }

  String _getClinicId(StaffRoles role) {
    return AppConstants.activeClinicId;
  }

  String _getRoleLabel(StaffRoles role) {
    switch (role) {
      case StaffRoles.owner:
        return AppStrings.ownerRoleLabel;
      case StaffRoles.secretary:
        return AppStrings.secretaryRoleLabel;
      case StaffRoles.doctor:
      default:
        return AppStrings.generalDoctor;
    }
  }

  /// تحميل الإعدادات من المستودع حسب دور المستخدم
  Future<void> loadSettings(StaffRoles role) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final userId = _getUserId(role);
      final clinicId = _getClinicId(role);

      // 1. جلب الملف الشخصي
      final userResult = await _repository.getUserProfile(userId);
      // 2. جلب العيادة الحالية
      final clinicResult = await _repository.getClinicInfo(clinicId);
      // 3. جلب العيادات المتاحة
      final clinicsResult = await _repository.getAvailableClinics();
      // 4. جلب الاشتراك (للمالك)
      final subResult = role == StaffRoles.owner
          ? await _repository.getSubscription(userId)
          : null;

      userResult.fold(
        (failure) => emit(state.copyWith(isLoading: false, error: failure.message)),
        (user) {
          clinicResult.fold(
            (failure) => emit(state.copyWith(isLoading: false, error: failure.message)),
            (clinic) {
              clinicsResult.fold(
                (failure) => emit(state.copyWith(isLoading: false, error: failure.message)),
                (clinics) async {
                  SettingsState updatedState = state.copyWith(
                    isLoading: false,
                    userId: user['id'] as String,
                    userName: user['name'] as String,
                    userEmail: user['email'] as String,
                    userRole: _getRoleLabel(role),
                    userPhone: user['phone'] as String,
                    userAvatarUrl: user['avatar_url'] as String?,
                    userSpecialty: user['specialty'] as String?,
                    clinicId: clinic['id'] as String,
                    clinicName: clinic['name'] as String,
                    clinicAddress: clinic['address'] as String,
                    clinicPhone: (clinic['phone'] ?? clinic['phone1'] ?? '') as String,
                    clinicLogoUrl: clinic['logo_url'] as String?,
                    availableClinics: clinics,
                  );

                  if (subResult != null) {
                    subResult.fold(
                      (_) {},
                      (sub) {
                        updatedState = updatedState.copyWith(
                          planType: sub['plan_type'] as String? ?? '',
                          planStatus: sub['status'] as String? ?? '',
                          trialEndAt: sub['trial_end_at'] as String?,
                          currentPeriodEnd: sub['current_period_end'] as String?,
                        );
                      },
                    );
                  }

                  emit(updatedState);

                  // للسكرتيرة: تحميل الأطباء والجدول النشط
                  if (role == StaffRoles.secretary) {
                    await loadSecretaryDoctorsList();
                  }
                },
              );
            },
          );
        },
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  /// تحميل الأطباء المقترنين بالسكرتيرة
  Future<void> loadSecretaryDoctorsList() async {
    if (state.userId.isEmpty || state.clinicId.isEmpty) return;
    
    final doctorsResult = await _repository.getSecretaryDoctors(state.userId, state.clinicId);
    doctorsResult.fold(
      (failure) => emit(state.copyWith(error: failure.message)),
      (doctors) {
        final activeDoc = doctors.firstWhere(
          (d) => d['is_active'] == true,
          orElse: () => <String, dynamic>{},
        );
        emit(state.copyWith(
          secretaryDoctors: doctors,
          currentDoctorId: activeDoc['doctor_id'] as String?,
          currentDoctorName: activeDoc['name'] as String?,
          currentDoctorSpecialty: activeDoc['specialty'] as String?,
          currentDoctorAvatar: activeDoc['avatar_url'] as String?,
        ));
      },
    );
  }

  /// تحديث الملف الشخصي في المستودع
  Future<void> updateProfile({required String name, required String phone}) async {
    if (state.userId.isEmpty) return;
    emit(state.copyWith(isLoading: true));

    final result = await _repository.updateProfile(
      userId: state.userId,
      name: name,
      phone: phone,
    );

    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, error: failure.message)),
      (_) {
        emit(state.copyWith(
          isLoading: false,
          userName: name,
          userPhone: phone,
        ));
      },
    );
  }

  /// تغيير الطبيب النشط للسكرتيرة
  Future<void> changeActiveDoctor(String doctorId) async {
    if (state.userId.isEmpty || state.clinicId.isEmpty) return;

    final result = await _repository.setSecretaryActiveDoctor(
      state.userId,
      state.clinicId,
      doctorId,
    );

    result.fold(
      (failure) => emit(state.copyWith(error: failure.message)),
      (_) async {
        await loadSecretaryDoctorsList();
      },
    );
  }

  /// تبديل العيادة النشطة
  Future<void> changeClinic(String clinicId) async {
    emit(state.copyWith(isLoading: true));
    final clinicResult = await _repository.getClinicInfo(clinicId);

    clinicResult.fold(
      (failure) => emit(state.copyWith(isLoading: false, error: failure.message)),
      (clinic) async {
        AppConstants.activeClinicId = clinicId; // تحديث العيادة النشطة عالمياً
        emit(state.copyWith(
          isLoading: false,
          clinicId: clinic['id'] as String,
          clinicName: clinic['name'] as String,
          clinicAddress: clinic['address'] as String,
          clinicPhone: clinic['phone'] as String,
          clinicLogoUrl: clinic['logo_url'] as String?,
        ));

        // إذا كانت سكرتيرة، أعد تحميل قائمة الأطباء التابعة للعيادة الجديدة
        if (state.userRole == AppStrings.secretaryRoleLabel) {
          await loadSecretaryDoctorsList();
        }
      },
    );
  }

  /// تسجيل الخروج
  void logout() {
    emit(state.copyWith(isLoading: false));
  }
}

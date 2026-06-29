// ────────────────────────────────────────────────────────
// SettingsCubit — يدير بيانات صفحة الإعدادات
// يحمل بيانات المستخدم والعيادة والاشتراك من MockData
// ────────────────────────────────────────────────────────

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/staff_roles.dart';
import '../../../../core/mocks/mock_data.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(const SettingsState());

  String _getUserId(StaffRoles role) {
    switch (role) {
      case StaffRoles.owner: return 'u-owner-1';
      case StaffRoles.secretary: return 'u-sec-1';
      case StaffRoles.doctor: default: return 'u-doc-1';
    }
  }

  String _getClinicId(StaffRoles role) {
    return 'c-1'; // جميع الأدوار في العيادة الأولى حالياً
  }

  String _getRoleLabel(StaffRoles role) {
    switch (role) {
      case StaffRoles.owner: return 'صاحب عيادة';
      case StaffRoles.secretary: return 'سكرتيرة';
      case StaffRoles.doctor: default: return 'طبيب عام';
    }
  }

  /// تحميل البيانات من MockData حسب الدور
  void loadSettings(StaffRoles role) {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final userId = _getUserId(role);
      final clinicId = _getClinicId(role);

      // المستخدم
      final user = MockData.users.firstWhere((u) => u['id'] == userId);
      // العيادة الحالية
      final clinic = MockData.clinics.firstWhere((c) => c['id'] == clinicId);
      // قائمة العيادات
      final clinics = List<Map<String, dynamic>>.from(MockData.clinics);
      // الاشتراك
      final subscription = MockData.subscriptions.isNotEmpty
          ? MockData.subscriptions.first
          : <String, dynamic>{};

      emit(state.copyWith(
        isLoading: false,
        userId: user['id'] as String,
        userName: user['name'] as String,
        userEmail: user['email'] as String,
        userRole: _getRoleLabel(role),
        userPhone: user['phone'] as String,
        userAvatarUrl: user['avatar_url'] as String?,
        clinicId: clinic['id'] as String,
        clinicName: clinic['name'] as String,
        clinicAddress: clinic['address'] as String,
        clinicPhone: clinic['phone'] as String,
        clinicLogoUrl: clinic['logo_url'] as String?,
        availableClinics: clinics,
        planType: subscription['plan_type'] as String? ?? '',
        planStatus: subscription['status'] as String? ?? '',
        trialEndAt: subscription['trial_end_at'] as String?,
        currentPeriodEnd: subscription['current_period_end'] as String?,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  /// تحديث الملف الشخصي
  void updateProfile({required String name, required String phone}) {
    final userIndex = MockData.users.indexWhere((u) => u['id'] == state.userId);
    if (userIndex == -1) return;

    MockData.users[userIndex] = {
      ...MockData.users[userIndex],
      'name': name,
      'phone': phone,
    };

    emit(state.copyWith(userName: name, userPhone: phone));
  }

  /// تبديل العيادة النشطة
  void changeClinic(String clinicId) {
    final clinic = MockData.clinics.firstWhere(
      (c) => c['id'] == clinicId,
      orElse: () => <String, dynamic>{},
    );
    if (clinic.isEmpty) return;

    emit(state.copyWith(
      clinicId: clinic['id'] as String,
      clinicName: clinic['name'] as String,
      clinicAddress: clinic['address'] as String,
      clinicPhone: clinic['phone'] as String,
      clinicLogoUrl: clinic['logo_url'] as String?,
    ));
  }

  /// تسجيل الخروج
  void logout() {
    // محاكاة تسجيل خروج (في التطبيق الحقيقي يتم مسح التوكن)
    emit(state.copyWith(isLoading: false));
  }
}

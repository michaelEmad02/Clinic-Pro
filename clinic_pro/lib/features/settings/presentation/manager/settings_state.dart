// ────────────────────────────────────────────────────────
// SettingsState — حالة صفحة الإعدادات
// تحتوي على بيانات المستخدم والعيادة والاشتراك والطبيب النشط للسكرتيرة
// ────────────────────────────────────────────────────────

import 'package:equatable/equatable.dart';
import '../../../auth/domain/entities/auth_user_entity.dart';
import '../../../clinics/domain/entities/clinic_entity.dart';
import '../../../subscriptions/domain/entities/subscription_entity.dart';

class SettingsState extends Equatable {
  final bool isLoading;
  final String? error;

  // الكيانات المكتوبة للبيانات الأساسية
  final AuthUserEntity? userEntity;
  final ClinicEntity? clinicEntity;
  final SubscriptionEntity? subscriptionEntity;

  // قائمة العيادات المتاحة
  final List<ClinicEntity> availableClinics;

  // قائمة الأطباء للسكرتيرة
  final List<Map<String, dynamic>> secretaryDoctors;

  // بيانات الطبيب الحالي المحدد للسكرتيرة
  final String? currentDoctorId;
  final String? currentDoctorName;
  final String? currentDoctorSpecialty;
  final String? currentDoctorAvatar;

  const SettingsState({
    this.isLoading = false,
    this.error,
    this.userEntity,
    this.clinicEntity,
    this.subscriptionEntity,
    this.availableClinics = const [],
    this.secretaryDoctors = const [],
    this.currentDoctorId,
    this.currentDoctorName,
    this.currentDoctorSpecialty,
    this.currentDoctorAvatar,
  });

  SettingsState copyWith({
    bool? isLoading,
    String? error,
    AuthUserEntity? userEntity,
    ClinicEntity? clinicEntity,
    SubscriptionEntity? subscriptionEntity,
    List<ClinicEntity>? availableClinics,
    List<Map<String, dynamic>>? secretaryDoctors,
    String? currentDoctorId,
    String? currentDoctorName,
    String? currentDoctorSpecialty,
    String? currentDoctorAvatar,
  }) {
    return SettingsState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      userEntity: userEntity ?? this.userEntity,
      clinicEntity: clinicEntity ?? this.clinicEntity,
      subscriptionEntity: subscriptionEntity ?? this.subscriptionEntity,
      availableClinics: availableClinics ?? this.availableClinics,
      secretaryDoctors: secretaryDoctors ?? this.secretaryDoctors,
      currentDoctorId: currentDoctorId ?? this.currentDoctorId,
      currentDoctorName: currentDoctorName ?? this.currentDoctorName,
      currentDoctorSpecialty: currentDoctorSpecialty ?? this.currentDoctorSpecialty,
      currentDoctorAvatar: currentDoctorAvatar ?? this.currentDoctorAvatar,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        error,
        userEntity,
        clinicEntity,
        subscriptionEntity,
        availableClinics,
        secretaryDoctors,
        currentDoctorId,
        currentDoctorName,
        currentDoctorSpecialty,
        currentDoctorAvatar,
      ];
}

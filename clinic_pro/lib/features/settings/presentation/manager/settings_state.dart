// ────────────────────────────────────────────────────────
// SettingsState — حالة صفحة الإعدادات
// تحتوي على بيانات المستخدم والعيادة والاشتراك والطبيب النشط للسكرتيرة
// ────────────────────────────────────────────────────────

import 'package:equatable/equatable.dart';

class SettingsState extends Equatable {
  final bool isLoading;
  final String? error;

  // بيانات المستخدم
  final String userId;
  final String userName;
  final String userEmail;
  final String userRole;
  final String userPhone;
  final String? userAvatarUrl;
  final String? userSpecialty;

  // بيانات العيادة الحالية
  final String clinicId;
  final String clinicName;
  final String clinicAddress;
  final String clinicPhone;
  final String? clinicLogoUrl;

  // قائمة العيادات المتاحة
  final List<Map<String, dynamic>> availableClinics;

  // قائمة الأطباء للسكرتيرة
  final List<Map<String, dynamic>> secretaryDoctors;

  // بيانات الطبيب الحالي المحدد للسكرتيرة
  final String? currentDoctorId;
  final String? currentDoctorName;
  final String? currentDoctorSpecialty;
  final String? currentDoctorAvatar;

  // بيانات الاشتراك (للمالك)
  final String planType;
  final String planStatus;
  final String? trialEndAt;
  final String? currentPeriodEnd;

  const SettingsState({
    this.isLoading = false,
    this.error,
    this.userId = '',
    this.userName = '',
    this.userEmail = '',
    this.userRole = '',
    this.userPhone = '',
    this.userAvatarUrl,
    this.userSpecialty,
    this.clinicId = '',
    this.clinicName = '',
    this.clinicAddress = '',
    this.clinicPhone = '',
    this.clinicLogoUrl,
    this.availableClinics = const [],
    this.secretaryDoctors = const [],
    this.currentDoctorId,
    this.currentDoctorName,
    this.currentDoctorSpecialty,
    this.currentDoctorAvatar,
    this.planType = '',
    this.planStatus = '',
    this.trialEndAt,
    this.currentPeriodEnd,
  });

  SettingsState copyWith({
    bool? isLoading,
    String? error,
    String? userId,
    String? userName,
    String? userEmail,
    String? userRole,
    String? userPhone,
    String? userAvatarUrl,
    String? userSpecialty,
    String? clinicId,
    String? clinicName,
    String? clinicAddress,
    String? clinicPhone,
    String? clinicLogoUrl,
    List<Map<String, dynamic>>? availableClinics,
    List<Map<String, dynamic>>? secretaryDoctors,
    String? currentDoctorId,
    String? currentDoctorName,
    String? currentDoctorSpecialty,
    String? currentDoctorAvatar,
    String? planType,
    String? planStatus,
    String? trialEndAt,
    String? currentPeriodEnd,
  }) {
    return SettingsState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      userRole: userRole ?? this.userRole,
      userPhone: userPhone ?? this.userPhone,
      userAvatarUrl: userAvatarUrl ?? this.userAvatarUrl,
      userSpecialty: userSpecialty ?? this.userSpecialty,
      clinicId: clinicId ?? this.clinicId,
      clinicName: clinicName ?? this.clinicName,
      clinicAddress: clinicAddress ?? this.clinicAddress,
      clinicPhone: clinicPhone ?? this.clinicPhone,
      clinicLogoUrl: clinicLogoUrl ?? this.clinicLogoUrl,
      availableClinics: availableClinics ?? this.availableClinics,
      secretaryDoctors: secretaryDoctors ?? this.secretaryDoctors,
      currentDoctorId: currentDoctorId ?? this.currentDoctorId,
      currentDoctorName: currentDoctorName ?? this.currentDoctorName,
      currentDoctorSpecialty: currentDoctorSpecialty ?? this.currentDoctorSpecialty,
      currentDoctorAvatar: currentDoctorAvatar ?? this.currentDoctorAvatar,
      planType: planType ?? this.planType,
      planStatus: planStatus ?? this.planStatus,
      trialEndAt: trialEndAt ?? this.trialEndAt,
      currentPeriodEnd: currentPeriodEnd ?? this.currentPeriodEnd,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        error,
        userId,
        userName,
        userEmail,
        userRole,
        userPhone,
        userAvatarUrl,
        userSpecialty,
        clinicId,
        clinicName,
        clinicAddress,
        clinicPhone,
        clinicLogoUrl,
        availableClinics,
        secretaryDoctors,
        currentDoctorId,
        currentDoctorName,
        currentDoctorSpecialty,
        currentDoctorAvatar,
        planType,
        planStatus,
        trialEndAt,
        currentPeriodEnd,
      ];
}

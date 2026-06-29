// ────────────────────────────────────────────────────────
// SettingsState — حالة صفحة الإعدادات
// تحتوي على بيانات المستخدم والعيادة والاشتراك المستخرجة من MockData
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

  // بيانات العيادة الحالية
  final String clinicId;
  final String clinicName;
  final String clinicAddress;
  final String clinicPhone;
  final String? clinicLogoUrl;

  // قائمة العيادات المتاحة (للمُنتقى)
  final List<Map<String, dynamic>> availableClinics;

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
    this.clinicId = '',
    this.clinicName = '',
    this.clinicAddress = '',
    this.clinicPhone = '',
    this.clinicLogoUrl,
    this.availableClinics = const [],
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
    String? clinicId,
    String? clinicName,
    String? clinicAddress,
    String? clinicPhone,
    String? clinicLogoUrl,
    List<Map<String, dynamic>>? availableClinics,
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
      clinicId: clinicId ?? this.clinicId,
      clinicName: clinicName ?? this.clinicName,
      clinicAddress: clinicAddress ?? this.clinicAddress,
      clinicPhone: clinicPhone ?? this.clinicPhone,
      clinicLogoUrl: clinicLogoUrl ?? this.clinicLogoUrl,
      availableClinics: availableClinics ?? this.availableClinics,
      planType: planType ?? this.planType,
      planStatus: planStatus ?? this.planStatus,
      trialEndAt: trialEndAt ?? this.trialEndAt,
      currentPeriodEnd: currentPeriodEnd ?? this.currentPeriodEnd,
    );
  }

  @override
  List<Object?> get props => [
    isLoading, error,
    userId, userName, userEmail, userRole, userPhone, userAvatarUrl,
    clinicId, clinicName, clinicAddress, clinicPhone, clinicLogoUrl,
    availableClinics,
    planType, planStatus, trialEndAt, currentPeriodEnd,
  ];
}

// ────────────────────────────────────────────────────────
// SettingsState — حالة صفحة الإعدادات
// تحتوي على بيانات المستخدم والعيادة والاشتراك والطبيب النشط للسكرتيرة
// ────────────────────────────────────────────────────────

import 'package:equatable/equatable.dart';
import '../../../auth/domain/entities/auth_user_entity.dart';
import '../../../clinics/domain/entities/clinic_entity.dart';
import '../../../staff_and_invitations/domain/entities/staff_entity.dart';
import '../../../plans_and_subscriptions/domain/entities/subscription_entity.dart';

class SettingsState extends Equatable {
  final bool isLoading;
  final String? error;

  // الكيانات المكتوبة للبيانات الأساسية
  final AuthUserEntity? userEntity;
  final ClinicEntity? clinicEntity;
  final SubscriptionEntity? subscriptionEntity;
  final StaffEntity? doctorEntity;

  // قائمة العيادات المتاحة
  final List<ClinicEntity> availableClinics;

  // قائمة أطقم العيادة الحالية للمالك
  final List<StaffEntity> staffList;

  // قائمة الأطباء للسكرتيرة
  final List<Map<String, dynamic>> secretaryDoctors;

  const SettingsState({
    this.isLoading = false,
    this.error,
    this.userEntity,
    this.clinicEntity,
    this.subscriptionEntity,
    this.doctorEntity,
    this.availableClinics = const [],
    this.staffList = const [],
    this.secretaryDoctors = const [],
  });

  // Getters مساعدة للتوافق التام
  StaffEntity? get doctor => doctorEntity;
  String? get currentDoctorId =>
      (doctor?.userId.isNotEmpty == true) ? doctor!.userId : doctor?.id;
  String? get currentDoctorName => doctor?.name;
  String? get currentDoctorSpecialty => doctor?.specialty;
  String? get currentDoctorAvatar => doctor?.avatarUrl;

  SettingsState copyWith({
    bool? isLoading,
    String? error,
    AuthUserEntity? userEntity,
    ClinicEntity? clinicEntity,
    SubscriptionEntity? subscriptionEntity,
    StaffEntity? doctorEntity,
    List<ClinicEntity>? availableClinics,
    List<StaffEntity>? staffList,
    List<Map<String, dynamic>>? secretaryDoctors,
  }) {
    return SettingsState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      userEntity: userEntity ?? this.userEntity,
      clinicEntity: clinicEntity ?? this.clinicEntity,
      subscriptionEntity: subscriptionEntity ?? this.subscriptionEntity,
      doctorEntity: doctorEntity ?? this.doctorEntity,
      availableClinics: availableClinics ?? this.availableClinics,
      staffList: staffList ?? this.staffList,
      secretaryDoctors: secretaryDoctors ?? this.secretaryDoctors,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        error,
        userEntity,
        clinicEntity,
        subscriptionEntity,
        doctorEntity,
        availableClinics,
        staffList,
        secretaryDoctors,
      ];
}

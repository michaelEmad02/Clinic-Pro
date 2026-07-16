// ────────────────────────────────────────────────────────
// Cubit شاشة العيادات — يستخدم UseCases من طبقة الـ Domain
// ────────────────────────────────────────────────────────

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/entities/clinic_entity.dart';
import '../../../domain/use_cases/fetch_clinics_use_case.dart';
import '../../../domain/use_cases/add_clinic_use_case.dart';
import '../../../domain/use_cases/edit_clinic_use_case.dart';
import '../../../domain/use_cases/delete_clinic_use_case.dart';
import '../../../domain/use_cases/toggle_is_active_use_case.dart';
import '../../../domain/use_cases/add_staff_use_case.dart';
import '../../../domain/use_cases/delete_staff_use_case.dart';
import '../../../../../core/constants/staff_roles.dart';
import 'clinics_state.dart';

@injectable
class ClinicsCubit extends Cubit<ClinicsState> {
  final FetchClinicsUseCase fetchClinicsUseCase;
  final AddClinicUseCase addClinicUseCase;
  final EditClinicUseCase editClinicUseCase;
  final DeleteClinicUseCase deleteClinicUseCase;
  final ToggleIsActiveUseCase toggleIsActiveUseCase;
  final AddStaffUseCase addStaffUseCase;
  final DeleteStaffUseCase deleteStaffUseCase;

  ClinicsCubit({
    required this.fetchClinicsUseCase,
    required this.addClinicUseCase,
    required this.editClinicUseCase,
    required this.deleteClinicUseCase,
    required this.toggleIsActiveUseCase,
    required this.addStaffUseCase,
    required this.deleteStaffUseCase,
  }) : super(ClinicsInitial());

  // جلب جميع العيادات
  Future<void> fetchClinics() async {
    emit(ClinicsLoading());

    final result = await fetchClinicsUseCase.call();

    result.fold(
      (failure) => emit(ClinicsError(failure.message)),
      (clinics) => emit(ClinicsLoaded(clinics: clinics)),
    );
  }

  // إضافة عيادة جديدة
  Future<void> addClinic(ClinicEntity clinic) async {
    final result = await addClinicUseCase.call(clinic);

    result.fold(
      (failure) => emit(ClinicsError(failure.message)),
      (_) => fetchClinics(), // إعادة تحميل القائمة بعد الإضافة
    );
  }

  // تعديل بيانات عيادة
  Future<void> updateClinic(ClinicEntity clinic) async {
    final result = await editClinicUseCase.call(clinic);

    result.fold(
      (failure) => emit(ClinicsError(failure.message)),
      (_) => fetchClinics(), // إعادة تحميل القائمة بعد التعديل
    );
  }

  // حذف عيادة
  Future<void> deleteClinic(String clinicId) async {
    final result = await deleteClinicUseCase.call(clinicId);

    result.fold(
      (failure) => emit(ClinicsError(failure.message)),
      (_) => fetchClinics(), // إعادة تحميل القائمة بعد الحذف
    );
  }

  // تفعيل / إيقاف عيادة
  Future<void> toggleActive(String clinicId) async {
    if (state is! ClinicsLoaded) return;
    final loaded = state as ClinicsLoaded;

    // البحث عن العيادة الحالية للحصول على حالتها
    final clinic = loaded.clinics.firstWhere((c) => c.id == clinicId);
    final newStatus = !clinic.isActive;

    final result = await toggleIsActiveUseCase.call(clinicId, newStatus);

    result.fold(
      (failure) => emit(ClinicsError(failure.message)),
      (_) => fetchClinics(), // إعادة تحميل القائمة بعد التبديل
    );
  }

  // إضافة عضو إلى طاقم العيادة
  Future<void> addStaffMember({
    required String clinicId,
    required String userId,
    required String doctorId,
    required StaffRoles role,
  }) async {
    final result = await addStaffUseCase.call(clinicId, userId, doctorId, role);

    result.fold(
      (failure) => emit(ClinicsError(failure.message)),
      (_) => fetchClinics(), // إعادة تحميل القائمة بعد الإضافة
    );
  }

  // إزالة عضو من طاقم العيادة
  Future<void> removeStaffMember({
    required String clinicId,
    required String staffId,
  }) async {
    final result = await deleteStaffUseCase.call(clinicId, staffId);

    result.fold(
      (failure) => emit(ClinicsError(failure.message)),
      (_) => fetchClinics(), // إعادة تحميل القائمة بعد الإزالة
    );
  }
}

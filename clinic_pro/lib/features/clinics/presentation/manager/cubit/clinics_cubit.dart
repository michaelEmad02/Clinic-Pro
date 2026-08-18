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
import 'package:clinic_pro/features/staff_and_invitations/domain/use_cases/delete_staff_use_case.dart' as staff_use_cases;
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
  final staff_use_cases.DeleteStaffUseCase deleteStaffUseCase;

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
  Future<void> fetchClinics(String ownerId) async {
    emit(ClinicsLoading());

    final result = await fetchClinicsUseCase.call(ownerId);

    result.fold(
      (failure) => emit(ClinicsError(failure.message)),
      (clinics) => emit(ClinicsLoaded(clinics: clinics)),
    );
  }

  // إضافة عيادة جديدة
  Future<void> addClinic(ClinicEntity clinic, {bool isDoctor = false}) async {
    final result = await addClinicUseCase.call(clinic);

    result.fold(
      (failure) => emit(ClinicsError(failure.message)),
      (newClinicId) async {
        final createdClinic = clinic.copyWith(id: newClinicId);

        if (isDoctor) {
          final staffResult = await addStaffUseCase.call(
            newClinicId,
            clinic.ownerId,
            null,
            StaffRoles.doctor,
            clinic.ownerId,
          );
          staffResult.fold(
            (failure) => emit(ClinicsError(failure.message)),
            (_) {
              _addClinicToLocalState(createdClinic, message: 'تمت إضافة العيادة بنجاح');
            },
          );
        } else {
          _addClinicToLocalState(createdClinic, message: 'تمت إضافة العيادة بنجاح');
        }
      },
    );
  }

  // تعديل بيانات عيادة
  Future<void> updateClinic(ClinicEntity clinic) async {
    final result = await editClinicUseCase.call(clinic);

    result.fold(
      (failure) => emit(ClinicsError(failure.message)),
      (_) {
        _updateClinicInLocalState(clinic, message: 'تم تعديل بيانات العيادة بنجاح');
      },
    );
  }

  // حذف عيادة
  Future<void> deleteClinic(ClinicEntity clinic) async {
    final result = await deleteClinicUseCase.call(clinic.id);

    result.fold(
      (failure) => emit(ClinicsError(failure.message)),
      (_) {
        _deleteClinicFromLocalState(clinic.id, message: 'تم حذف عيادة "${clinic.name}" بنجاح');
      },
    );
  }

  // تفعيل / إيقاف عيادة
  Future<void> toggleActive(String clinicId) async {
    if (state is! ClinicsLoaded) return;
    final loaded = state as ClinicsLoaded;
    final clinic = loaded.clinics.firstWhere((c) => c.id == clinicId);
    final newStatus = !clinic.isActive;
    final result = await toggleIsActiveUseCase.call(clinic.id, newStatus);

    result.fold(
      (failure) => emit(ClinicsError(failure.message)),
      (_) {
        final updatedClinic = clinic.copyWith(isActive: newStatus);
        _updateClinicInLocalState(updatedClinic, message: newStatus ? 'تم تفعيل العيادة بنجاح' : 'تم إيقاف العيادة بنجاح');
      },
    );
  }

  // ─── Local State Mutators ──────────────────────────────

  void _addClinicToLocalState(ClinicEntity clinic, {String? message}) {
    if (state is ClinicsLoaded) {
      final currentList = (state as ClinicsLoaded).clinics;
      emit(ClinicsLoaded(clinics: [...currentList, clinic], actionMessage: message));
    } else {
      emit(ClinicsLoaded(clinics: [clinic], actionMessage: message));
    }
  }

  void _updateClinicInLocalState(ClinicEntity updatedClinic, {String? message}) {
    if (state is ClinicsLoaded) {
      final currentList = (state as ClinicsLoaded).clinics;
      final updatedList = currentList.map((c) => c.id == updatedClinic.id ? updatedClinic : c).toList();
      emit(ClinicsLoaded(clinics: updatedList, actionMessage: message));
    }
  }

  void _deleteClinicFromLocalState(String clinicId, {String? message}) {
    if (state is ClinicsLoaded) {
      final currentList = (state as ClinicsLoaded).clinics;
      final updatedList = currentList.where((c) => c.id != clinicId).toList();
      emit(ClinicsLoaded(clinics: updatedList, actionMessage: message));
    }
  }

  // إضافة عضو إلى طاقم العيادة
  Future<void> addStaffMember({
    required String clinicId,
    required String ownerId,
    required String userId,
    required String? doctorId,
    required StaffRoles role,
  }) async {
    final result = await addStaffUseCase.call(clinicId, userId, doctorId, role, ownerId);

    result.fold(
      (failure) => emit(ClinicsError(failure.message)),
      (_) => fetchClinics(ownerId), // إعادة تحميل القائمة بعد الإضافة
    );
  }

  // إزالة عضو من طاقم العيادة
  Future<void> removeStaffMember({
    required String clinicId,
    required String ownerId,
    required String staffId,
    String? doctorId,
  }) async {
    final result = await deleteStaffUseCase.call(staffId);

    result.fold(
      (failure) => emit(ClinicsError(failure.message)),
      (_) => fetchClinics(ownerId), // إعادة تحميل القائمة بعد الإزالة
    );
  }
}

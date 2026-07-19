import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/constants/staff_roles.dart';
import '../../domain/entities/invitation_entity.dart';
import '../../domain/use_cases/fetch_all_staff_use_case.dart';
import '../../domain/use_cases/invite_staff_use_case.dart';
import 'invite_staff_state.dart';

@injectable
class InviteStaffCubit extends Cubit<InviteStaffState> {
  final FetchAllStaffUseCase fetchAllStaffUseCase;
  final InviteStaffUseCase inviteStaffUseCase;

  InviteStaffCubit({
    required this.fetchAllStaffUseCase,
    required this.inviteStaffUseCase,
  }) : super(InviteStaffInitial());

  Future<void> loadInitialData(String ownerId, String? initialClinicId) async {
    emit(InviteStaffLoading());

    try {
      final staffResult = await fetchAllStaffUseCase.call(ownerId);

      staffResult.fold(
        (failure) => emit(InviteStaffError(failure.message)),
        (staffList) {
          final doctors = staffList
              .where((s) =>
                  s.role == StaffRoles.doctor &&
                  s.clinicId == initialClinicId)
              .toList();
          final selectedDoctorId = doctors.isNotEmpty ? doctors.first.id : null;

          emit(InviteStaffLoaded(
            doctors: doctors,
            selectedClinicId: initialClinicId,
            selectedDoctorId: selectedDoctorId,
          ));
        },
      );
    } catch (e) {
      emit(InviteStaffError(e.toString()));
    }
  }

  void onClinicChanged(String clinicId, String ownerId) async {
    if (state is! InviteStaffLoaded) return;
    final loaded = state as InviteStaffLoaded;

    final staffResult = await fetchAllStaffUseCase.call(ownerId);

    staffResult.fold(
      (failure) => emit(InviteStaffError(failure.message)),
      (staffList) {
        final doctors = staffList
            .where((s) =>
                s.role == StaffRoles.doctor && s.clinicId == clinicId)
            .toList();
        final selectedDoctorId = doctors.isNotEmpty ? doctors.first.id : null;

        emit(loaded.copyWith(
          selectedClinicId: clinicId,
          doctors: doctors,
          selectedDoctorId: selectedDoctorId,
        ));
      },
    );
  }

  void onDoctorChanged(String? doctorId) {
    if (state is! InviteStaffLoaded) return;
    final loaded = state as InviteStaffLoaded;
    emit(loaded.copyWith(selectedDoctorId: doctorId));
  }

  void onRoleChanged(StaffRoles role) {
    if (state is! InviteStaffLoaded) return;
    final loaded = state as InviteStaffLoaded;
    emit(loaded.copyWith(selectedRole: role));
  }

  /// إضافة موظف إلى قائمة الدعوات المقترحة للتحقق منها قبل الإرسال
  void addInvitee(InvitationEntity invitee) {
    if (state is! InviteStaffLoaded) return;
    final loaded = state as InviteStaffLoaded;

    // التحقق من أن هذا البريد لم يتم إضافته في القائمة الحالية بالفعل
    if (loaded.invitedStaff.any((s) => s.email == invitee.email)) {
      emit(loaded.copyWith(submitErrorMessage: 'هذا البريد الإلكتروني مضاف مسبقاً'));
      return;
    }

    emit(loaded.copyWith(
      invitedStaff: [...loaded.invitedStaff, invitee],
    ));
  }

  void removeInvitee(int index) {
    if (state is! InviteStaffLoaded) return;
    final loaded = state as InviteStaffLoaded;
    final list = List<InvitationEntity>.from(loaded.invitedStaff)..removeAt(index);
    emit(loaded.copyWith(invitedStaff: list));
  }

  Future<void> sendInvitations(String ownerId) async {
    if (state is! InviteStaffLoaded) return;
    final loaded = state as InviteStaffLoaded;

    // إذا كانت القائمة فارغة، نعرض رسالة خطأ بدلاً من النجاح الزائف
    if (loaded.invitedStaff.isEmpty) {
      emit(loaded.copyWith(
        submitErrorMessage: 'يرجى إضافة موظف واحد على الأقل لإرسال الدعوات',
      ));
      return;
    }

    emit(loaded.copyWith(isSubmitting: true));

    bool hasError = false;
    String? errorMsg;

    for (final invitation in loaded.invitedStaff) {
      final result = await inviteStaffUseCase.call(invitation);
      result.fold(
        (failure) {
          hasError = true;
          errorMsg = failure.message;
        },
        (_) {},
      );

      if (hasError) break;
    }

    if (hasError) {
      emit(loaded.copyWith(isSubmitting: false, submitErrorMessage: errorMsg));
    } else {
      emit(loaded.copyWith(isSubmitting: false, isSuccess: true));
    }
  }

  void clearSubmitError() {
    if (state is InviteStaffLoaded) {
      emit((state as InviteStaffLoaded).copyWith(submitErrorMessage: null));
    }
  }
}

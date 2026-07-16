import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/constants/staff_roles.dart';
import '../../../../core/constants/supabase_constants.dart';
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

  void addInvitee({
    required String name,
    required String email,
    required String clinicName,
    required String ownerId,
  }) {
    if (state is! InviteStaffLoaded) return;
    final loaded = state as InviteStaffLoaded;

    if (loaded.invitedStaff.any((s) => s.email == email)) {
      emit(loaded.copyWith(submitErrorMessage: 'هذا البريد الإلكتروني مضاف مسبقاً'));
      return;
    }

    String? doctorName;
    if (loaded.selectedRole == StaffRoles.secretary && loaded.selectedDoctorId != null) {
      final doc = loaded.doctors.firstWhere((d) => d.id == loaded.selectedDoctorId);
      doctorName = doc.name;
    }

    final now = DateTime.now();
    final newItem = InvitationEntity(
      id: '',
      clinicId: loaded.selectedClinicId!,
      clinicName: clinicName,
      ownerId: ownerId,
      doctorId: loaded.selectedRole == StaffRoles.secretary ? loaded.selectedDoctorId : null,
      doctorName: doctorName,
      email: email,
      name: name,
      role: loaded.selectedRole,
      token: 'token-${now.millisecondsSinceEpoch}',
      status: InvitationStatus.pending,
      expiredAt: now.add(const Duration(days: 7)),
      createdAt: now,
    );

    emit(loaded.copyWith(
      invitedStaff: [...loaded.invitedStaff, newItem],
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

    if (loaded.invitedStaff.isEmpty) {
      emit(loaded.copyWith(isSuccess: true));
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

import 'package:clinic_pro/features/staff/domain/entities/invitation_entity.dart';
import 'package:clinic_pro/features/staff/domain/entities/staff_entity.dart';
import 'package:clinic_pro/features/staff/domain/use_cases/cancel_invitation_use_case.dart';
import 'package:clinic_pro/features/staff/domain/use_cases/delete_staff_use_case.dart';
import 'package:clinic_pro/features/staff/domain/use_cases/edit_staff_entity_use_case.dart';
import 'package:clinic_pro/features/staff/domain/use_cases/fetch_all_staff_use_case.dart';
import 'package:clinic_pro/features/staff/domain/use_cases/fetch_pending_invitations_use_case.dart';
import 'package:clinic_pro/features/staff/domain/use_cases/fetch_staff_by_is_use_case.dart';
import 'package:clinic_pro/features/staff/domain/use_cases/invite_staff_use_case.dart';
import 'package:clinic_pro/core/constants/staff_roles.dart';
import 'package:clinic_pro/core/constants/supabase_constants.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:injectable/injectable.dart';
import '../../../../core/strings/app_strings.dart';
import 'staff_state.dart';

@injectable
class StaffCubit extends Cubit<StaffState> {
  final FetchAllStaffUseCase fetchAllStaffUseCase;
  final FetchStaffByIsUseCase fetchStaffByIsUseCase;
  final FetchPendingInvitationsUseCase fetchPendingInvitationsUseCase;
  final DeleteStaffUseCase deleteStaffUseCase;
  final EditStaffEntityUseCase editStaffEntityUseCase;
  final InviteStaffUseCase inviteStaffUseCase;
  final CancelInvitationUseCase cancelInvitationUseCase;

  StaffCubit({
    required this.fetchAllStaffUseCase,
    required this.fetchStaffByIsUseCase,
    required this.fetchPendingInvitationsUseCase,
    required this.deleteStaffUseCase,
    required this.editStaffEntityUseCase,
    required this.inviteStaffUseCase,
    required this.cancelInvitationUseCase,
  }) : super(StaffInitial());

  Future<void> fetchAllStaff(String ownerId) async {
    emit(StaffLoading());

    try {
      final staffResult = await fetchAllStaffUseCase.call(ownerId);
      final invitationsResult =
          await fetchPendingInvitationsUseCase.call(ownerId);

      List<StaffEntity> items = [];
      List<InvitationEntity> invitations = [];

      staffResult.fold(
        (failure) => throw Exception(failure.message),
        (entities) {
          items = entities;
        },
      );

      invitationsResult.fold(
        (failure) => throw Exception(failure.message),
        (entities) {
          invitations = entities;
        },
      );

      emit(StaffLoaded(
        allStaff: items,
        invitations: invitations,
      ));
    } catch (_) {
      emit(StaffError(AppStrings.loadStaffFailed));
    }
  }

  void search(String query) {
    if (state is StaffLoaded) {
      emit((state as StaffLoaded).copyWith(searchQuery: query));
    }
  }

  void changeFilter(StaffFilter filter) {
    if (state is StaffLoaded) {
      emit((state as StaffLoaded).copyWith(activeFilter: filter));
    }
  }

  void changeClinicFilter(String? clinicId) {
    if (state is StaffLoaded) {
      emit((state as StaffLoaded).copyWith(selectedClinicId: clinicId));
    }
  }

  Future<void> inviteStaff({
    required String email,
    required String name,
    required String role,
    String? clinicId,
  }) async {
    if (state is! StaffLoaded) return;
    final loaded = state as StaffLoaded;

    final now = DateTime.now();
    final staffRole = StaffRoles.values.firstWhere(
      (r) => r.name == role,
      orElse: () => StaffRoles.secretary,
    );

    final invitation = InvitationEntity(
      id: '',
      clinicId: clinicId ?? 'c-1',
      ownerId: 'u-owner-1',
      email: email,
      name: name,
      role: staffRole,
      token: 'token-${now.millisecondsSinceEpoch}',
      status: InvitationStatus.pending,
      expiredAt: now.add(const Duration(days: 7)),
      createdAt: now,
    );

    final result = await inviteStaffUseCase.call(invitation);

    result.fold(
      (failure) => emit(StaffError(failure.message)),
      (_) {
        final newInvitation = InvitationEntity(
          id: invitation.id.isEmpty
              ? 'inv-${now.millisecondsSinceEpoch}'
              : invitation.id,
          clinicId: invitation.clinicId,
          ownerId: invitation.ownerId,
          email: invitation.email,
          name: invitation.name,
          role: invitation.role,
          token: invitation.token,
          status: invitation.status,
          expiredAt: invitation.expiredAt,
          createdAt: invitation.createdAt,
        );
        emit(loaded
            .copyWith(invitations: [...loaded.invitations, newInvitation]));
      },
    );
  }

  Future<void> resendInvitation(String invitationId) async {
    if (state is! StaffLoaded) return;
    await Future.delayed(const Duration(milliseconds: 300));
  }

  Future<void> cancelInvitation(String invitationId) async {
    if (state is! StaffLoaded) return;
    final loaded = state as StaffLoaded;

    final result = await cancelInvitationUseCase.call(invitationId);

    result.fold(
      (failure) => emit(StaffError(failure.message)),
      (_) {
        final updated =
            loaded.invitations.where((inv) => inv.id != invitationId).toList();
        emit(loaded.copyWith(invitations: updated));
      },
    );
  }

  Future<void> updateStaffRole(String staffId, String newRole) async {
    if (state is! StaffLoaded) return;
    final loaded = state as StaffLoaded;

    final staffItem = loaded.allStaff.firstWhere((s) => s.id == staffId);
    final staffRole = StaffRoles.values.firstWhere(
      (r) => r.name == newRole,
      orElse: () => StaffRoles.secretary,
    );

    final staffEntity = StaffEntity(
      id: staffItem.id,
      clinicId: staffItem.clinicId,
      userId: staffItem.userId,
      name: staffItem.name,
      email: staffItem.email,
      phone: staffItem.phone,
      avatarUrl: staffItem.avatarUrl,
      specialty: staffItem.specialty,
      role: staffRole,
      isActive: staffItem.isActive,
      joinedAt: staffItem.joinedAt,
      doctorSecretaries: staffItem.doctorSecretaries,
      doctorSchedules: staffItem.doctorSchedules,
    );

    final result = await editStaffEntityUseCase.call(staffEntity);

    result.fold(
      (failure) => emit(StaffError(failure.message)),
      (_) {
        final list = loaded.allStaff.map((s) {
          if (s.id == staffId) {
            return StaffEntity(
              id: s.id,
              clinicId: s.clinicId,
              userId: s.userId,
              name: s.name,
              email: s.email,
              phone: s.phone,
              avatarUrl: s.avatarUrl,
              specialty: s.specialty,
              role: staffRole,
              isActive: s.isActive,
              joinedAt: s.joinedAt,
              doctorSecretaries: s.doctorSecretaries,
              doctorSchedules: s.doctorSchedules,
            );
          }
          return s;
        }).toList();
        emit(loaded.copyWith(allStaff: list));
      },
    );
  }

  Future<void> toggleSuspend(String staffId) async {
    if (state is! StaffLoaded) return;
    final loaded = state as StaffLoaded;
    final staffItem = loaded.allStaff.firstWhere((s) => s.id == staffId);

    final staffEntity = StaffEntity(
      id: staffItem.id,
      clinicId: staffItem.clinicId,
      userId: staffItem.userId,
      name: staffItem.name,
      email: staffItem.email,
      phone: staffItem.phone,
      avatarUrl: staffItem.avatarUrl,
      specialty: staffItem.specialty,
      role: staffItem.role,
      isActive: !staffItem.isActive,
      joinedAt: staffItem.joinedAt,
      doctorSecretaries: staffItem.doctorSecretaries,
      doctorSchedules: staffItem.doctorSchedules,
    );

    final result = await editStaffEntityUseCase.call(staffEntity);

    result.fold(
      (failure) => emit(StaffError(failure.message)),
      (_) {
        final list = loaded.allStaff.map((s) {
          if (s.id == staffId) {
            return StaffEntity(
              id: s.id,
              clinicId: s.clinicId,
              userId: s.userId,
              name: s.name,
              email: s.email,
              phone: s.phone,
              avatarUrl: s.avatarUrl,
              specialty: s.specialty,
              role: s.role,
              isActive: !s.isActive,
              joinedAt: s.joinedAt,
              doctorSecretaries: s.doctorSecretaries,
              doctorSchedules: s.doctorSchedules,
            );
          }
          return s;
        }).toList();
        emit(loaded.copyWith(allStaff: list));
      },
    );
  }

  Future<void> deleteStaff(String staffId) async {
    if (state is! StaffLoaded) return;
    final loaded = state as StaffLoaded;

    final result = await deleteStaffUseCase.call(staffId);

    result.fold(
      (failure) => emit(StaffError(failure.message)),
      (_) {
        final list = loaded.allStaff.where((s) => s.id != staffId).toList();
        emit(loaded.copyWith(allStaff: list));
      },
    );
  }
}

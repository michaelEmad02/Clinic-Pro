// ────────────────────────────────────────────────────────
// حالات شاشة الطاقم الطبي — نماذج StaffItem و StaffInvitationItem
// ────────────────────────────────────────────────────────

import 'package:equatable/equatable.dart';
import '../../../../core/constants/staff_roles.dart';
import '../../domain/entities/staff_entity.dart';
import '../../domain/entities/invitation_entity.dart';

enum StaffFilter { all, doctor, secretary }

abstract class StaffState extends Equatable {
  const StaffState();

  @override
  List<Object?> get props => [];
}

class StaffInitial extends StaffState {}

class StaffLoading extends StaffState {}

class StaffLoaded extends StaffState {
  final List<StaffEntity> allStaff;
  final List<InvitationEntity> invitations;
  final String? selectedClinicId;
  final String searchQuery;
  final StaffFilter activeFilter;

  const StaffLoaded({
    required this.allStaff,
    this.invitations = const [],
    this.selectedClinicId,
    this.searchQuery = '',
    this.activeFilter = StaffFilter.all,
  });

  List<StaffEntity> get filteredStaff {
    var list = allStaff;

    if (selectedClinicId != null && selectedClinicId!.isNotEmpty) {
      list = list.where((s) => s.clinicId == selectedClinicId).toList();
    }

    if (searchQuery.isNotEmpty) {
      list = list
          .where((s) =>
              s.name.contains(searchQuery) || s.email.contains(searchQuery))
          .toList();
    }

    switch (activeFilter) {
      case StaffFilter.all:
        break;
      case StaffFilter.doctor:
        list = list.where((s) => s.role == StaffRoles.doctor).toList();
        break;
      case StaffFilter.secretary:
        list = list.where((s) => s.role == StaffRoles.secretary).toList();
        break;
    }

    return list;
  }

  List<InvitationEntity> get pendingInvitations {
    var list = invitations.where((inv) => inv.status == 'pending').toList();
    if (selectedClinicId != null && selectedClinicId!.isNotEmpty) {
      list = list.where((inv) => inv.clinicId == selectedClinicId).toList();
    }
    return list;
  }

  StaffLoaded copyWith({
    List<StaffEntity>? allStaff,
    List<InvitationEntity>? invitations,
    String? selectedClinicId,
    String? searchQuery,
    StaffFilter? activeFilter,
  }) {
    return StaffLoaded(
      allStaff: allStaff ?? this.allStaff,
      invitations: invitations ?? this.invitations,
      selectedClinicId: selectedClinicId ?? this.selectedClinicId,
      searchQuery: searchQuery ?? this.searchQuery,
      activeFilter: activeFilter ?? this.activeFilter,
    );
  }

  @override
  List<Object?> get props =>
      [allStaff, invitations, selectedClinicId, searchQuery, activeFilter];
}

class StaffError extends StaffState {
  final String message;

  const StaffError(this.message);

  @override
  List<Object?> get props => [message];
}

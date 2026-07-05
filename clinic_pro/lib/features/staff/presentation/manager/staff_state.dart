// ────────────────────────────────────────────────────────
// حالات شاشة الطاقم الطبي — نماذج StaffItem و StaffInvitationItem
// ────────────────────────────────────────────────────────

import 'package:equatable/equatable.dart';
import '../../../../core/constants/staff_roles.dart';

enum StaffFilter { all, doctor, secretary }

class StaffItem extends Equatable {
  final String id;
  final String clinicId;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String? avatarUrl;
  final String? specialty;
  final double? rating;
  final bool isOnline;
  final String? lastSeen;
  final bool isActive;

  const StaffItem({
    required this.id,
    this.clinicId = '',
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.avatarUrl,
    this.specialty,
    this.rating,
    this.isOnline = false,
    this.lastSeen,
    this.isActive = true,
  });

  String get initials {
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0];
    return '${parts.first[0]}${parts.last[0]}';
  }

  String get roleLabel {
    switch (role) {
      case 'doctor':
        return 'طبيب';
      case 'nurse':
        return 'تمريض';
      case 'accountant':
        return 'محاسب';
      case 'secretary':
        return 'سكرتير';
      case 'owner':
        return 'مالك';
      default:
        return role;
    }
  }

  StaffItem copyWith({
    String? role,
    bool? isActive,
    bool? isOnline,
    String? lastSeen,
  }) {
    return StaffItem(
      id: id,
      clinicId: clinicId,
      name: name,
      email: email,
      phone: phone,
      role: role ?? this.role,
      avatarUrl: avatarUrl,
      specialty: specialty,
      rating: rating,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [id, name, role, isActive];
}

class StaffInvitationItem extends Equatable {
  final String id;
  final String clinicId;
  final String ownerId;
  final String email;
  final String? name;
  final String role;
  final String status;
  final String createdAt;
  final String? expiresAt;

  const StaffInvitationItem({
    required this.id,
    this.clinicId = '',
    this.ownerId = '',
    required this.email,
    this.name,
    required this.role,
    required this.status,
    required this.createdAt,
    this.expiresAt,
  });

  String get roleLabel {
    switch (role) {
      case 'doctor':
        return 'طبيب';
      case 'nurse':
        return 'تمريض';
      case 'accountant':
        return 'محاسب';
      case 'secretary':
        return 'سكرتير';
      default:
        return role;
    }
  }

  @override
  List<Object?> get props => [id, clinicId, email, status];
}

abstract class StaffState extends Equatable {
  const StaffState();

  @override
  List<Object?> get props => [];
}

class StaffInitial extends StaffState {}

class StaffLoading extends StaffState {}

class StaffLoaded extends StaffState {
  final List<StaffItem> allStaff;
  final List<StaffInvitationItem> invitations;
  final List<Map<String, dynamic>> clinics;
  final String? selectedClinicId;
  final String searchQuery;
  final StaffFilter activeFilter;

  const StaffLoaded({
    required this.allStaff,
    this.invitations = const [],
    this.clinics = const [],
    this.selectedClinicId,
    this.searchQuery = '',
    this.activeFilter = StaffFilter.all,
  });

  List<StaffItem> get filteredStaff {
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
        list = list.where((s) => s.role == StaffRoles.doctor.name).toList();
        break;
      case StaffFilter.secretary:
        list = list.where((s) => s.role == StaffRoles.secretary.name).toList();
        break;
    }

    return list;
  }

  List<StaffInvitationItem> get pendingInvitations {
    var list = invitations.where((inv) => inv.status == 'pending').toList();
    if (selectedClinicId != null && selectedClinicId!.isNotEmpty) {
      list = list.where((inv) => inv.clinicId == selectedClinicId).toList();
    }
    return list;
  }

  StaffLoaded copyWith({
    List<StaffItem>? allStaff,
    List<StaffInvitationItem>? invitations,
    List<Map<String, dynamic>>? clinics,
    String? selectedClinicId,
    String? searchQuery,
    StaffFilter? activeFilter,
  }) {
    return StaffLoaded(
      allStaff: allStaff ?? this.allStaff,
      invitations: invitations ?? this.invitations,
      clinics: clinics ?? this.clinics,
      selectedClinicId: selectedClinicId ?? this.selectedClinicId,
      searchQuery: searchQuery ?? this.searchQuery,
      activeFilter: activeFilter ?? this.activeFilter,
    );
  }

  @override
  List<Object?> get props =>
      [allStaff, invitations, clinics, selectedClinicId, searchQuery, activeFilter];
}

class StaffError extends StaffState {
  final String message;

  const StaffError(this.message);

  @override
  List<Object?> get props => [message];
}

// ────────────────────────────────────────────────────────
// حالات شاشة الطاقم الطبي — نماذج StaffItem و StaffInvitationItem
// ────────────────────────────────────────────────────────

import 'package:equatable/equatable.dart';

enum StaffFilter { all, doctors, nursing, admin }

class StaffItem extends Equatable {
  final String id;
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
  final String email;
  final String? name;
  final String role;
  final String status;
  final String createdAt;

  const StaffInvitationItem({
    required this.id,
    required this.email,
    this.name,
    required this.role,
    required this.status,
    required this.createdAt,
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
  List<Object?> get props => [id, email, status];
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
  final String searchQuery;
  final StaffFilter activeFilter;

  const StaffLoaded({
    required this.allStaff,
    this.invitations = const [],
    this.searchQuery = '',
    this.activeFilter = StaffFilter.all,
  });

  List<StaffItem> get filteredStaff {
    var list = allStaff;

    if (searchQuery.isNotEmpty) {
      list = list
          .where((s) =>
              s.name.contains(searchQuery) || s.email.contains(searchQuery))
          .toList();
    }

    switch (activeFilter) {
      case StaffFilter.all:
        break;
      case StaffFilter.doctors:
        list = list.where((s) => s.role == 'doctor').toList();
      case StaffFilter.nursing:
        list = list.where((s) => s.role == 'nurse').toList();
      case StaffFilter.admin:
        list = list
            .where((s) =>
                s.role == 'secretary' ||
                s.role == 'accountant' ||
                s.role == 'owner')
            .toList();
    }

    return list;
  }

  List<StaffInvitationItem> get pendingInvitations =>
      invitations.where((inv) => inv.status == 'pending').toList();

  StaffLoaded copyWith({
    List<StaffItem>? allStaff,
    List<StaffInvitationItem>? invitations,
    String? searchQuery,
    StaffFilter? activeFilter,
  }) {
    return StaffLoaded(
      allStaff: allStaff ?? this.allStaff,
      invitations: invitations ?? this.invitations,
      searchQuery: searchQuery ?? this.searchQuery,
      activeFilter: activeFilter ?? this.activeFilter,
    );
  }

  @override
  List<Object?> get props =>
      [allStaff, invitations, searchQuery, activeFilter];
}

class StaffError extends StaffState {
  final String message;

  const StaffError(this.message);

  @override
  List<Object?> get props => [message];
}

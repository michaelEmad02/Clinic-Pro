// ────────────────────────────────────────────────────────
// Cubit شاشة الطاقم الطبي — تحميل وفلترة ودعوة موظفين (Mock)
// ────────────────────────────────────────────────────────

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/mocks/mock_data.dart';
import 'staff_state.dart';

class StaffCubit extends Cubit<StaffState> {
  StaffCubit() : super(StaffInitial());

  Future<void> loadStaff() async {
    emit(StaffLoading());
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final items = _mapStaffFromMock();
      final invitations = _mapInvitationsFromMock();
      emit(StaffLoaded(allStaff: items, invitations: invitations));
    } catch (_) {
      emit(const StaffError('تعذّر تحميل قائمة الطاقم الطبي'));
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

  Future<void> inviteStaff({
    required String email,
    required String name,
    required String role,
  }) async {
    if (state is! StaffLoaded) return;
    final loaded = state as StaffLoaded;
    await Future.delayed(const Duration(milliseconds: 400));

    final newInvitation = StaffInvitationItem(
      id: 'inv-new-${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      name: name,
      role: role,
      status: 'pending',
      createdAt: DateTime.now().toIso8601String(),
    );

    emit(loaded.copyWith(
        invitations: [...loaded.invitations, newInvitation]));
  }

  Future<void> resendInvitation(String invitationId) async {
    if (state is! StaffLoaded) return;
    await Future.delayed(const Duration(milliseconds: 300));
  }

  Future<void> cancelInvitation(String invitationId) async {
    if (state is! StaffLoaded) return;
    final loaded = state as StaffLoaded;
    await Future.delayed(const Duration(milliseconds: 300));

    final updated = loaded.invitations
        .where((inv) => inv.id != invitationId)
        .toList();
    emit(loaded.copyWith(invitations: updated));
  }

  Future<void> updateStaffRole(String staffId, String newRole) async {
    if (state is! StaffLoaded) return;
    final loaded = state as StaffLoaded;
    await Future.delayed(const Duration(milliseconds: 300));

    final list = loaded.allStaff.map((s) {
      return s.id == staffId ? s.copyWith(role: newRole) : s;
    }).toList();
    emit(loaded.copyWith(allStaff: list));
  }

  Future<void> toggleSuspend(String staffId) async {
    if (state is! StaffLoaded) return;
    final loaded = state as StaffLoaded;
    await Future.delayed(const Duration(milliseconds: 300));

    final list = loaded.allStaff.map((s) {
      return s.id == staffId
          ? s.copyWith(isActive: !s.isActive)
          : s;
    }).toList();
    emit(loaded.copyWith(allStaff: list));
  }

  /// تحويل MockData (users + clinicStaff) إلى StaffItem
  List<StaffItem> _mapStaffFromMock() {
    final users = MockData.users;
    final clinicStaff = MockData.clinicStaff;

    // نجمع user_id النشطين من clinicStaff
    final activeUserIds = clinicStaff
        .where((cs) => cs['is_active'] == true)
        .map((cs) => cs['user_id'] as String)
        .toSet()
        .toList();

    return activeUserIds.map((userId) {
      final userData = users.firstWhere(
        (u) => u['id'] == userId,
        orElse: () => <String, dynamic>{},
      );

      if (userData.isEmpty) return null;

      // نحدد الدور من clinicStaff
      final staffEntry = clinicStaff.firstWhere(
        (cs) => cs['user_id'] == userId,
      );
      final role = staffEntry['role'] as String;

      final isOnline = role == 'doctor';
      final lastSeen = isOnline
          ? null
          : 'آخر ظهور: أمس';

      return StaffItem(
        id: userId,
        name: userData['name'] as String? ?? '',
        email: userData['email'] as String? ?? '',
        phone: userData['phone'] as String? ?? '',
        role: role,
        avatarUrl: userData['avatar_url'] as String?,
        specialty: userData['specialty'] as String?,
        rating: (userData['rating'] as num?)?.toDouble(),
        isOnline: isOnline,
        lastSeen: lastSeen,
        isActive: true,
      );
    }).whereType<StaffItem>().toList();
  }

  /// تحويل MockData.invitations إلى StaffInvitationItem
  List<StaffInvitationItem> _mapInvitationsFromMock() {
    return MockData.invitations.map((inv) {
      return StaffInvitationItem(
        id: inv['id'] as String,
        email: inv['email'] as String,
        name: inv['name'] as String?,
        role: inv['role'] as String,
        status: inv['status'] as String,
        createdAt: inv['created_at'] as String,
      );
    }).toList();
  }
}



import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/i_cloud_service.dart';
import 'staff_state.dart';

class StaffCubit extends Cubit<StaffState> {
  final ICloudService _cloudService;

  StaffCubit(this._cloudService) : super(StaffInitial());

  Future<void> loadStaff() async {
    emit(StaffLoading());

    try {
      final staffRows = await _cloudService.select(table: 'clinic_staff');
      final userRows = await _cloudService.select(table: 'users');
      final invitationRows = await _cloudService.select(table: 'invitations');
      final clinicRows = await _cloudService.select(table: 'clinics');

      final items = _mapStaff(staffRows, userRows);
      final invitations = _mapInvitations(invitationRows);
      emit(StaffLoaded(
        allStaff: items,
        invitations: invitations,
        clinics: clinicRows,
      ));
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
    final data = {
      'clinic_id': clinicId ?? 'c-1',
      'owner_id': 'u-owner-1',
      'email': email,
      'name': name,
      'role': role,
      'status': 'pending',
      'created_at': now.toIso8601String(),
      'expires_at': now.add(const Duration(days: 7)).toIso8601String(),
    };

    final newRecord = await _cloudService.insert(
      table: 'invitations',
      data: data,
    );

    final newInvitation = StaffInvitationItem(
      id: newRecord['id']?.toString() ?? 'inv-${now.millisecondsSinceEpoch}',
      clinicId: newRecord['clinic_id'] as String? ?? 'c-1',
      ownerId: newRecord['owner_id'] as String? ?? 'u-owner-1',
      email: newRecord['email'] as String,
      name: newRecord['name'] as String?,
      role: newRecord['role'] as String,
      status: newRecord['status'] as String,
      createdAt: newRecord['created_at'] as String,
      expiresAt: newRecord['expires_at'] as String?,
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

    await _cloudService.delete(
      table: 'invitations',
      matchColumn: 'id',
      matchValue: invitationId,
    );

    final updated = loaded.invitations
        .where((inv) => inv.id != invitationId)
        .toList();
    emit(loaded.copyWith(invitations: updated));
  }

  Future<void> updateStaffRole(String staffId, String newRole) async {
    if (state is! StaffLoaded) return;
    final loaded = state as StaffLoaded;

    await _cloudService.update(
      table: 'clinic_staff',
      data: {'role': newRole},
      matchColumn: 'user_id',
      matchValue: staffId,
    );

    final list = loaded.allStaff.map((s) {
      return s.id == staffId ? s.copyWith(role: newRole) : s;
    }).toList();
    emit(loaded.copyWith(allStaff: list));
  }

  Future<void> toggleSuspend(String staffId) async {
    if (state is! StaffLoaded) return;
    final loaded = state as StaffLoaded;
    final staffItem = loaded.allStaff.firstWhere((s) => s.id == staffId);

    await _cloudService.update(
      table: 'clinic_staff',
      data: {'is_active': !staffItem.isActive},
      matchColumn: 'user_id',
      matchValue: staffId,
    );

    final list = loaded.allStaff.map((s) {
      return s.id == staffId
          ? s.copyWith(isActive: !s.isActive)
          : s;
    }).toList();
    emit(loaded.copyWith(allStaff: list));
  }

  List<StaffItem> _mapStaff(List<Map<String, dynamic>> clinicStaff, List<Map<String, dynamic>> users) {
    // نجمع user_id النشطين من clinicStaff
    final activeUserIds = clinicStaff
        .map((cs) => cs['user_id'] as String)
        .toSet()
        .toList();

    return activeUserIds.map((userId) {
      final userData = users.firstWhere(
        (u) => u['id'] == userId,
        orElse: () => <String, dynamic>{},
      );

      if (userData.isEmpty) return null;

      final staffEntry = clinicStaff.firstWhere(
        (cs) => cs['user_id'] == userId,
      );
      final role = staffEntry['role'] as String;
      final isActive = staffEntry['is_active'] as bool? ?? true;

      final isOnline = role == 'doctor';
      final lastSeen = isOnline ? null : 'آخر ظهور: أمس';

      return StaffItem(
        id: userId,
        clinicId: staffEntry['clinic_id'] as String? ?? '',
        name: userData['name'] as String? ?? '',
        email: userData['email'] as String? ?? '',
        phone: userData['phone'] as String? ?? '',
        role: role,
        avatarUrl: userData['avatar_url'] as String?,
        specialty: userData['specialty'] as String?,
        rating: (userData['rating'] as num?)?.toDouble(),
        isOnline: isOnline,
        lastSeen: lastSeen,
        isActive: isActive,
      );
    }).whereType<StaffItem>().toList();
  }

  List<StaffInvitationItem> _mapInvitations(List<Map<String, dynamic>> invitationRows) {
    return invitationRows.map((inv) {
      return StaffInvitationItem(
        id: inv['id'] as String,
        clinicId: inv['clinic_id'] as String? ?? '',
        ownerId: inv['owner_id'] as String? ?? '',
        email: inv['email'] as String,
        name: inv['name'] as String?,
        role: inv['role'] as String,
        status: inv['status'] as String,
        createdAt: inv['created_at'] as String,
        expiresAt: inv['expires_at'] as String?,
      );
    }).toList();
  }
}



import 'package:injectable/injectable.dart';
import 'package:clinic_pro/core/constants/supabase_constants.dart';
import 'package:clinic_pro/core/services/i_auth_services.dart';
import 'package:clinic_pro/core/services/i_cloud_service.dart';
import 'package:clinic_pro/features/staff/data/models/invitation_model.dart';
import 'package:clinic_pro/features/staff/data/models/staff_model.dart';

abstract class StaffRemoteDataSource {
  Future<List<StaffModel>> fetchAllStaff(String ownerId);
  Future<StaffModel> fetchStaffById(String id);
  Future<void> inviteStaff(InvitationModel staff);
  Future<List<InvitationModel>> fetchPendingInvitations(String ownerId);
  Future<void> editStaff(StaffModel staff);
  Future<void> deleteStaff(String staffId);
  Future<void> cancelInvitation(String invitationId);
}

@LazySingleton(as: StaffRemoteDataSource)
class StaffRemoteDataSourceImplementation extends StaffRemoteDataSource {
  final ICloudService iCloudService;
  final IAuthServices iAuthServices;

  StaffRemoteDataSourceImplementation(
      {required this.iAuthServices, required this.iCloudService});

  final table = SupabaseTables.clinicStaff;
  @override
  Future<void> deleteStaff(String staffId) async {
    await iCloudService.delete(
        table: table, matchColumn: "id", matchValue: staffId);
  }

  @override
  Future<void> cancelInvitation(String invitationId) async {
    await iCloudService.delete(
      table: SupabaseTables.invitations,
      matchColumn: 'id',
      matchValue: invitationId,
    );
  }

  @override
  Future<void> editStaff(StaffModel staff) async {
    await iCloudService.update(
        table: table,
        data: staff.toJson(),
        matchColumn: 'id',
        matchValue: staff.id);
  }

  @override
  Future<List<StaffModel>> fetchAllStaff(String ownerId) async {
    // جلب الموظفين التابعين لهذا المالك عبر owner_id في جدول users
    final userRows = await iCloudService.select(
      table: 'users',
      eq: {'owner_id': ownerId},
    );

    // جلب صفوف clinic_staff لربط بيانات العيادة بالموظف
    final staffRows = await iCloudService.select(table: table);

    final Set<String> processedKeys = {}; // يحفظ مفاتيح مدمجة: userId_clinicId
    final List<StaffModel> uniqueStaff = [];

    for (final cs in staffRows) {
      final userId = cs['user_id'] as String;
      final clinicId = cs['clinic_id'] as String;
      final key = '${userId}_$clinicId';
      
      // التحقق من أن المستخدم يتبع هذا المالك ولم يسبق إضافته لنفس العيادة
      if (userRows.any((u) => u['id'] == userId) && !processedKeys.contains(key)) {
        processedKeys.add(key);
        
        final userData = userRows.firstWhere(
          (u) => u['id'] == userId,
          orElse: () => <String, dynamic>{},
        );

        final mergedJson = {
          ...cs,
          'users': userData,
        };
        uniqueStaff.add(StaffModel.fromJson(mergedJson));
      }
    }

    return uniqueStaff;
  }

  @override
  Future<List<InvitationModel>> fetchPendingInvitations(String ownerId) async {
    var result = await iCloudService
        .select(table: SupabaseTables.invitations, eq: {"owner_id": ownerId});
    return result.map((i) => InvitationModel.fromJson(i)).toList();
  }

  @override
  Future<StaffModel> fetchStaffById(String id) async {
    final staffRows =
        await iCloudService.select(table: table, eq: {"user_id": id});
    if (staffRows.isEmpty) {
      throw Exception("Staff member not found");
    }
    final cs = staffRows.first;

    final userRows = await iCloudService.select(table: 'users', eq: {"id": id});
    final userData = userRows.isNotEmpty ? userRows.first : <String, dynamic>{};

    final mergedJson = {
      ...cs,
      'users': userData,
    };
    return StaffModel.fromJson(mergedJson);
  }

  @override
  Future<void> inviteStaff(InvitationModel staff) async {
    // send invitation
    await iAuthServices.sendInvitation(staff.email);

    // save invitation data
    await iCloudService.insert(
        table: SupabaseTables.invitations, data: staff.toJson());
  }
}

import 'package:injectable/injectable.dart';
import 'package:clinic_pro/core/constants/supabase_constants.dart';
import 'package:clinic_pro/core/constants/staff_roles.dart';
import 'package:clinic_pro/core/services/i_auth_services.dart';
import 'package:clinic_pro/core/services/i_cloud_service.dart';
import 'package:clinic_pro/features/staff_and_invitations/data/models/invitation_model.dart';
import 'package:clinic_pro/features/staff_and_invitations/data/models/staff_model.dart';

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
    // 1. جلب سجل الموظف لمعرفة الـ user_id والـ clinic_id والدور
    final staffRows = await iCloudService.select(
      table: table,
      eq: {'id': staffId},
    );
    if (staffRows.isEmpty) return;

    final userId = staffRows.first['user_id'] as String;
    final roleStr = staffRows.first['role'] as String;

    // 2. جلب جميع ارتباطات السكرتير بالأطباء
    final doctorPairings = roleStr == StaffRoles.secretary.name
        ? await iCloudService.select(
            table: SupabaseTables.doctorSecretaries,
            eq: {'secretary_id': userId},
          )
        : const <Map<String, dynamic>>[];

    // 3. التحقق من وجود أي سجلات عيادات للموظف في جدول clinic_staff
    final staffClinics = await iCloudService.select(
      table: table,
      eq: {'user_id': userId},
    );

    // 4. الحذف النهائي من جدول users والـ Auth فقط إذا كان مسجلاً في عيادة واحدة ولديه ارتباط بطبيب واحد على الأكثر
    if (staffClinics.length <= 1 && doctorPairings.length <= 1) {
      // أ. حذفه من جدول users (سيقوم السيرفر بحذف باقي بياناته تلقائياً بفضل الـ ON DELETE CASCADE)
      await iCloudService.delete(
        table: SupabaseTables.users,
        matchColumn: 'id',
        matchValue: userId,
      );

      // ب. حذفه من الـ Auth سحابياً
      try {
        await iAuthServices.deleteUserFromAuth(userId);
      } catch (e) {
        print('⚠️ فشل حذف حساب الموظف من الـ Auth: $e');
      }
    } else {
      // 5. إذا كان مسجلاً في عيادات أو مع أطباء آخرين، نكتفي بحذف السجل الحالي فقط من العيادة
      if (roleStr == StaffRoles.secretary.name) {
        await iCloudService.delete(
          table: SupabaseTables.doctorSecretaries,
          matchColumn: 'secretary_id',
          matchValue: userId,
          // هنا يفضل تحديد الطبيب أو العيادة الحالية إن أمكن لتجنب حذف ارتباطاته بالأطباء في العيادات الأخرى
        );
      }

      await iCloudService.delete(
        table: table,
        matchColumn: "id",
        matchValue: staffId,
      );
    }
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
      table: SupabaseTables.users,
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
      if (userRows.any((u) => u['id'] == userId) &&
          !processedKeys.contains(key)) {
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

    final userRows =
        await iCloudService.select(table: SupabaseTables.users, eq: {"id": id});
    final userData = userRows.isNotEmpty ? userRows.first : <String, dynamic>{};

    final mergedJson = {
      ...cs,
      'users': userData,
    };
    return StaffModel.fromJson(mergedJson);
  }

  @override
  Future<void> inviteStaff(InvitationModel staff) async {
    // 1. إرسال بريد الدعوة عبر Supabase
    await iAuthServices.sendInvitation(staff.toJson());

    // // 2. توليد توكن آمن وموثوق لربطه بالدعوة
    // final secureToken = const Uuid().v4();
    // final invitationData = staff.copyWith(token: secureToken).toJson();

    // // 3. حفظ بيانات الدعوة في قاعدة البيانات
    // await iCloudService.insert(
    //     table: SupabaseTables.invitations, data: invitationData);
  }
}

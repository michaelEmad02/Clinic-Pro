// ────────────────────────────────────────────────────────
// مصدر بيانات التحقق من الهوية البعيد (AuthRemoteDataSource)
// ────────────────────────────────────────────────────────

import 'package:injectable/injectable.dart';
import '../../../../core/constants/staff_roles.dart';
import '../../../../core/services/i_auth_services.dart';
import '../../../../core/services/i_cloud_service.dart';
import '../../../../core/constants/supabase_constants.dart';
import '../models/auth_user_model.dart';
import '../../../staff/data/models/invitation_model.dart';

abstract class IAuthRemoteDataSource {
  Future<AuthUserModel?> getCurrentUser();
  Future<AuthUserModel> loginWithGoogle();
  Future<AuthUserModel> loginWithApple();
  Future<AuthUserModel> loginWithEmailAndPassword(
      String email, String password);
  Future<void> sendMagicLink(String email);
  Future<AuthUserModel> registerOwner({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String country,
    required String address,
  });
  Future<InvitationModel> getInvitationByToken(String token);
  Future<void> acceptInvitation(String token);
  Future<void> verifyEmail(String email, String token);
  Future<bool> isEmailVerified(String email);
  Future<void> logout();
}

@LazySingleton(as: IAuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements IAuthRemoteDataSource {
  final ICloudService _cloudService;
  final IAuthServices _authServices;

  AuthRemoteDataSourceImpl(this._cloudService, this._authServices);

  @override
  Future<AuthUserModel?> getCurrentUser() async {
    // 1. التحقق من وجود معرف الجلسة الفعالة
    final userId = await _authServices.getCurrentUserId();
    if (userId == null || userId.isEmpty) return null;

    final email = await _authServices.getCurrentUserEmail();

    // 2. البحث في جدول المالكين Owners
    final ownerResults = await _cloudService.select(
      table: SupabaseTables.owners,
      eq: {'id': userId},
    );

    if (ownerResults.isNotEmpty) {
      final ownerData = Map<String, dynamic>.from(ownerResults.first);
      ownerData['email'] = email;
      return AuthUserModel.fromJson(ownerData, StaffRoles.owner);
    }

    // 3. البحث في جدول الموظفين users
    final userResults = await _cloudService.select(
      table: SupabaseTables.users,
      eq: {'id': userId},
    );

    if (userResults.isEmpty) {
      // إذا لم يوجد في أي جدول نقوم بعمل تسجيل خروج لإنهاء الجلسة المعلقة
      await logout();
      return null;
    }

    final userData = Map<String, dynamic>.from(userResults.first);
    userData['email'] = email;

    // 4. جلب دور الموظف من جدول clinic_staff
    final staffResults = await _cloudService.select(
      table: 'clinic_staff',
      eq: {'user_id': userId},
    );

    StaffRoles staffRole =
        StaffRoles.doctor; // الافتراضي طبيب في حال عدم التحديد
    if (staffResults.isNotEmpty) {
      final roleStr = staffResults.first['role'] as String?;
      staffRole = StaffRoles.values.firstWhere((r) => r.name == roleStr);
      // if (roleStr == 'secretary') {
      //   staffRole = StaffRoles.secretary;
      // }
    }

    return AuthUserModel.fromJson(userData, staffRole);
  }

  @override
  Future<AuthUserModel> loginWithGoogle() async {
    await _authServices.signInWithGoogle();
    final user = await getCurrentUser();
    if (user == null) {
      throw Exception('فشل تسجيل الدخول: لم يتم العثور على بيانات المستخدم.');
    }
    return user;
  }

  @override
  Future<AuthUserModel> loginWithApple() async {
    await _authServices.signInWithApple();
    final user = await getCurrentUser();
    if (user == null) {
      throw Exception('فشل تسجيل الدخول: لم يتم العثور على بيانات المستخدم.');
    }
    return user;
  }

  @override
  Future<AuthUserModel> loginWithEmailAndPassword(
      String email, String password) async {
    await _authServices.signInWithEmailAndPassword(email, password);
    final user = await getCurrentUser();
    if (user == null) {
      throw Exception('فشل تسجيل الدخول: لم يتم العثور على بيانات المستخدم.');
    }
    return user;
  }

  @override
  Future<void> sendMagicLink(String email) {
    return _authServices.sendMagicLink(email);
  }

  @override
  Future<AuthUserModel> registerOwner({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String country,
    required String address,
  }) async {
    await _authServices.signUp(email, password, phone, country);
    final userId = await _authServices.getCurrentUserId();
    if (userId == null) {
      throw Exception('يجب تسجيل الدخول بالبريد أولاً لإنشاء الحساب.');
    }

    final ownerData = {
      'id': userId,
      'name': name,
      'phone': phone,
      'country': country,
      'address': address,
    };

    final inserted = await _cloudService.insert(
      table: SupabaseTables.owners,
      data: ownerData,
    );

    final fullData = Map<String, dynamic>.from(inserted);
    fullData['email'] = email;

    return AuthUserModel.fromJson(fullData, StaffRoles.owner);
  }

  @override
  Future<InvitationModel> getInvitationByToken(String token) async {
    final results = await _cloudService.select(
      table: 'invitations',
      eq: {'token': token},
    );

    if (results.isEmpty) {
      throw Exception('الدعوة غير موجودة أو منتهية الصلاحية.');
    }

    final invitationData = Map<String, dynamic>.from(results.first);

    // جلب اسم العيادة للعرض في الواجهة
    final clinicId = invitationData['clinic_id'] as String;
    final clinicResults = await _cloudService.select(
      table: 'clinics',
      eq: {'id': clinicId},
    );
    if (clinicResults.isNotEmpty) {
      invitationData['clinic_name'] = clinicResults.first['name'];
    }

    return InvitationModel.fromJson(invitationData);
  }

  @override
  Future<void> acceptInvitation(String token) async {
    final invitation = await getInvitationByToken(token);
    final userId = await _authServices.getCurrentUserId();
    if (userId == null) {
      throw Exception('يجب تسجيل الدخول أولاً لقبول الدعوة.');
    }

    // 1. إنشاء حساب الموظف في جدول users
    final userResults = await _cloudService.select(
      table: SupabaseTables.users,
      eq: {'id': userId},
    );

    if (userResults.isEmpty) {
      await _cloudService.insert(
        table: SupabaseTables.users,
        data: {
          'id': userId,
          'owner_id': invitation.ownerId,
          'name': invitation.name ?? 'موظف عيادة',
          'is_active': true,
        },
      );
    }

    // 2. إضافته لطاقم العيادة clinic_staff
    final staffResults = await _cloudService.select(
      table: 'clinic_staff',
      eq: {'clinic_id': invitation.clinicId, 'user_id': userId},
    );

    if (staffResults.isEmpty) {
      await _cloudService.insert(
        table: 'clinic_staff',
        data: {
          'clinic_id': invitation.clinicId,
          'user_id': userId,
          'role': invitation.role.name,
          'is_active': true,
        },
      );
    }

    // 3. تحديث حالة الدعوة إلى مقبولة accepted
    await _cloudService.update(
      table: 'invitations',
      data: {'status': 'accepted'},
      matchColumn: 'id',
      matchValue: invitation.id,
    );
  }

  @override
  Future<void> verifyEmail(String email, String token) {
    return _authServices.verifyEmail(email, token);
  }

  @override
  Future<bool> isEmailVerified(String email) {
    return _authServices.isEmailVerified(email);
  }

  @override
  Future<void> logout() {
    return _authServices.signOut();
  }
}

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

    final email = await _authServices.getCurrentUserEmail() ?? '';

    // 2. البحث في جدول المالكين Owners
    var ownerResults = await _cloudService.select(
      table: SupabaseTables.owners,
      eq: {'id': userId},
    );

    // 3. البحث في جدول الموظفين users
    var userResults = await _cloudService.select(
      table: SupabaseTables.users,
      eq: {'id': userId},
    );

    // 4. إذا لم يكن للمستخدم أي سجلات في قاعدة البيانات ولكن لديه جلسة Auth (حالة تسجيل دخول خارجي جديدة)
    if (ownerResults.isEmpty && userResults.isEmpty && email.isNotEmpty) {
      // أ. التحقق من وجود دعوة معلقة (Pending Invitation) مقترنة بهذا البريد الإلكتروني
      final invitationResults = await _cloudService.select(
        table: SupabaseTables.invitations,
        eq: {'email': email, 'status': InvitationStatus.pending},
      );

      if (invitationResults.isNotEmpty) {
        // تم العثور على دعوة معلقة لهذا البريد الإلكتروني
        final invitationData = Map<String, dynamic>.from(invitationResults.first);
        final ownerId = invitationData['owner_id'] as String;
        final clinicId = invitationData['clinic_id'] as String;
        final roleStr = invitationData['role'] as String;
        final displayName = invitationData['name'] as String? ?? (email.split('@').first);

        // إنشاء حساب الموظف في جدول users
        await _cloudService.insert(
          table: SupabaseTables.users,
          data: {
            'id': userId,
            'owner_id': ownerId,
            'name': displayName,
            'phone': '',
            'address': '',
            'is_active': true,
          },
        );

        // إضافته لطاقم العيادة clinic_staff
        await _cloudService.insert(
          table: SupabaseTables.clinicStaff,
          data: {
            'clinic_id': clinicId,
            'user_id': userId,
            'role': roleStr,
            'is_active': true,
          },
        );

        // إذا كان الموظف سكرتير، يتم ربطه بالطبيب
        final doctorId = invitationData['doctor_id'] as String?;
        if (roleStr == StaffRoles.secretary.name && doctorId != null) {
          await _cloudService.insert(
            table: SupabaseTables.doctorSecretaries,
            data: {
              'clinic_id': clinicId,
              'doctor_id': doctorId,
              'secretary_id': userId,
            },
          );
        }

        // تحديث حالة الدعوة إلى مقبولة (accepted)
        await _cloudService.update(
          table: SupabaseTables.invitations,
          data: {'status': InvitationStatus.accepted},
          matchColumn: 'id',
          matchValue: invitationData['id'],
        );

        // إعادة جلب السجلات المحدثة
        userResults = await _cloudService.select(
          table: SupabaseTables.users,
          eq: {'id': userId},
        );
      } else {
        // لا توجد دعوات معلقة، يتم تسجيله كـ مالك جديد
        final googleName = await _authServices.getCurrentUserName();
        final displayName = (googleName != null && googleName.isNotEmpty) 
            ? googleName 
            : (email.isNotEmpty ? email.split('@').first : 'Google User');

        // إدراج المالك الجديد
        await _cloudService.insert(
          table: SupabaseTables.owners,
          data: {
            'id': userId,
            'name': displayName,
            'phone': '',
            'country': '',
            'address': '',
          },
        );

        // إدراج الموظف المرتبط به كطبيب - مالك
        await _cloudService.insert(
          table: SupabaseTables.users,
          data: {
            'id': userId,
            'owner_id': userId,
            'name': displayName,
            'phone': '',
            'address': '',
            'specialty': 'طبيب - مالك',
            'is_active': true,
          },
        );

        // إعادة جلب السجلات المحدثة
        ownerResults = await _cloudService.select(
          table: SupabaseTables.owners,
          eq: {'id': userId},
        );
      }
    }

    // 5. بناء كائن المستخدم المرجّع بناءً على نوع الحساب
    if (ownerResults.isNotEmpty) {
      final ownerData = Map<String, dynamic>.from(ownerResults.first);
      ownerData['email'] = email;
      return AuthUserModel.fromJson(ownerData, StaffRoles.owner);
    }

    if (userResults.isNotEmpty) {
      final userData = Map<String, dynamic>.from(userResults.first);
      userData['email'] = email;

      final staffResults = await _cloudService.select(
        table: SupabaseTables.clinicStaff,
        eq: {'user_id': userId},
      );

      StaffRoles staffRole = StaffRoles.doctor;
      if (staffResults.isNotEmpty) {
        staffRole = StaffRoles.fromString(staffResults.first['role'] as String?);
      }

      return AuthUserModel.fromJson(userData, staffRole);
    }

    // إذا لم يوجد في أي جدول نقوم بعمل تسجيل خروج لإنهاء الجلسة المعلقة
    await logout();
    return null;
  }

  @override
  Future<AuthUserModel> loginWithGoogle() async {
    // 1. تسجيل الدخول عبر الخدمات السحابية لمصادقة جوجل (تنتظر اختيار الحساب محلياً)
    await _authServices.signInWithGoogle();

    // 2. استدعاء تهيئة البيانات والحساب فوراً بعد اكتمال تسجيل الدخول
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
    

    final userData = {
      'id': userId,
      'owner_id': userId,
      'name': name,
      'phone': phone,
      'address': address,
      'specialty': 'طبيب - مالك',
      'is_active': true,
    };

    await _cloudService.insert(
      table: SupabaseTables.users,
      data: userData,
    );

    final fullData = Map<String, dynamic>.from(inserted);
    fullData['email'] = email;
    var user = AuthUserModel.fromJson(fullData, StaffRoles.owner);
    return user;
  }

  @override
  Future<InvitationModel> getInvitationByToken(String token) async {
    final results = await _cloudService.select(
      table: SupabaseTables.invitations,
      eq: {'token': token},
    );

    if (results.isEmpty) {
      throw Exception('الدعوة غير موجودة أو منتهية الصلاحية.');
    }

    final invitationData = Map<String, dynamic>.from(results.first);

    // جلب اسم العيادة للعرض في الواجهة
    final clinicId = invitationData['clinic_id'] as String;
    final clinicResults = await _cloudService.select(
      table: SupabaseTables.clinics,
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
      table: SupabaseTables.clinicStaff,
      eq: {'clinic_id': invitation.clinicId, 'user_id': userId},
    );

    if (staffResults.isEmpty) {
      await _cloudService.insert(
        table: SupabaseTables.clinicStaff,
        data: {
          'clinic_id': invitation.clinicId,
          'user_id': userId,
          'role': invitation.role.name,
          'is_active': true,
        },
      );
    }

    // إذا كان الموظف سكرتير، يتم ربطه بالطبيب
    if (invitation.role == StaffRoles.secretary && invitation.doctorId != null) {
      final docSecCheck = await _cloudService.select(
        table: SupabaseTables.doctorSecretaries,
        eq: {
          'clinic_id': invitation.clinicId,
          'doctor_id': invitation.doctorId,
          'secretary_id': userId,
        },
      );

      if (docSecCheck.isEmpty) {
        await _cloudService.insert(
          table: SupabaseTables.doctorSecretaries,
          data: {
            'clinic_id': invitation.clinicId,
            'doctor_id': invitation.doctorId,
            'secretary_id': userId,
          },
        );
      }
    }

    // 3. تحديث حالة الدعوة إلى مقبولة accepted
    await _cloudService.update(
      table: SupabaseTables.invitations,
      data: {'status': InvitationStatus.accepted},
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

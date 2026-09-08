// ────────────────────────────────────────────────────────
// مصدر بيانات التحقق من الهوية البعيد (AuthRemoteDataSource)
// ────────────────────────────────────────────────────────

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/constants/staff_roles.dart';
import '../../../../core/services/i_auth_services.dart';
import '../../../../core/services/i_cloud_service.dart';
import '../../../../core/constants/supabase_constants.dart';
import '../models/auth_user_model.dart';
import '../../../staff_and_invitations/data/models/invitation_model.dart';

abstract class IAuthRemoteDataSource {
  Future<AuthUserModel?> getCurrentUser();
  Future<AuthUserModel> loginWithGoogle();
  Future<AuthUserModel> loginWithApple();
  Future<AuthUserModel> loginWithEmailAndPassword(
      String email, String password);
  Future<void> sendMagicLink(String email);
  Future<void> sendPasswordResetEmail(String email);
  Future<void> updatePassword(String newPassword);
  Future<AuthUserModel> registerOwner({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String country,
    required String address,
  });
  Future<InvitationModel> getInvitationByToken(String token);
  Future<void> acceptInvitation(
    String token, {
    String? name,
    String? phone,
    String? address,
    String? specialty,
  });
  Future<void> acceptInvitationWithPassword({
    required String token,
    required String email,
    required String password,
    String? name,
    String? phone,
    String? address,
    String? specialty,
  });
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
        // تم العثور على دعوة معلقة لهذا البريد الإلكتروني — استخدام الـ RPC بصلاحيات السيرفر الآمنة (SECURITY DEFINER)
        final invitationData = Map<String, dynamic>.from(invitationResults.first);
        final token = invitationData['token'] as String;
        final displayName = invitationData['name'] as String? ?? (email.split('@').first);

        try {
          final rpcRes = await _cloudService.rpc(
            'accept_staff_invitation',
            params: {
              'p_token': token,
              'p_user_id': userId,
              'p_name': displayName,
            },
          );
          if (rpcRes != null && rpcRes is Map && rpcRes['success'] == false) {
            debugPrint('⚠️ RPC فشلت من السيرفر: ${rpcRes['message']}');
            throw Exception(rpcRes['message']);
          }
        } catch (e) {
          debugPrint('⚠️ RPC فشلت، استخدام fallback مباشر: $e');

          // Fallback: إدراج مباشر في الجداول عند فشل الـ RPC (مثلاً بسبب RLS)
          try {
            await _cloudService.insert(
              table: SupabaseTables.users,
              data: {
                'id': userId,
                'owner_id': invitationData['owner_id'],
                'name': displayName,
                'is_active': true,
              },
            );
          } catch (_) {
            // قد يكون المستخدم موجوداً بالفعل في جدول users
          }

          try {
            await _cloudService.insert(
              table: SupabaseTables.clinicStaff,
              data: {
                'clinic_id': invitationData['clinic_id'],
                'user_id': userId,
                'role': invitationData['role'],
                'is_active': true,
              },
            );
          } catch (_) {}

          // ربط السكرتير بالطبيب إذا كان الدور سكرتير
          if (invitationData['role'] == 'secretary' && invitationData['doctor_id'] != null) {
            try {
              await _cloudService.insert(
                table: SupabaseTables.doctorSecretaries,
                data: {
                  'clinic_id': invitationData['clinic_id'],
                  'doctor_id': invitationData['doctor_id'],
                  'secretary_id': userId,
                },
              );
            } catch (_) {}
          }

          // تحديث حالة الدعوة إلى مقبولة
          try {
            await _cloudService.update(
              table: SupabaseTables.invitations,
              data: {'status': 'accepted'},
              matchColumn: 'id',
              matchValue: invitationData['id'],
            );
          } catch (_) {}
        }

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
        final ownerData = {
          'id': userId,
          'name': displayName,
          'phone': '',
          'country': '',
          'address': '',
        };
        await _cloudService.insert(
          table: SupabaseTables.owners,
          data: ownerData,
        );

        // إدراج الموظف المرتبط به كطبيب - مالك
        final userData = {
          'id': userId,
          'owner_id': userId,
          'name': displayName,
          'phone': '',
          'address': '',
          'specialty': 'طبيب - مالك',
          'is_active': true,
        };
        await _cloudService.insert(
          table: SupabaseTables.users,
          data: userData,
        );

        // إرجاع النموذج مباشرةً بدون طلبات SELECT إضافية توفيراً للوقت والموارد
        final returnedUserData = Map<String, dynamic>.from(userData);
        returnedUserData['email'] = email;
        return AuthUserModel.fromJson(returnedUserData, StaffRoles.owner, isNewUser: true);
      }
    }

    StaffRoles staffRole = StaffRoles.owner;

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

      if (ownerResults.isEmpty && staffResults.isNotEmpty) {
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
  Future<void> sendPasswordResetEmail(String email) {
    return _authServices.resetPassword(email);
  }

  @override
  Future<void> updatePassword(String newPassword) {
    return _authServices.updatePassword(newPassword);
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
    // 1. محاولة استدعاء دالة الـ RPC السحابية get_invitation_by_token
    // تعمل بصلاحيات SECURITY DEFINER لتجاوز قيود الـ RLS وجلب اسم العيادة والطبيب بأمان
    try {
      final rpcRes = await _cloudService.rpc(
        'get_invitation_by_token',
        params: {'p_token': token},
      );
      if (rpcRes != null && rpcRes is Map) {
        final rpcMap = Map<String, dynamic>.from(rpcRes);
        if (rpcMap['success'] == true) {
          return InvitationModel.fromJson(rpcMap);
        } else if (rpcMap.containsKey('message')) {
          throw Exception(rpcMap['message']);
        }
      }
    } catch (e) {
      debugPrint('⚠️ تعذر جلب تفاصيل الدعوة عبر الـ RPC، التبديل للاستعلام المباشر: $e');
    }

    // 2. الاستعلام المباشر كحل احتياطي (Fallback)
    final results = await _cloudService.select(
      table: SupabaseTables.invitations,
      eq: {'token': token},
    );

    if (results.isEmpty) {
      throw Exception('الدعوة غير موجودة أو منتهية الصلاحية.');
    }

    final invitationData = Map<String, dynamic>.from(results.first);

    // محاولة جلب اسم العيادة
    try {
      final clinicId = invitationData['clinic_id'] as String;
      final clinicResults = await _cloudService.select(
        table: SupabaseTables.clinics,
        eq: {'id': clinicId},
      );
      if (clinicResults.isNotEmpty) {
        invitationData['clinic_name'] = clinicResults.first['name'];
      }
    } catch (_) {}

    // محاولة جلب اسم الطبيب المرتبط إذا كان الموظف سكرتيراً
    try {
      final doctorId = invitationData['doctor_id'] as String?;
      if (doctorId != null && doctorId.isNotEmpty) {
        final docResults = await _cloudService.select(
          table: SupabaseTables.users,
          eq: {'id': doctorId},
        );
        if (docResults.isNotEmpty) {
          invitationData['doctor_name'] = docResults.first['name'];
        }
      }
    } catch (_) {}

    return InvitationModel.fromJson(invitationData);
  }

  @override
  Future<void> acceptInvitation(
    String token, {
    String? name,
    String? phone,
    String? address,
    String? specialty,
  }) async {
    final userId = await _authServices.getCurrentUserId();
    if (userId == null || userId.isEmpty) {
      throw Exception('يجب تسجيل الدخول أولاً لقبول الدعوة.');
    }

    // 1. استدعاء دالة الـ RPC لقبول الدعوة في معاملة ذرية متكاملة
    try {
      final rpcRes = await _cloudService.rpc(
        'accept_staff_invitation',
        params: {
          'p_token': token,
          'p_user_id': userId,
          'p_name': name,
          'p_phone': phone,
          'p_address': address,
          'p_specialty': specialty,
        },
      );

      if (rpcRes != null && rpcRes is Map) {
        if (rpcRes['success'] == false) {
          throw Exception(rpcRes['message'] ?? 'فشل قبول الدعوة عبر السيرفر.');
        }
        return;
      }
    } catch (e) {
      // في حال لم تكن دالة الـ RPC منشأة بعد أو حدث استثناء، نستخدم المعالجة المحلية الاحتياطية
      final msg = e.toString();
      if (!msg.contains('function accept_staff_invitation') && !msg.contains('Could not find the function')) {
        rethrow;
      }
    }

    // Fallback: التنفيذ المباشر إذا لم تكن دالة الـ RPC مفعلة على السيرفر
    final invitation = await getInvitationByToken(token);
    final userResults = await _cloudService.select(
      table: SupabaseTables.users,
      eq: {'id': userId},
    );

    final finalName = (name != null && name.trim().isNotEmpty)
        ? name.trim()
        : (invitation.name ?? 'موظف عيادة');

    if (userResults.isEmpty) {
      await _cloudService.insert(
        table: SupabaseTables.users,
        data: {
          'id': userId,
          'owner_id': invitation.ownerId,
          'name': finalName,
          'phone': phone ?? '',
          'address': address ?? '',
          'specialty': specialty ?? '',
          'is_active': true,
        },
      );
    }

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
  Future<void> acceptInvitationWithPassword({
    required String token,
    required String email,
    required String password,
    String? name,
    String? phone,
    String? address,
    String? specialty,
  }) async {
    // 1. محاولة تسجيل مستخدم جديد أولاً
    try {
      await _authServices.signUp(email, password, '', '');
      // signUp في Supabase لا ينشئ session تلقائياً — لازم signIn
      await _authServices.signInWithEmailAndPassword(email, password);
    } catch (e) {
      final errStr = e.toString();

      // 2. الحساب موجود بالفعل — مستخدم سابق (عنده عيادة تانية مثلاً)
      if (errStr.contains('already registered') ||
          errStr.contains('User already registered')) {
        try {
          await _authServices.signInWithEmailAndPassword(email, password);
        } catch (signInErr) {
          final signInErrStr = signInErr.toString();
          if (signInErrStr.contains('Invalid login credentials') ||
              signInErrStr.contains('invalid_credentials')) {
            throw Exception(
              'هذا البريد مسجل بالفعل. يرجى إدخال كلمة المرور الصحيحة لحسابك.',
            );
          }
          rethrow;
        }
      } else if (errStr.contains('email_not_confirmed')) {
        // الحساب موجود لكن الإيميل مش متأكد — نسجل دخول مباشرة
        await _authServices.signInWithEmailAndPassword(email, password);
      } else {
        rethrow;
      }
    }

    // 3. قبول الدعوة وربط الحساب بالعيادة عبر الـ RPC
    await acceptInvitation(
      token,
      name: name,
      phone: phone,
      address: address,
      specialty: specialty,
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

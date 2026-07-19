// ────────────────────────────────────────────────────────
// محاكاة خدمات المصادقة (MockAuthServices)
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/constants/supabase_constants.dart';
import 'package:clinic_pro/core/di/injection_container.dart';
import 'package:clinic_pro/core/services/i_cloud_service.dart';
import 'i_auth_services.dart';


class MockAuthServices implements IAuthServices {
  String? _currentUserId; // افتراضياً، المالك مسجل دخوله للمحاكاة
  String? _currentUserEmail;

  @override
  Future<String?> getCurrentUserId() async {
    return _currentUserId;
  }

  @override
  Future<String?> getCurrentUserEmail() async {
    return _currentUserEmail;
  }

  @override
  Future<String?> getCurrentUserName() async {
    return 'Mock User';
  }

  @override
  Future<void> signInWithGoogle() async {
    _currentUserId = 'u-owner-1';
    _currentUserEmail = 'owner@clinicpro.com';
  }

  @override
  Future<void> signInWithApple() async {
    _currentUserId = 'u-owner-1';
    _currentUserEmail = 'owner@clinicpro.com';
  }

  @override
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    if (email == 'error@clinicpro.com') {
      throw Exception('بيانات الدخول غير صحيحة');
    }
    var users = await sl<ICloudService>()
        .select(table: SupabaseTables.users, eq: {'email': email});
    final data = Map<String, dynamic>.from(users.first);
    _currentUserId = data['id'];
    _currentUserEmail = email;
  }

  @override
  Future<void> sendMagicLink(String email) async {
    if (email.isEmpty) {
      throw Exception('البريد الإلكتروني مطلوب');
    }
  }

  @override
  Future<void> verifyEmail(String email, String token) async {
    if (token == '000000') {
      throw Exception('رمز التحقق غير صحيح أو منتهي الصلاحية');
    }
    _currentUserId = 'u-owner-1';
    _currentUserEmail = email;
  }

  @override
  Future<bool> isEmailVerified(String email) async {
    return email != 'unverified@clinicpro.com';
  }

  @override
  Future<void> signOut() async {
    _currentUserId = null;
    _currentUserEmail = null;
  }

  @override
  Future<void> resetPassword(String email) {
    // TODO: implement resetPassword
    throw UnimplementedError();
  }

  @override
  Future<void> updatePassword(String email, String password) {
    // TODO: implement updatePassword
    throw UnimplementedError();
  }

  @override
  Future<void> signUp(
      String email, String password, String phone, String country) {
    // TODO: implement signUp
    throw UnimplementedError();
  }

  @override
  Future<void> sendInvitation(Map<String, dynamic> metadata) {
    // TODO: implement sendInvitation
    throw UnimplementedError();
  }
}

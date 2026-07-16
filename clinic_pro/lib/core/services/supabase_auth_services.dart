import 'package:clinic_pro/core/services/i_auth_services.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@LazySingleton(as: IAuthServices)
class SupabaseAuthServices extends IAuthServices {
  final SupabaseClient supabase;

  SupabaseAuthServices(this.supabase);
  @override
  Future<String?> getCurrentUserEmail() async {
    return supabase.auth.currentUser?.email ?? "";
  }

  @override
  Future<String?> getCurrentUserId() async {
    return supabase.auth.currentUser?.id ?? "";
  }

  @override
  Future<bool> isEmailVerified(String email) {
    throw UnimplementedError();
  }

  @override
  Future<void> signUp(
      String email, String password, String phone, String country) async {
    var user = await supabase.auth.signUp(email: email, password: password);
  }

  @override
  Future<void> sendMagicLink(String email) async {
    return await supabase.auth.signInWithOtp(email: email);
  }

  @override
  Future<void> signInWithApple() {
    // TODO: implement signInWithApple
    throw UnimplementedError();
  }

  @override
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    await supabase.auth.signInWithPassword(email: email, password: password);
  }

  @override
  Future<void> signInWithGoogle() async {
    // TODO: implement signInWithGoogle
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  @override
  Future<void> verifyEmail(String email, String token) {
    // TODO: implement verifyEmail
    throw UnimplementedError();
  }

  @override
  Future<void> resetPassword(String email) async {
    await supabase.auth.resetPasswordForEmail(email);
  }

  @override
  Future<void> updatePassword(String email, String password) {
    return supabase.auth
        .updateUser(UserAttributes(email: email, password: password));
  }

  @override
  Future<void> sendInvitation(String email) async {
    await supabase.auth.admin.inviteUserByEmail(email);
  }
}

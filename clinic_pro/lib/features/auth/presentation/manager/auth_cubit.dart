import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/services/i_cloud_service.dart';
import 'auth_state.dart';

@injectable
class AuthCubit extends Cubit<AuthState> {
  final ICloudService _cloudService;

  AuthCubit(this._cloudService) : super(AuthInitial());

  Future<void> checkAuthStatus() async {
    emit(AuthLoading());
    await Future.delayed(const Duration(seconds: 2));
    // في مرحلة الـ UI نقوم دائماً ببدء التطبيق كغير مسجل الدخول
    emit(AuthUnauthenticated());
  }

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final users = await _cloudService.select(table: 'users');
      
      // محاكاة تسجيل الدخول: الحصول على مالك العيادة كمثال للـ Mock
      final user = users.firstWhere(
        (u) => u['role'] == 'owner',
        orElse: () => users.first,
      );
      
      emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(const AuthError(message: 'فشل تسجيل الدخول. يرجى المحاولة مرة أخرى.'));
    }
  }

  Future<void> logout() async {
    emit(AuthLoading());
    await Future.delayed(const Duration(milliseconds: 500));
    emit(AuthUnauthenticated());
  }
}

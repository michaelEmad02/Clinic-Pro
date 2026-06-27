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

  /// تسجيل دخول بأي بيانات (Mock) — يدخل دائماً كمالك عيادة
  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    await Future.delayed(const Duration(milliseconds: 800));

    // بيانات وهمية للمالك — أي ايميل وباسوورد مقبولين
    emit(AuthAuthenticated(user: {
      'id': 'u-owner-1',
      'name': 'د. محمد عبد الرحمن',
      'email': email.isNotEmpty ? email : 'owner@clinicpro.com',
      'role': 'owner',
      'phone': '+201011111111',
    }));
  }

  /// تسجيل دخول بدور محدد (للاختبار)
  Future<void> loginAsRole(String role) async {
    emit(AuthLoading());
    await Future.delayed(const Duration(milliseconds: 600));

    final Map<String, Map<String, dynamic>> mockUsers = {
      'owner': {
        'id': 'u-owner-1',
        'name': 'د. محمد عبد الرحمن',
        'email': 'owner@clinicpro.com',
        'role': 'owner',
      },
      'doctor': {
        'id': 'u-doc-1',
        'name': 'د. ياسر مصطفى',
        'email': 'yasser@clinicpro.com',
        'role': 'doctor',
      },
      'secretary': {
        'id': 'u-sec-1',
        'name': 'أ. سارة أحمد',
        'email': 'sara@clinicpro.com',
        'role': 'secretary',
      },
    };

    final user = mockUsers[role] ?? mockUsers['owner']!;
    emit(AuthAuthenticated(user: user));
  }

  /// إنشاء حساب جديد (Mock) — يسجل ويعيد بيانات مالك جديد
  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    emit(AuthLoading());
    await Future.delayed(const Duration(milliseconds: 800));

    // في مرحلة الـ Mock يتم إنشاء الحساب بنجاح دائماً
    emit(AuthAuthenticated(user: {
      'id': 'u-new-owner',
      'name': name.isNotEmpty ? name : 'مالك جديد',
      'email': email.isNotEmpty ? email : 'new@clinicpro.com',
      'role': 'owner',
      'phone': phone,
    }));
  }

  Future<void> logout() async {
    emit(AuthLoading());
    await Future.delayed(const Duration(milliseconds: 500));
    emit(AuthUnauthenticated());
  }
}


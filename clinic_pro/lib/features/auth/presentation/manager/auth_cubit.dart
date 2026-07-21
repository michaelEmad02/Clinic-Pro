// ────────────────────────────────────────────────────────
// متحكم حالة التحقق من الهوية (AuthCubit)
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/constants/staff_roles.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/use_cases/get_current_user_use_case.dart';
import '../../domain/use_cases/login_with_google_use_case.dart';
import '../../domain/use_cases/login_with_apple_use_case.dart';
import '../../domain/use_cases/login_with_email_and_password_use_case.dart';
import '../../domain/use_cases/register_owner_use_case.dart';
import '../../domain/use_cases/logout_use_case.dart';
import 'auth_state.dart';

@injectable
class AuthCubit extends Cubit<AuthState> {
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final LoginWithGoogleUseCase _loginWithGoogleUseCase;
  final LoginWithAppleUseCase _loginWithAppleUseCase;
  final LoginWithEmailAndPasswordUseCase _loginWithEmailAndPasswordUseCase;
  final RegisterOwnerUseCase _registerOwnerUseCase;
  final LogoutUseCase _logoutUseCase;

  /// الدور الأصلي للمستخدم (يُحفظ عند التبديل بين الأدوار)
  StaffRoles? _originalRole;

  /// هل المستخدم مالك أصلي يعمل حالياً بدور مختلف؟
  bool get isOwnerActingAsDoctor =>
      _originalRole == StaffRoles.owner &&
      state.user?.role == StaffRoles.doctor;

  /// الدور الأصلي للمستخدم
  StaffRoles? get originalRole => _originalRole;

  AuthCubit(
    this._getCurrentUserUseCase,
    this._loginWithGoogleUseCase,
    this._loginWithAppleUseCase,
    this._loginWithEmailAndPasswordUseCase,
    this._registerOwnerUseCase,
    this._logoutUseCase,
  ) : super(AuthInitial());

  /// التحقق من حالة الجلسة الحالية
  Future<void> checkAuthStatus() async {
    emit(AuthLoading());
    final result = await _getCurrentUserUseCase();
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (user) {
        if (user != null) {
          emit(AuthAuthenticated(user: user));
        } else {
          emit(AuthUnauthenticated());
        }
      },
    );
  }


  /// تسجيل دخول بالبريد الإلكتروني وكلمة المرور
  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    final result = await _loginWithEmailAndPasswordUseCase(
      email: email,
      password: password,
    );
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (user) => emit(AuthAuthenticated(user: user)),
    );
  }

  /// تسجيل دخول سريع بدور محدد للاختبار وتسهيل التطوير
  Future<void> loginAsRole(StaffRoles role) async {
    emit(AuthLoading());
    String email = 'owner@clinicpro.com';
    if (role == StaffRoles.doctor) {
      email = 'yasser@clinicpro.com';
    } else if (role == StaffRoles.secretary) {
      email = 'sara@clinicpro.com';
    }

    final result = await _loginWithEmailAndPasswordUseCase(
      email: email,
      password: 'mock_password',
    );
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (user) => emit(AuthAuthenticated(user: user)),
    );
  }

  /// تسجيل الدخول عبر Google
  Future<void> loginWithGoogle() async {
    emit(AuthLoading());
    final result = await _loginWithGoogleUseCase();
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (user) => emit(AuthAuthenticated(user: user)),
    );
  }

  /// تسجيل الدخول عبر Apple
  Future<void> loginWithApple() async {
    emit(AuthLoading());
    final result = await _loginWithAppleUseCase();
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (user) => emit(AuthAuthenticated(user: user)),
    );
  }

  /// إنشاء حساب جديد لمالك العيادة
  Future<void> register({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String country,
    required String address,
  }) async {
    emit(AuthLoading());
    final result = await _registerOwnerUseCase(
      email: email,
      password: password,
      name: name,
      phone: phone,
      country: country,
      address: address,
    );
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (user) => emit(AuthRegistrationSuccess(user: user)),
    );
  }

  /// تسجيل الخروج
  Future<void> logout() async {
    emit(AuthLoading());
    final result = await _logoutUseCase();
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (_) => emit(AuthUnauthenticated()),
    );
  }

  /// تحديث بيانات المستخدم الحالية محلياً لتنعكس على الواجهات
  void updateUserData({
    required String name,
    required String phone,
    String? address,
    String? imageUrl,
  }) {
    if (state is AuthAuthenticated) {
      final currentUser = (state as AuthAuthenticated).user;
      final updatedUser = currentUser.copyWith(
        name: name,
        phone: phone,
        address: address ?? currentUser.address,
        imageUrl: imageUrl ?? currentUser.imageUrl,
      );
      emit(AuthAuthenticated(user: updatedUser));
    }
  }

  /// تبديل الدور من مالك إلى طبيب (عرض لوحة تحكم الطبيب)
  void switchToDoctor() {
    if (state is AuthAuthenticated) {
      final currentUser = (state as AuthAuthenticated).user;
      // حفظ الدور الأصلي للعودة إليه لاحقاً
      _originalRole = currentUser.role;
      final updatedUser = currentUser.copyWith(role: StaffRoles.doctor);
      emit(AuthAuthenticated(user: updatedUser));
    }
  }

  /// العودة من دور الطبيب إلى دور المالك الأصلي
  void switchBackToOwner() {
    if (state is AuthAuthenticated && _originalRole == StaffRoles.owner) {
      final currentUser = (state as AuthAuthenticated).user;
      final updatedUser = currentUser.copyWith(role: StaffRoles.owner);
      _originalRole = null;
      emit(AuthAuthenticated(user: updatedUser));
    }
  }
}

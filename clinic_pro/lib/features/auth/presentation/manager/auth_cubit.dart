// ────────────────────────────────────────────────────────
// متحكم حالة التحقق من الهوية (AuthCubit)
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/constants/staff_roles.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../plans_and_subscriptions/domain/entities/subscription_entity.dart';
import '../../../plans_and_subscriptions/domain/usecases/subscriptions_usecases.dart';
import '../../domain/use_cases/get_current_user_use_case.dart';
import '../../domain/use_cases/login_with_google_use_case.dart';
import '../../domain/use_cases/login_with_apple_use_case.dart';
import '../../domain/use_cases/login_with_email_and_password_use_case.dart';
import '../../domain/use_cases/register_owner_use_case.dart';
import '../../domain/use_cases/logout_use_case.dart';
import '../../domain/use_cases/send_password_reset_email_use_case.dart';
import '../../domain/use_cases/update_password_use_case.dart';
import '../../domain/entities/auth_user_entity.dart';
import 'auth_state.dart';

@injectable
class AuthCubit extends Cubit<AuthState> {
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final LoginWithGoogleUseCase _loginWithGoogleUseCase;
  final LoginWithAppleUseCase _loginWithAppleUseCase;
  final LoginWithEmailAndPasswordUseCase _loginWithEmailAndPasswordUseCase;
  final RegisterOwnerUseCase _registerOwnerUseCase;
  final LogoutUseCase _logoutUseCase;
  final CheckSubscriptionStatusUseCase _checkSubscriptionStatusUseCase;
  final SendPasswordResetEmailUseCase _sendPasswordResetEmailUseCase;
  final UpdatePasswordUseCase _updatePasswordUseCase;

  /// الدور الأصلي للمستخدم (يُحفظ عند التبديل بين الأدوار)
  StaffRoles? _originalRole;

  /// هل المستخدم مالك أصلي يعمل حالياً بدور مختلف؟
  bool get isOwnerActingAsDoctor =>
      _originalRole == StaffRoles.owner &&
      state.user?.role == StaffRoles.doctor;

  /// الدور الأصلي للمستخدم
  StaffRoles? get originalRole => _originalRole;

  /// هل التطبيق في وضع القراءة فقط لانتهاء الاشتراك؟
  bool get isReadOnlyMode {
    if (state is AuthAuthenticated) {
      return (state as AuthAuthenticated).isReadOnlyMode;
    }
    return false;
  }

  /// تفعيل وضع القراءة فقط عند انتهاء الاشتراك لمتابعة التصفح
  void enterReadOnlyMode() {
    if (state is AuthAuthenticated) {
      final curr = state as AuthAuthenticated;
      emit(curr.copyWith(isReadOnlyMode: true));
    }
  }

  AuthCubit(
    this._getCurrentUserUseCase,
    this._loginWithGoogleUseCase,
    this._loginWithAppleUseCase,
    this._loginWithEmailAndPasswordUseCase,
    this._registerOwnerUseCase,
    this._logoutUseCase,
    this._checkSubscriptionStatusUseCase,
    this._sendPasswordResetEmailUseCase,
    this._updatePasswordUseCase,
  ) : super(AuthInitial());

  /// بناء حالة المصادقة المكتملة مع فحص الاشتراك ووضع القراءة فقط لجميع الأدوار
  Future<AuthAuthenticated> _buildAuthenticatedState(AuthUserEntity user) async {
    SubscriptionEntity? activeSub;
    final targetOwnerId = (user.role == StaffRoles.owner)
        ? user.id
        : (user.ownerId ?? user.id);

    final subResult = await _checkSubscriptionStatusUseCase(targetOwnerId);
    subResult.fold((_) => null, (sub) => activeSub = sub);

    // تفعيل وضع القراءة فقط تلقائياً إذا لم يكن هناك اشتراك نشط أو انتهت صلاحيته
    final bool isReadOnly =
        activeSub == null || !activeSub!.isActive || activeSub!.isExpired;

    return AuthAuthenticated(
      user: user,
      activeSubscription: activeSub,
      isReadOnlyMode: isReadOnly,
    );
  }

  /// التحقق من حالة الجلسة الحالية
  Future<void> checkAuthStatus() async {
    emit(AuthLoading());
    final result = await _getCurrentUserUseCase();
    await result.fold(
      (failure) async => emit(AuthError(message: failure.message)),
      (user) async {
        if (user != null) {
          final authState = await _buildAuthenticatedState(user);
          emit(authState);
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
    await result.fold(
      (failure) async => emit(AuthError(message: failure.message)),
      (user) async {
        final authState = await _buildAuthenticatedState(user);
        emit(authState);
      },
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
    await result.fold(
      (failure) async => emit(AuthError(message: failure.message)),
      (user) async {
        final authState = await _buildAuthenticatedState(user);
        emit(authState);
      },
    );
  }

  /// تسجيل الدخول عبر Google
  Future<void> loginWithGoogle() async {
    emit(AuthLoading());
    final result = await _loginWithGoogleUseCase();
    await result.fold(
      (failure) async => emit(AuthError(message: failure.message)),
      (user) async {
        final authState = await _buildAuthenticatedState(user);
        emit(authState);
      },
    );
  }

  /// تسجيل الدخول عبر Apple
  Future<void> loginWithApple() async {
    emit(AuthLoading());
    final result = await _loginWithAppleUseCase();
    await result.fold(
      (failure) async => emit(AuthError(message: failure.message)),
      (user) async {
        final authState = await _buildAuthenticatedState(user);
        emit(authState);
      },
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

  /// إرسال رابط إعادة تعيين كلمة المرور
  Future<void> sendPasswordResetEmail(String email) async {
    emit(AuthLoading());
    final result = await _sendPasswordResetEmailUseCase(email);
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (_) => emit(AuthPasswordResetSent(email: email)),
    );
  }

  /// تعيين وتحديث كلمة المرور الجديدة
  Future<void> updatePassword(String newPassword) async {
    emit(AuthLoading());
    final result = await _updatePasswordUseCase(newPassword);
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (_) => emit(AuthPasswordUpdatedSuccess()),
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

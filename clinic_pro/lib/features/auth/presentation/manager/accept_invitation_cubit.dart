// ────────────────────────────────────────────────────────
// متحكم حالة قبول الدعوة (AcceptInvitationCubit)
// يدير تدفق: تحميل الدعوة → التحقق → تسجيل الدخول → القبول
// ────────────────────────────────────────────────────────

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/constants/supabase_constants.dart';
import '../../domain/use_cases/get_invitation_by_token_use_case.dart';
import '../../domain/use_cases/accept_invitation_use_case.dart';
import '../../domain/use_cases/login_with_google_use_case.dart';
import '../../domain/use_cases/login_with_apple_use_case.dart';
import '../../domain/use_cases/logout_use_case.dart';
import '../../../staff/domain/entities/invitation_entity.dart';
import 'accept_invitation_state.dart';

@injectable
class AcceptInvitationCubit extends Cubit<AcceptInvitationState> {
  final GetInvitationByTokenUseCase _getInvitationByTokenUseCase;
  final AcceptInvitationUseCase _acceptInvitationUseCase;
  final LoginWithGoogleUseCase _loginWithGoogleUseCase;
  final LoginWithAppleUseCase _loginWithAppleUseCase;
  final LogoutUseCase _logoutUseCase;

  /// يُخزَّن التوكن لاستخدامه عند القبول لاحقاً
  String? _currentToken;
  InvitationEntity? _currentInvitation;

  AcceptInvitationCubit(
    this._getInvitationByTokenUseCase,
    this._acceptInvitationUseCase,
    this._loginWithGoogleUseCase,
    this._loginWithAppleUseCase,
    this._logoutUseCase,
  ) : super(AcceptInvitationInitial());

  /// تحميل بيانات الدعوة والتحقق من صلاحيتها
  Future<void> loadInvitation(String token) async {
    _currentToken = token;
    emit(AcceptInvitationLoading());

    // عمل تسجيل خروج لأي جلسة سابقة نشطة لضمان بدء عملية القبول بحساب نظيف
    await _logoutUseCase();

    final result = await _getInvitationByTokenUseCase(token);

    result.fold(
      (failure) => emit(AcceptInvitationError(message: failure.message)),
      (invitation) {
        _currentInvitation = invitation;

        // التحقق من حالة الدعوة
        if (invitation.status == InvitationStatus.accepted) {
          emit(const AcceptInvitationAlreadyAccepted());
          return;
        }

        if (invitation.status == InvitationStatus.expired ||
            invitation.status == InvitationStatus.cancelled) {
          emit(const AcceptInvitationExpired());
          return;
        }

        // التحقق من انتهاء الصلاحية الزمنية (7 أيام)
        if (DateTime.now().isAfter(invitation.expiredAt)) {
          emit(const AcceptInvitationExpired(
            message: 'انتهت صلاحية هذه الدعوة. يرجى التواصل مع مالك العيادة.',
          ));
          return;
        }

        // الدعوة صالحة — عرض التفاصيل
        emit(AcceptInvitationLoaded(invitation: invitation));
      },
    );
  }

  /// تسجيل الدخول عبر Google ثم قبول الدعوة تلقائياً
  Future<void> acceptWithGoogle() async {
    if (_currentToken == null) return;
    emit(AcceptInvitationAccepting());

    // 1. تسجيل الدخول بجوجل
    final loginResult = await _loginWithGoogleUseCase();

    await loginResult.fold(
      (failure) async =>
          emit(AcceptInvitationError(message: failure.message)),
      (user) async {
        // 2. قبول الدعوة (إنشاء user + clinic_staff + تحديث status)
        final acceptResult =
            await _acceptInvitationUseCase(_currentToken!);

        acceptResult.fold(
          (failure) =>
              emit(AcceptInvitationError(message: failure.message)),
          (_) => emit(AcceptInvitationSuccess(
            role: _currentInvitation?.role.name ?? 'doctor',
            clinicName: _currentInvitation?.clinicName ?? '',
          )),
        );
      },
    );
  }

  /// تسجيل الدخول عبر Apple ثم قبول الدعوة تلقائياً
  Future<void> acceptWithApple() async {
    if (_currentToken == null) return;
    emit(AcceptInvitationAccepting());

    final loginResult = await _loginWithAppleUseCase();

    await loginResult.fold(
      (failure) async =>
          emit(AcceptInvitationError(message: failure.message)),
      (user) async {
        final acceptResult =
            await _acceptInvitationUseCase(_currentToken!);

        acceptResult.fold(
          (failure) =>
              emit(AcceptInvitationError(message: failure.message)),
          (_) => emit(AcceptInvitationSuccess(
            role: _currentInvitation?.role.name ?? 'doctor',
            clinicName: _currentInvitation?.clinicName ?? '',
          )),
        );
      },
    );
  }
}

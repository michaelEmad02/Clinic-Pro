// ────────────────────────────────────────────────────────
// تنفيذ مستودع التحقق من الهوية (AuthRepositoryImpl)
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/error/auth_failure.dart';
import 'package:clinic_pro/features/staff_and_invitations/domain/entities/invitation_entity.dart';
import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/auth_user_entity.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../data_sources/auth_remote_data_source.dart';

@LazySingleton(as: IAuthRepository)
class AuthRepositoryImpl implements IAuthRepository {
  final IAuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, AuthUserEntity?>> getCurrentUser() async {
    try {
      final user = await _remoteDataSource.getCurrentUser();
      return Right(user);
    } catch (e) {
      return Left(AuthFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, AuthUserEntity>> loginWithGoogle() async {
    try {
      final user = await _remoteDataSource.loginWithGoogle();
      return Right(user);
    } catch (e) {
      return Left(AuthFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, AuthUserEntity>> loginWithApple() async {
    try {
      final user = await _remoteDataSource.loginWithApple();
      return Right(user);
    } catch (e) {
      return Left(AuthFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, AuthUserEntity>> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final user =
          await _remoteDataSource.loginWithEmailAndPassword(email, password);
      return Right(user);
    } catch (e) {
      return Left(AuthFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> sendMagicLink(String email) async {
    try {
      await _remoteDataSource.sendMagicLink(email);
      return const Right(unit);
    } catch (e) {
      return Left(AuthFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, AuthUserEntity>> registerOwner({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String country,
    required String address,
  }) async {
    try {
      final user = await _remoteDataSource.registerOwner(
        email: email,
        password: password,
        name: name,
        phone: phone,
        country: country,
        address: address,
      );
      return Right(user);
    } catch (e) {
      return Left(AuthFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, InvitationEntity>> getInvitationByToken(
      String token) async {
    try {
      final invitation = await _remoteDataSource.getInvitationByToken(token);
      return Right(invitation);
    } catch (e) {
      return Left(AuthFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> acceptInvitation(String token) async {
    try {
      await _remoteDataSource.acceptInvitation(token);
      return const Right(unit);
    } catch (e) {
      return Left(AuthFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, AuthUserEntity>> verifyEmail({
    required String email,
    required String token,
  }) async {
    try {
      await _remoteDataSource.verifyEmail(email, token);
      final user = await _remoteDataSource.getCurrentUser();
      if (user == null) {
        return const Left(EmailNotVerifiedFailure());
      }
      return Right(user);
    } catch (e) {
      return Left(AuthFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, bool>> isEmailVerified(String email) async {
    try {
      final isVerified = await _remoteDataSource.isEmailVerified(email);
      return Right(isVerified);
    } catch (e) {
      return Left(AuthFailure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    try {
      await _remoteDataSource.logout();
      return const Right(unit);
    } catch (e) {
      return Left(AuthFailure.fromException(e));
    }
  }
}

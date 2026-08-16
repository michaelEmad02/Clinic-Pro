// ────────────────────────────────────────────────────────
// حالات المصادقة (AuthState)
// ────────────────────────────────────────────────────────

import 'package:equatable/equatable.dart';
import '../../../plans_and_subscriptions/domain/entities/subscription_entity.dart';
import '../../domain/entities/auth_user_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  AuthUserEntity? get user => null;

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  @override
  final AuthUserEntity user;
  final SubscriptionEntity? activeSubscription;

  const AuthAuthenticated({
    required this.user,
    this.activeSubscription,
  });

  @override
  List<Object?> get props => [user, activeSubscription];
}

class AuthRegistrationSuccess extends AuthState {
  @override
  final AuthUserEntity user;

  const AuthRegistrationSuccess({required this.user});

  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}

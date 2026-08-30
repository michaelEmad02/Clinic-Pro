// ────────────────────────────────────────────────────────
// أخطاء الاتصال المباشر (RealtimeFailure)
// ────────────────────────────────────────────────────────
// ignore_for_file: deprecated_member_use

import 'package:clinic_pro/core/error/failures.dart';
import 'package:clinic_pro/core/strings/failure_strings.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class RealtimeFailure extends Failure {
  const RealtimeFailure({required String message}) : super(message);

  factory RealtimeFailure.fromException(Object e) {
    if (e is RealtimeSubscribeException) {
      return RealtimeFailure.fromRealtimeSubscribeException(e);
    }
    if (e is SupabaseRealtimeError) {
      return UnknownRealtimeFailure(
        message: Error.safeToString(e.message),
      );
    }
    return UnknownRealtimeFailure(message: e.toString());
  }

  factory RealtimeFailure.fromRealtimeSubscribeException(
      RealtimeSubscribeException e) {
    switch (e.status) {
      case RealtimeSubscribeStatus.channelError:
        return RealtimeChannelError(details: e.details);
      case RealtimeSubscribeStatus.timedOut:
        return const RealtimeTimedOut();
      case RealtimeSubscribeStatus.closed:
        return const RealtimeConnectionClosed();
      case RealtimeSubscribeStatus.subscribed:
        return const UnknownRealtimeFailure(
            message: 'Realtime Unexpected Error');
    }
  }
}

class RealtimeChannelError extends RealtimeFailure {
  final Object? details;

  RealtimeChannelError({this.details, String? message})
      : super(message: message ?? '');

  @override
  String get message =>
      super.message.isEmpty ? FailureStrings.realtimeChannelError : super.message;
}

class RealtimeTimedOut extends RealtimeFailure {
  const RealtimeTimedOut([String? message])
      : super(message: message ?? '');

  @override
  String get message =>
      super.message.isEmpty ? FailureStrings.realtimeTimedOut : super.message;
}

class RealtimeConnectionClosed extends RealtimeFailure {
  const RealtimeConnectionClosed([String? message])
      : super(message: message ?? '');

  @override
  String get message =>
      super.message.isEmpty ? FailureStrings.realtimeConnectionClosed : super.message;
}

class UnknownRealtimeFailure extends RealtimeFailure {
  const UnknownRealtimeFailure({required super.message});

  @override
  String get message => super.message == 'Realtime Unexpected Error'
      ? FailureStrings.realtimeUnexpected
      : super.message;
}

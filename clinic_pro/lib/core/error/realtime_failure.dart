// ────────────────────────────────────────────────────────
// أخطاء الاتصال المباشر (RealtimeFailure)
// ────────────────────────────────────────────────────────
// ignore_for_file: deprecated_member_use

import 'package:clinic_pro/core/error/failures.dart';
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
            message: 'خطأ غير متوقع في الاتصال المباشر.');
    }
  }
}

class RealtimeChannelError extends RealtimeFailure {
  final Object? details;

  RealtimeChannelError({this.details})
      : super(message: 'خطأ في قناة الاتصال المباشر.');
}

class RealtimeTimedOut extends RealtimeFailure {
  const RealtimeTimedOut()
      : super(message: 'انتهت مهلة الاتصال المباشر.');
}

class RealtimeConnectionClosed extends RealtimeFailure {
  const RealtimeConnectionClosed()
      : super(message: 'تم إغلاق الاتصال المباشر.');
}

class UnknownRealtimeFailure extends RealtimeFailure {
  const UnknownRealtimeFailure({required super.message});
}

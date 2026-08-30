// ────────────────────────────────────────────────────────
// تعريف الأخطاء العامة للتطبيق (Failures)
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/strings/failure_strings.dart';

abstract class Failure {
  final String _customMessage;
  const Failure([this._customMessage = '']);

  String get defaultMessage => FailureStrings.unknownError;

  String get message =>
      _customMessage.isNotEmpty ? _customMessage : defaultMessage;
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.customMessage]);

  @override
  String get defaultMessage => FailureStrings.networkError;
}

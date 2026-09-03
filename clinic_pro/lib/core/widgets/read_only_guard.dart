// ────────────────────────────────────────────────────────
// حارس وضع القراءة فقط (ReadOnlyGuard)
// يفحص هل التطبيق في وضع القراءة فقط قبل تنفيذ عمليات الإضافة والتعديل
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/presentation/manager/auth_cubit.dart';
import 'subscription_expired_dialog.dart';

class ReadOnlyGuard {
  /// يتحقق مما إذا كان التطبيق في وضع القراءة فقط:
  /// إذا كان في وضع القراءة فقط، يظهر الـ Dialog التحذيري ويعيد false لمنع العملية.
  /// إذا كان الحساب نشطاً، ينفذ onAllowed ويعيد true.
  static bool protect(BuildContext context, {VoidCallback? onAllowed}) {
    final isReadOnly = context.read<AuthCubit>().isReadOnlyMode;
    if (isReadOnly) {
      SubscriptionExpiredDialog.show(
        context,
        isNoSubscription: false,
      );
      return false;
    }
    onAllowed?.call();
    return true;
  }
}

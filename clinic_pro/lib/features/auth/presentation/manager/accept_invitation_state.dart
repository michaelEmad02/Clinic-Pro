// ────────────────────────────────────────────────────────
// حالات شاشة قبول الدعوة (AcceptInvitationState)
// ────────────────────────────────────────────────────────

import 'package:equatable/equatable.dart';
import '../../../../features/staff/domain/entities/invitation_entity.dart';

abstract class AcceptInvitationState extends Equatable {
  const AcceptInvitationState();

  @override
  List<Object?> get props => [];
}

/// الحالة الابتدائية — لم يتم تحميل أي بيانات
class AcceptInvitationInitial extends AcceptInvitationState {}

/// جاري تحميل بيانات الدعوة من قاعدة البيانات
class AcceptInvitationLoading extends AcceptInvitationState {}

/// تم تحميل بيانات الدعوة بنجاح — جاهز لعرض التفاصيل
class AcceptInvitationLoaded extends AcceptInvitationState {
  final InvitationEntity invitation;

  const AcceptInvitationLoaded({required this.invitation});

  @override
  List<Object?> get props => [invitation];
}

/// الدعوة منتهية الصلاحية (أكثر من 7 أيام)
class AcceptInvitationExpired extends AcceptInvitationState {
  final String message;

  const AcceptInvitationExpired({
    this.message = 'هذه الدعوة منتهية الصلاحية',
  });

  @override
  List<Object?> get props => [message];
}

/// الدعوة تم قبولها مسبقاً
class AcceptInvitationAlreadyAccepted extends AcceptInvitationState {
  final String message;

  const AcceptInvitationAlreadyAccepted({
    this.message = 'تم قبول هذه الدعوة مسبقاً',
  });

  @override
  List<Object?> get props => [message];
}

/// جاري تنفيذ عملية القبول (تسجيل دخول + إنشاء الحساب)
class AcceptInvitationAccepting extends AcceptInvitationState {}

/// تم قبول الدعوة بنجاح — جاهز للتوجيه للـ Dashboard
class AcceptInvitationSuccess extends AcceptInvitationState {
  final String role;
  final String clinicName;

  const AcceptInvitationSuccess({
    required this.role,
    required this.clinicName,
  });

  @override
  List<Object?> get props => [role, clinicName];
}

/// خطأ عام أثناء التحميل أو القبول
class AcceptInvitationError extends AcceptInvitationState {
  final String message;

  const AcceptInvitationError({required this.message});

  @override
  List<Object?> get props => [message];
}

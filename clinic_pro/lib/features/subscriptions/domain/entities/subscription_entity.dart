// ────────────────────────────────────────────────────────
// كيان الاشتراك (SubscriptionEntity)
// يمثل اشتراك المالك في إحدى الخطط المتاحة
// ────────────────────────────────────────────────────────

class SubscriptionEntity {
  final String id;
  final String ownerId;
  final String planId;
  final String subscriptionType; // 'trail' | 'monthly' | 'yearly' | 'lifetime'
  final String status; // 'pending' | 'active' | 'expired' | 'cancelled'
  final DateTime? startedAt;
  final DateTime? endAt;
  final DateTime createdAt;

  const SubscriptionEntity({
    required this.id,
    required this.ownerId,
    required this.planId,
    required this.subscriptionType,
    required this.status,
    this.startedAt,
    this.endAt,
    required this.createdAt,
  });

  /// هل الاشتراك نشط حالياً؟
  bool get isActive => status == 'active';

  /// هل هو في فترة التجربة؟
  bool get isTrial => subscriptionType == 'trail'; // ⚠️ الخطأ الإملائي موجود في قاعدة البيانات

  /// هل انتهت صلاحية الاشتراك؟
  bool get isExpired => status == 'expired';

  /// الأيام المتبقية حتى انتهاء الاشتراك
  int get daysRemaining {
    if (endAt == null) return 0;
    final remaining = endAt!.difference(DateTime.now()).inDays;
    return remaining > 0 ? remaining : 0;
  }
}

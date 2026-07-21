// ────────────────────────────────────────────────────────
// نموذج الاشتراك (SubscriptionModel)
// يرث من SubscriptionEntity ويضيف إمكانية التحويل من وإلى JSON
// ────────────────────────────────────────────────────────

import '../../domain/entities/subscription_entity.dart';

class SubscriptionModel extends SubscriptionEntity {
  const SubscriptionModel({
    required super.id,
    required super.ownerId,
    required super.planId,
    required super.subscriptionType,
    required super.status,
    super.startedAt,
    super.endAt,
    required super.createdAt,
  });

  /// إنشاء نموذج من بيانات Supabase الخام
  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String? ?? '',
      planId: json['plan_id'] as String? ?? '',
      subscriptionType: json['subscription_type'] as String? ?? '',
      status: json['status'] as String? ?? '',
      startedAt: json['started_at'] != null
          ? DateTime.parse(json['started_at'] as String)
          : null,
      endAt: json['end_at'] != null
          ? DateTime.parse(json['end_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// تحويل النموذج إلى Map لحفظه في قاعدة البيانات
  Map<String, dynamic> toJson() {
    return {
      'owner_id': ownerId,
      'plan_id': planId,
      'subscription_type': subscriptionType,
      'status': status,
      'started_at': startedAt?.toIso8601String(),
      'end_at': endAt?.toIso8601String(),
    };
  }
}

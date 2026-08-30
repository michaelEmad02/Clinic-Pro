// ────────────────────────────────────────────────────────
// نموذج الاشتراك (SubscriptionModel)
// يرث من SubscriptionEntity ويضيف إمكانية التحويل من وإلى JSON
// ────────────────────────────────────────────────────────

import '../../domain/entities/subscription_entity.dart';

class SubscriptionModel extends SubscriptionEntity {
  static DateTime _parseUtc(String s) {
    final parsed = DateTime.parse(s);
    if (parsed.isUtc) return parsed;
    return DateTime.utc(parsed.year, parsed.month, parsed.day,
        parsed.hour, parsed.minute, parsed.second,
        parsed.millisecond, parsed.microsecond);
  }

  const SubscriptionModel({
    required super.id,
    required super.ownerId,
    required super.planId,
    required super.subscriptionType,
    required super.status,
    super.paymentMethod,
    super.startedAt,
    super.endAt,
    super.createdBy,
    required super.createdAt,
  });

  /// إنشاء نموذج من الـ Entity
  factory SubscriptionModel.fromEntity(SubscriptionEntity entity) {
    return SubscriptionModel(
      id: entity.id,
      ownerId: entity.ownerId,
      planId: entity.planId,
      subscriptionType: entity.subscriptionType,
      status: entity.status,
      paymentMethod: entity.paymentMethod,
      startedAt: entity.startedAt,
      endAt: entity.endAt,
      createdBy: entity.createdBy,
      createdAt: entity.createdAt,
    );
  }

  /// إنشاء نموذج من بيانات Supabase الخام
  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String? ?? '',
      planId: json['plan_id'] as String? ?? '',
      subscriptionType: json['subscription_type'] as String? ?? '',
      status: json['status'] as String? ?? '',
      paymentMethod: json['payment_method'] as String?,
      startedAt: json['started_at'] != null
          ? _parseUtc(json['started_at'] as String)
          : null,
      endAt: json['end_at'] != null
          ? _parseUtc(json['end_at'] as String)
          : null,
      createdBy: json['created_by'] as String?,
      createdAt: _parseUtc(json['created_at'] as String),
    );
  }

  /// تحويل النموذج إلى Map لحفظه في قاعدة البيانات
  Map<String, dynamic> toJson() {
    return {
      'owner_id': ownerId,
      'plan_id': planId,
      'subscription_type': subscriptionType,
      'status': status,
      'payment_method': paymentMethod,
      'started_at': startedAt?.toUtc().toIso8601String(),
      'end_at': endAt?.toUtc().toIso8601String(),
      'created_by': createdBy ?? ownerId,
    };
  }
}

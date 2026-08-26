// ─────────────────────────────────────────────────────────────────────────────
// ملف كيان الكوبون (Coupon Entity)
// يمثل بيانات كوبون الخصم سواء كان عاماً أو مخصصاً لطبيب معين (مكافأة إحالة)
// ─────────────────────────────────────────────────────────────────────────────

import 'package:equatable/equatable.dart';
import 'package:clinic_pro/core/constants/supabase_constants.dart';

/// كيان الكوبون النقي في طبقة الـ Domain
class CouponEntity extends Equatable {
  final String id;
  final String code;
  final CouponScope scope;
  final String? ownerId;
  final CouponRewardType rewardType;
  final double value;
  final int? maxUses;
  final int usedCount;
  final DateTime validFrom;
  final DateTime? validUntil;
  final List<String>? planIds;
  final bool isActive;
  final String? description;

  const CouponEntity({
    required this.id,
    required this.code,
    required this.scope,
    this.ownerId,
    required this.rewardType,
    required this.value,
    this.maxUses,
    required this.usedCount,
    required this.validFrom,
    this.validUntil,
    this.planIds,
    required this.isActive,
    this.description,
  });

  @override
  List<Object?> get props => [
        id,
        code,
        scope,
        ownerId,
        rewardType,
        value,
        maxUses,
        usedCount,
        validFrom,
        validUntil,
        planIds,
        isActive,
        description,
      ];
}

// ─────────────────────────────────────────────────────────────────────────────
// نموذج الكوبون (Coupon Model)
// يقوم بتحويل البيانات الخام القادمة من السيرفر (RPC / Supabase) إلى كيان Domain
// ─────────────────────────────────────────────────────────────────────────────

import 'package:clinic_pro/core/constants/supabase_constants.dart';
import 'package:clinic_pro/features/coupons/domain/entities/coupon_entity.dart';

class CouponModel extends CouponEntity {
  static DateTime _parseUtc(String s) {
    final parsed = DateTime.parse(s);
    if (parsed.isUtc) return parsed;
    return DateTime.utc(parsed.year, parsed.month, parsed.day,
        parsed.hour, parsed.minute, parsed.second,
        parsed.millisecond, parsed.microsecond);
  }

  const CouponModel({
    required super.id,
    required super.code,
    required super.scope,
    super.ownerId,
    required super.rewardType,
    required super.value,
    super.maxUses,
    required super.usedCount,
    required super.validFrom,
    super.validUntil,
    super.planIds,
    required super.isActive,
    super.description,
  });

  /// تحويل كائن JSON القادم من دالة السيرفر `get_available_coupons_for_owner`
  factory CouponModel.fromJson(Map<String, dynamic> json) {
    return CouponModel(
      id: json['coupon_id'] as String? ?? json['id'] as String,
      code: json['code'] as String,
      scope: (json['scope'] as String?) == 'private'
          ? CouponScope.private
          : CouponScope.public,
      ownerId: json['owner_id'] as String?,
      rewardType: _mapRewardType(json['reword_type'] as String?),
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
      maxUses: json['max_uses'] as int?,
      usedCount: json['used_count'] as int? ?? 0,
      validFrom: json['valid_from'] != null
          ? _parseUtc(json['valid_from'] as String)
          : DateTime.now().toUtc(),
      validUntil: json['valid_until'] != null
          ? _parseUtc(json['valid_until'] as String)
          : null,
      planIds: (json['plan_id'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      isActive: json['is_active'] as bool? ?? true,
      description: json['description'] as String?,
    );
  }

  /// تحويل النوع النصي من قاعدة البيانات إلى enum
  static CouponRewardType _mapRewardType(String? type) {
    switch (type) {
      case 'discount_percent':
        return CouponRewardType.discountPercent;
      case 'fixed_amount':
        return CouponRewardType.fixedAmount;
      case 'free_month':
        return CouponRewardType.freeMonth;
      case 'free_days':
      default:
        return CouponRewardType.freeDays;
    }
  }
}

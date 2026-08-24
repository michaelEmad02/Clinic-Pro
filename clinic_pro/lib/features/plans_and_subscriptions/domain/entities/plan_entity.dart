// ────────────────────────────────────────────────────────
// هذا الملف يحتوي على كيانات الخطة ومميزاتها (PlanEntity & PlanFeaturesEntity)
// ────────────────────────────────────────────────────────

class PlanEntity {
  final String id;
  final String name; // 'basic' | 'pro' | 'enterprise'
  final double monthlyPrice;
  final double yearlyPrice;
  final double lifetimePrice;
  final double monthlyPriceEgp;
  final double yearlyPriceEgp;
  final double lifetimePriceEgp;
  final String? description;
  final double monthlyDiscount;
  final double yearlyDiscount;
  final double lifetimeDiscount;
  final String currency;
  final PlanFeaturesEntity? features;

  const PlanEntity({
    required this.id,
    required this.name,
    required this.monthlyPrice,
    required this.yearlyPrice,
    required this.lifetimePrice,
    this.monthlyPriceEgp = 0.0,
    this.yearlyPriceEgp = 0.0,
    this.lifetimePriceEgp = 0.0,
    this.description,
    required this.monthlyDiscount,
    required this.yearlyDiscount,
    required this.lifetimeDiscount,
    required this.currency,
    this.features,
  });
}

class PlanFeaturesEntity {
  final String id;
  final String planId;
  final int maxClinics;
  final int maxStaff;
  final int maxPatients;
  final Map<String, dynamic>? customFeatures;

  const PlanFeaturesEntity({
    required this.id,
    required this.planId,
    required this.maxClinics,
    required this.maxStaff,
    required this.maxPatients,
    this.customFeatures,
  });
}

// ────────────────────────────────────────────────────────
// نماذج بيانات الخطة ومميزاتها والشركة (PlanModel, PlanFeaturesModel, CompanyInfoModel)
// ────────────────────────────────────────────────────────

import '../../domain/entities/company_info_entity.dart';
import '../../domain/entities/plan_entity.dart';

class PlanModel extends PlanEntity {
  const PlanModel({
    required super.id,
    required super.name,
    required super.monthlyPrice,
    required super.yearlyPrice,
    required super.lifetimePrice,
    super.monthlyPriceEgp,
    super.yearlyPriceEgp,
    super.lifetimePriceEgp,
    super.description,
    required super.monthlyDiscount,
    required super.yearlyDiscount,
    required super.lifetimeDiscount,
    required super.currency,
    super.features,
  });

  factory PlanModel.fromJson(Map<String, dynamic> json, {PlanFeaturesEntity? features}) {
    return PlanModel(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'basic',
      monthlyPrice: (json['monthly_price'] as num?)?.toDouble() ?? 0.0,
      yearlyPrice: (json['yearly_price'] as num?)?.toDouble() ?? 0.0,
      lifetimePrice: (json['lifetime_price'] as num?)?.toDouble() ?? 0.0,
      monthlyPriceEgp: (json['monthly_price_egp'] as num?)?.toDouble() ?? 0.0,
      yearlyPriceEgp: (json['yearly_price_egp'] as num?)?.toDouble() ?? 0.0,
      lifetimePriceEgp: (json['lifetime_price_egp'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] as String?,
      monthlyDiscount: (json['monthly_discount'] as num?)?.toDouble() ?? 0.0,
      yearlyDiscount: (json['yearly_discount'] as num?)?.toDouble() ?? 0.0,
      lifetimeDiscount: (json['lifetime_discount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? r'USD $',
      features: features,
    );
  }
}

class PlanFeaturesModel extends PlanFeaturesEntity {
  const PlanFeaturesModel({
    required super.id,
    required super.planId,
    required super.maxClinics,
    required super.maxStaff,
    required super.maxPatients,
    super.customFeatures,
  });

  factory PlanFeaturesModel.fromJson(Map<String, dynamic> json) {
    return PlanFeaturesModel(
      id: json['id'] as String,
      planId: json['plan_id'] as String? ?? '',
      maxClinics: json['max_clinics'] as int? ?? 1,
      maxStaff: json['max_staff'] as int? ?? 1,
      maxPatients: json['max_patients'] as int? ?? 100,
      customFeatures: json['features'] is Map<String, dynamic>
          ? json['features'] as Map<String, dynamic>
          : null,
    );
  }
}

class CompanyInfoModel extends CompanyInfoEntity {
  const CompanyInfoModel({
    required super.id,
    required super.name,
    super.location,
    required super.phone1,
    super.phone2,
    required super.whatsApp1,
    super.whatsApp2,
    super.website,
    super.logoUrl,
  });

  factory CompanyInfoModel.fromJson(Map<String, dynamic> json) {
    return CompanyInfoModel(
      id: json['id']?.toString() ?? 'default',
      name: json['name'] as String? ?? 'Clinic Pro Support',
      location: json['location'] as String?,
      phone1: (json['phone1'] ?? json['phone_1'])?.toString() ?? '+201000000000',
      phone2: (json['phone2'] ?? json['phone_2'])?.toString(),
      whatsApp1: (json['whats_app1'] ?? json['whatsapp1'] ?? json['whatsapp_1'] ?? json['phone1'])?.toString() ?? '+201000000000',
      whatsApp2: (json['whats_app2'] ?? json['whatsapp2'] ?? json['whatsapp_2'])?.toString(),
      website: json['website'] as String?,
      logoUrl: (json['logo_url'] ?? json['logourl']) as String?,
    );
  }
}

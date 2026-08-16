// ────────────────────────────────────────────────────────
// هذا الملف يحتوي على كيان معلومات الشركة للدعم والاتصال (CompanyInfoEntity)
// ────────────────────────────────────────────────────────

class CompanyInfoEntity {
  final String id;
  final String name;
  final String? location;
  final String phone1;
  final String? phone2;
  final String whatsApp1;
  final String? whatsApp2;
  final String? website;
  final String? logoUrl;

  const CompanyInfoEntity({
    required this.id,
    required this.name,
    this.location,
    required this.phone1,
    this.phone2,
    required this.whatsApp1,
    this.whatsApp2,
    this.website,
    this.logoUrl,
  });
}

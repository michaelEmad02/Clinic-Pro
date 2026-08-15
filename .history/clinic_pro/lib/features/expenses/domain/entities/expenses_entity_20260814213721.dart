class ClinicEntity {
  final String id;
  final String clinic_id;
  final String category_id;
  final String title;
  final String amount;
  final String notes;
  final String created_by;
  final String created_at;
  final String date;

  ClinicEntity({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.address,
    required this.phone1,
    required this.phone2,
    required this.logoUrl,
    required this.isActive,
    required this.createdAt,
  });

  // أول حرف من اسم العيادة — يُستخدم كشعار افتراضي
  String get initials {
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    return parts.first[0];
  }

  ClinicEntity copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? address,
    String? phone1,
    String? phone2,
    String? logoUrl,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return ClinicEntity(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      address: address ?? this.address,
      phone1: phone1 ?? this.phone1,
      phone2: phone2 ?? this.phone2,
      logoUrl: logoUrl ?? this.logoUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

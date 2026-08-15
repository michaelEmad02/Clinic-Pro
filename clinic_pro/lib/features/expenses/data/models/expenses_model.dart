import 'package:clinic_pro/features/clinics/domain/entities/clinic_entity.dart';

class ClinicModel extends ClinicEntity {
  ClinicModel(
      {required super.id,
      required super.ownerId,
      required super.name,
      required super.address,
      required super.phone1,
      required super.phone2,
      required super.logoUrl,
      required super.isActive,
      required super.createdAt});

  factory ClinicModel.fromJson(Map<String, dynamic> data) {
    return ClinicModel(
        id: data['id'],
        ownerId: data['owner_id'] as String? ?? '',
        name: data['name'] as String? ?? '',
        address: data['address'] as String? ?? '',
        phone1: data['phone1'] as String? ?? '',
        phone2: data['phone2'] as String? ?? '',
        logoUrl: data['logo_url'] as String? ?? '',
        isActive: data['is_active'] as bool? ?? false,
        createdAt: DateTime.parse(data['created_at'] as String));
  }

  Map<String, dynamic> toJson() {
    return {
      'owner_id': ownerId,
      'name': name,
      'address': address,
      'phone1': phone1,
      'phone2': phone2,
      'logo_url': logoUrl,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

// ────────────────────────────────────────────────────────
// كيان المريض (PatientEntity)
// يمثل بيانات المريض الأساسية — نقي بدون أي اعتماديات خارجية
// مطابق لجدول patients في قاعدة البيانات
// ────────────────────────────────────────────────────────

import 'package:equatable/equatable.dart';

class PatientEntity extends Equatable {
  final String id;
  final String clinicId;
  final String name;
  final String? phone;
  final String? address;
  final String? dateOfBirth;
  final String? allergies;
  final String? chronicConditions;
  final String gender; // required — enum: male | female
  final String? bloodType; // optional — enum: A+, A-, B+, B-, AB+, AB-, O+, O-

  const PatientEntity({
    required this.id,
    required this.clinicId,
    required this.name,
    this.phone,
    this.address,
    this.dateOfBirth,
    this.allergies,
    this.chronicConditions,
    required this.gender,
    this.bloodType,
  });

  /// الحروف الأولى من الاسم للعرض في الأفاتار
  String get initials {
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0];
    return '${parts.first[0]}${parts.last[0]}';
  }

  /// هل يعاني المريض من حساسية دوائية
  bool get hasAllergies =>
      allergies != null &&
      allergies!.isNotEmpty &&
      allergies != 'لا يوجد' &&
      allergies != 'None' &&
      allergies != 'no';

  /// هل يعاني المريض من أمراض مزمنة
  bool get isChronic =>
      chronicConditions != null &&
      chronicConditions!.isNotEmpty &&
      chronicConditions != 'لا يوجد' &&
      chronicConditions != 'None';

  PatientEntity copyWith({
    String? id,
    String? clinicId,
    String? name,
    String? Function()? phone,
    String? Function()? address,
    String? Function()? dateOfBirth,
    String? Function()? allergies,
    String? Function()? chronicConditions,
    String? gender,
    String? Function()? bloodType,
  }) {
    return PatientEntity(
      id: id ?? this.id,
      clinicId: clinicId ?? this.clinicId,
      name: name ?? this.name,
      phone: phone != null ? phone() : this.phone,
      address: address != null ? address() : this.address,
      dateOfBirth: dateOfBirth != null ? dateOfBirth() : this.dateOfBirth,
      allergies: allergies != null ? allergies() : this.allergies,
      chronicConditions:
          chronicConditions != null ? chronicConditions() : this.chronicConditions,
      gender: gender ?? this.gender,
      bloodType: bloodType != null ? bloodType() : this.bloodType,
    );
  }

  @override
  List<Object?> get props => [
        id,
        clinicId,
        name,
        phone,
        address,
        dateOfBirth,
        allergies,
        chronicConditions,
        gender,
        bloodType,
      ];
}

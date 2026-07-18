class DoctorSecretariesEntity {
  final String id;
  final String clinicId;
  final String doctorId; // = user_id
  final String secretaryId;
  final bool isActive;

  DoctorSecretariesEntity({
    required this.id,
    required this.clinicId,
    required this.doctorId,
    required this.secretaryId,
    required this.isActive,
  });
}

// ────────────────────────────────────────────────────────
// نموذج الموعد (AppointmentModel)
// يرث من AppointmentEntity ويقوم بعمليات التحويل من وإلى JSON
// ────────────────────────────────────────────────────────

import '../../domain/entities/appointment_entity.dart';

class AppointmentModel extends AppointmentEntity {
  const AppointmentModel({
    required super.id,
    required super.clinicId,
    required super.doctorId,
    required super.patientId,
    required super.typeId,
    required super.date,
    super.time,
    required super.status,
    required super.price,
    super.notes,
    required super.isUrgent,
    super.arrivedAt,
    super.calledAt,
    required super.createdBy,
    required super.createdAt,
    super.patientName,
    super.patientPhone,
    super.doctorName,
    super.typeName,
    super.displayTime,
    super.expectedCallTime,
    super.hasPrescription = false,
    super.hasInvoice = false,
    super.prescriptionDiagnosis,
    super.invoiceAmount,
    super.invoiceStatus,
    super.invoiceNumber,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    final patient = json['patients'] as Map<String, dynamic>? ?? {};
    final type = json['appointment_types'] as Map<String, dynamic>? ?? {};
    final doctor = json['users'] as Map<String, dynamic>? ?? {};

    final timeRaw = json['time'] as String? ?? '00:00:00';
    final parts = timeRaw.split(':');
    String displayTime = '';
    if (parts.isNotEmpty) {
      final hour = int.tryParse(parts[0]) ?? 0;
      final minute = parts.length > 1 ? parts[1] : '00';
      final period = hour >= 12 ? 'م' : 'ص';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      displayTime = '$displayHour:$minute $period';
    }

    final prescription = json['prescriptions'] as List? ?? [];
    final invoice = json['invoices'] as List? ?? [];

    return AppointmentModel(
      id: json['id'] as String,
      clinicId: json['clinic_id'] as String? ?? '',
      doctorId: json['doctor_id'] as String? ?? '',
      patientId: json['patient_id'] as String? ?? '',
      typeId: json['type_id'] as String? ?? '',
      date: json['date'] as String? ?? '',
      time: json['time'] as String?,
      status: json['status'] as String? ?? 'scheduled',
      price: (json['price'] as num? ?? 0.0).toDouble(),
      notes: json['notes'] as String?,
      isUrgent: json['is_urgent'] as bool? ?? false,
      arrivedAt: json['arrived_at'] != null ? DateTime.parse(json['arrived_at'] as String) : null,
      calledAt: json['called_at'] != null ? DateTime.parse(json['called_at'] as String) : null,
      createdBy: json['created_by'] as String? ?? '',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : DateTime.now(),
      patientName: patient['name'] as String?,
      patientPhone: patient['phone'] as String?,
      doctorName: doctor['name'] as String?,
      typeName: type['name'] as String?,
      displayTime: displayTime,
      hasPrescription: prescription.isNotEmpty,
      hasInvoice: invoice.isNotEmpty,
      prescriptionDiagnosis: prescription.isNotEmpty ? prescription.first['diagnosis'] as String? : null,
      invoiceAmount: invoice.isNotEmpty ? '${invoice.first['amount']}' : null,
      invoiceStatus: invoice.isNotEmpty ? invoice.first['status'] as String? : null,
      invoiceNumber: invoice.isNotEmpty
          ? '#INV-${(json['id'] as String).substring((json['id'] as String).length > 4 ? (json['id'] as String).length - 4 : 0)}'
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'clinic_id': clinicId.isEmpty ? null : clinicId,
      'doctor_id': doctorId.isEmpty ? null : doctorId,
      'patient_id': patientId.isEmpty ? null : patientId,
      'type_id': typeId.isEmpty ? null : typeId,
      'date': date,
      'time': time,
      'status': status,
      'price': price,
      'notes': notes,
      'is_urgent': isUrgent,
      'arrived_at': arrivedAt?.toIso8601String(),
      'called_at': calledAt?.toIso8601String(),
      'created_by': createdBy.isEmpty ? null : createdBy,
    };
  }
}

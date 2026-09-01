// ────────────────────────────────────────────────────────
// InvoiceModel — النموذج الخاص بالفاتورة بـ Data Layer
// يتعامل مع التحويل من وإلى JSON لجدول invoices
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/features/invoices/domain/entities/invoice_entity.dart';

class InvoiceModel extends InvoiceEntity {
  /// يُفسّر أي timestamp من Supabase كـ UTC
  static DateTime _parseUtc(String s) {
    final parsed = DateTime.parse(s);
    if (parsed.isUtc) return parsed;
    return DateTime.utc(parsed.year, parsed.month, parsed.day,
        parsed.hour, parsed.minute, parsed.second,
        parsed.millisecond, parsed.microsecond);
  }

  const InvoiceModel({
    required super.id,
    required super.clinicId,
    required super.patientId,
    super.patientName,
    super.doctorId,
    required super.sourceId,
    super.sourceType,
    required super.totalAmount,
    required super.paidAmount,
    super.paymentMethod,
    super.createdBy,
    required super.createdAt,
    super.appointmentTypeName,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      id: json['id'] as String? ?? '',
      clinicId: json['clinic_id'] as String? ?? '',
      patientId: json['patient_id'] as String? ?? '',
      patientName: json['patient_name'] as String?,
      doctorId: json['doctor_id'] as String?,
      sourceId: json['source_id'] as String? ?? '',
      sourceType: json['source_type'] as String? ?? 'appointment',
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      paidAmount: (json['paid_amount'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: json['payment_method'] as String?,
      createdBy: json['created_by'] as String?,
      createdAt: json['created_at'] != null
          ? _parseUtc(json['created_at'] as String)
          : DateTime.now().toUtc(),
      appointmentTypeName: json['appointment_type'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'clinic_id': clinicId,
      'patient_id': patientId,
      if (doctorId != null && doctorId!.isNotEmpty) 'doctor_id': doctorId,
      'source_id': sourceId,
      'source_type': sourceType,
      'total_amount': totalAmount,
      'paid_amount': paidAmount,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (createdBy != null) 'created_by': createdBy,
    };
  }

  factory InvoiceModel.fromEntity(InvoiceEntity entity) {
    return InvoiceModel(
      id: entity.id,
      clinicId: entity.clinicId,
      patientId: entity.patientId,
      patientName: entity.patientName,
      doctorId: entity.doctorId,
      sourceId: entity.sourceId,
      sourceType: entity.sourceType,
      totalAmount: entity.totalAmount,
      paidAmount: entity.paidAmount,
      paymentMethod: entity.paymentMethod,
      createdBy: entity.createdBy,
      createdAt: entity.createdAt,
      appointmentTypeName: entity.appointmentTypeName,
    );
  }
}

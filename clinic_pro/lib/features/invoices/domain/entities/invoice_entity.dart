// ────────────────────────────────────────────────────────
// InvoiceEntity — كيان الفاتورة في Domain Layer
// يحسب حالة الفاتورة ديناميكياً من المبالغ المسجلة
// ────────────────────────────────────────────────────────

import 'package:equatable/equatable.dart';

enum InvoiceStatus {
  pending, // معلق (paidAmount == 0)
  partial, // جزئي (0 < paidAmount < totalAmount)
  paid, // مدفوع (paidAmount >= totalAmount)
}

class InvoiceEntity extends Equatable {
  final String id;
  final String clinicId;
  final String patientId;
  final String? patientName;
  final String sourceId; // رقم الموعد (appointments.id)
  final String sourceType; // 'appointment'
  final double totalAmount;
  final double paidAmount;
  final String? paymentMethod;
  final String? createdBy;
  final DateTime createdAt;
  final String? appointmentTypeName;

  const InvoiceEntity({
    required this.id,
    required this.clinicId,
    required this.patientId,
    this.patientName,
    required this.sourceId,
    this.sourceType = 'appointment',
    required this.totalAmount,
    required this.paidAmount,
    this.paymentMethod,
    this.createdBy,
    required this.createdAt,
    this.appointmentTypeName,
  });

  /// حساب حالة الفاتورة المشتقة ديناميكياً
  InvoiceStatus get status {
    if (paidAmount <= 0) return InvoiceStatus.pending;
    if (paidAmount < totalAmount) return InvoiceStatus.partial;
    return InvoiceStatus.paid;
  }

  /// إرجاع اسم الحالة باللغة العربية لعرضها ببطاقات الفواتير
  String get statusArabic {
    switch (status) {
      case InvoiceStatus.pending:
        return 'معلق';
      case InvoiceStatus.partial:
        return 'جزئي';
      case InvoiceStatus.paid:
        return 'مدفوع';
    }
  }

  /// إرجاع المبلغ المتبقي غير المدفوع
  double get remainingAmount =>
      (totalAmount - paidAmount) > 0 ? (totalAmount - paidAmount) : 0.0;

  InvoiceEntity copyWith({
    String? id,
    String? clinicId,
    String? patientId,
    String? patientName,
    String? sourceId,
    String? sourceType,
    double? totalAmount,
    double? paidAmount,
    String? paymentMethod,
    String? createdBy,
    DateTime? createdAt,
    String? appointmentTypeName,
  }) {
    return InvoiceEntity(
      id: id ?? this.id,
      clinicId: clinicId ?? this.clinicId,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      sourceId: sourceId ?? this.sourceId,
      sourceType: sourceType ?? this.sourceType,
      totalAmount: totalAmount ?? this.totalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      appointmentTypeName: appointmentTypeName ?? this.appointmentTypeName,
    );
  }

  @override
  List<Object?> get props => [
        id,
        clinicId,
        patientId,
        patientName,
        sourceId,
        sourceType,
        totalAmount,
        paidAmount,
        paymentMethod,
        createdBy,
        createdAt,
        appointmentTypeName,
      ];
}

// ────────────────────────────────────────────────────────
// كيان الموعد (AppointmentEntity)
// يمثل بيانات الموعد الأساسية وتفاصيل المريض والطبيب ونوع الزيارة
// ────────────────────────────────────────────────────────

import 'package:equatable/equatable.dart';

class AppointmentEntity extends Equatable {
  final String id;
  final String clinicId;
  final String doctorId;
  final String patientId;
  final String typeId; // FK -> doctor_appointment_types.id
  final String date; // التاريخ بصيغة 'yyyy-MM-dd'
  final String? time; // الوقت بصيغة 'HH:mm:ss'
  final String status; // scheduled, confirmed, in_progress, done, cancelled
  final double price; // السعر وقت الحجز
  final String? notes; // ملاحظات الموعد
  final bool isUrgent; // هل الموعد حالة طارئة
  final DateTime? arrivedAt; // وقت تأكيد الوصول
  final DateTime? calledAt; // وقت استدعاء الطبيب للمريض
  final String createdBy; // المستخدم الذي أنشأ الموعد
  final DateTime createdAt; // وقت إنشاء السجل

  // بيانات إضافية للعرض في الواجهات (Denormalized UI data)
  final String? patientName;
  final String? patientPhone;
  final String? doctorName;
  final String? typeName;
  final String? displayTime;

  // الوقت المتوقع للاستدعاء (يُحسب مؤقتاً في طابور الانتظار بنظام scheduled)
  final DateTime? expectedCallTime;

  // حقول الروشتات والفواتير المرتبطة
  final bool hasPrescription;
  final bool hasInvoice;
  final String? prescriptionDiagnosis;
  final String? invoiceAmount;
  final String? invoiceStatus;
  final String? invoiceNumber;

  const AppointmentEntity({
    required this.id,
    required this.clinicId,
    required this.doctorId,
    required this.patientId,
    required this.typeId,
    required this.date,
    this.time,
    required this.status,
    required this.price,
    this.notes,
    required this.isUrgent,
    this.arrivedAt,
    this.calledAt,
    required this.createdBy,
    required this.createdAt,
    this.patientName,
    this.patientPhone,
    this.doctorName,
    this.typeName,
    this.displayTime,
    this.expectedCallTime,
    this.hasPrescription = false,
    this.hasInvoice = false,
    this.prescriptionDiagnosis,
    this.invoiceAmount,
    this.invoiceStatus,
    this.invoiceNumber,
  });

  AppointmentEntity copyWith({
    String? status,
    bool? isUrgent,
    DateTime? arrivedAt,
    DateTime? calledAt,
    DateTime? expectedCallTime,
    String? patientName,
    String? patientPhone,
    String? doctorName,
    String? typeName,
    String? displayTime,
    bool? hasPrescription,
    bool? hasInvoice,
    String? prescriptionDiagnosis,
    String? invoiceAmount,
    String? invoiceStatus,
    String? invoiceNumber,
  }) {
    return AppointmentEntity(
      id: id,
      clinicId: clinicId,
      doctorId: doctorId,
      patientId: patientId,
      typeId: typeId,
      date: date,
      time: time,
      status: status ?? this.status,
      price: price,
      notes: notes,
      isUrgent: isUrgent ?? this.isUrgent,
      arrivedAt: arrivedAt ?? this.arrivedAt,
      calledAt: calledAt ?? this.calledAt,
      createdBy: createdBy,
      createdAt: createdAt,
      patientName: patientName ?? this.patientName,
      patientPhone: patientPhone ?? this.patientPhone,
      doctorName: doctorName ?? this.doctorName,
      typeName: typeName ?? this.typeName,
      displayTime: displayTime ?? this.displayTime,
      expectedCallTime: expectedCallTime ?? this.expectedCallTime,
      hasPrescription: hasPrescription ?? this.hasPrescription,
      hasInvoice: hasInvoice ?? this.hasInvoice,
      prescriptionDiagnosis: prescriptionDiagnosis ?? this.prescriptionDiagnosis,
      invoiceAmount: invoiceAmount ?? this.invoiceAmount,
      invoiceStatus: invoiceStatus ?? this.invoiceStatus,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
    );
  }

  @override
  List<Object?> get props => [
        id,
        clinicId,
        doctorId,
        patientId,
        typeId,
        date,
        time,
        status,
        price,
        notes,
        isUrgent,
        arrivedAt,
        calledAt,
        createdBy,
        createdAt,
        patientName,
        patientPhone,
        doctorName,
        typeName,
        displayTime,
        expectedCallTime,
        hasPrescription,
        hasInvoice,
        prescriptionDiagnosis,
        invoiceAmount,
        invoiceStatus,
        invoiceNumber,
      ];
}

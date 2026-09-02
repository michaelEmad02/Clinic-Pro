// ────────────────────────────────────────────────────────
// كيان الموعد (AppointmentEntity)
// يمثل بيانات الموعد الأساسية وتفاصيل المريض والطبيب ونوع الزيارة
// ────────────────────────────────────────────────────────

import 'package:equatable/equatable.dart';
import '../../../prescription/domain/entities/prescription_entity.dart';
import '../../../invoices/domain/entities/invoice_entity.dart';

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
  final String? createdByName; // اسم المستخدم الذي أنشأ الموعد
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
  final String? prescriptionDiagnosis;
  final List<InvoiceEntity>? invoices; // قائمة الفواتير المرتبطة بالزيارة
  final String? invoiceNumber;
  final List<PrescriptionItemEntity>? prescriptionDrugs; // قائمة أدوية الروشتة المرتبطة بالزيارة

  bool get hasInvoice => invoices != null && invoices!.isNotEmpty;

  String? get invoiceAmount {
    if (invoices == null || invoices!.isEmpty) return null;
    final totalPaid = invoices!.fold<double>(0.0, (sum, inv) => sum + inv.paidAmount);
    final totalTotal = invoices!.first.totalAmount;
    return '${totalPaid.toStringAsFixed(0)} / ${totalTotal.toStringAsFixed(0)}';
  }

  String? get invoiceStatus {
    if (invoices == null || invoices!.isEmpty) return null;
    final totalTotal = invoices!.first.totalAmount;
    final totalPaid = invoices!.fold<double>(0.0, (sum, inv) => sum + inv.paidAmount);
    if (totalPaid <= 0) return 'pending';
    if (totalPaid < totalTotal) return 'partial';
    return 'paid';
  }

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
    this.createdByName,
    required this.createdAt,
    this.patientName,
    this.patientPhone,
    this.doctorName,
    this.typeName,
    this.displayTime,
    this.expectedCallTime,
    this.hasPrescription = false,
    this.prescriptionDiagnosis,
    this.invoices,
    this.invoiceNumber,
    this.prescriptionDrugs,
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
    String? prescriptionDiagnosis,
    List<InvoiceEntity>? invoices,
    String? invoiceNumber,
    List<PrescriptionItemEntity>? prescriptionDrugs,
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
      createdByName: createdByName,
      createdAt: createdAt,
      patientName: patientName ?? this.patientName,
      patientPhone: patientPhone ?? this.patientPhone,
      doctorName: doctorName ?? this.doctorName,
      typeName: typeName ?? this.typeName,
      displayTime: displayTime ?? this.displayTime,
      expectedCallTime: expectedCallTime ?? this.expectedCallTime,
      hasPrescription: hasPrescription ?? this.hasPrescription,
      prescriptionDiagnosis: prescriptionDiagnosis ?? this.prescriptionDiagnosis,
      invoices: invoices ?? this.invoices,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      prescriptionDrugs: prescriptionDrugs ?? this.prescriptionDrugs,
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
        createdByName,
        createdAt,
        patientName,
        patientPhone,
        doctorName,
        typeName,
        displayTime,
        expectedCallTime,
        hasPrescription,
        prescriptionDiagnosis,
        invoices,
        invoiceNumber,
        prescriptionDrugs,
      ];
}

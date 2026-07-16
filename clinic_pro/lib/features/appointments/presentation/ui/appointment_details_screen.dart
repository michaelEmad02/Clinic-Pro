// ────────────────────────────────────────────────────────
// شاشة تفاصيل الموعد — مطابقة لتصميم Stitch
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/mocks/mock_data.dart';
import '../../../../core/strings/app_strings.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../manager/appointments_state.dart';
import 'widgets/appointment_header_card.dart';
import 'widgets/appointment_status_timeline.dart';
import 'widgets/linked_invoice_card.dart';
import 'widgets/linked_prescription_card.dart';
import 'widgets/urgent_appointment_banner.dart';

class AppointmentDetailsScreen extends StatelessWidget {
  final String id;

  const AppointmentDetailsScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    final appointment = _findAppointment(id);

    if (appointment == null) {
      return Scaffold(
        appBar: AppBar(title: Text(AppStrings.appointmentDetails)),
        body: Center(child: Text(AppStrings.isArabic ? 'الموعد غير موجود' : 'Appointment not found')),
      );
    }

    final canCancel =
        appointment.status != 'done' && appointment.status != 'cancelled';

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        toolbarHeight: 64,
        backgroundColor: context.surfaceColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          AppStrings.appointmentDetails,
          style: AppTextStyles.headlineMedium(context).copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: context.borderColor, height: 1),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppConstants.spaceMd),
        children: [
          AppointmentStatusTimeline(appointment: appointment),
          if (appointment.isUrgent) ...[
            const SizedBox(height: 12),
            const UrgentAppointmentBanner(),
          ],
          const SizedBox(height: 16),
          AppointmentHeaderCard(appointment: appointment),
          const SizedBox(height: 16),
          LinkedPrescriptionCard(
            hasPrescription: appointment.hasPrescription,
            diagnosis: appointment.prescriptionDiagnosis,
            appointmentId: appointment.id,
          ),
          const SizedBox(height: 16),
          LinkedInvoiceCard(
            hasInvoice: appointment.hasInvoice,
            amount: appointment.invoiceAmount,
            status: appointment.invoiceStatus,
            invoiceNumber: appointment.invoiceNumber,
          ),
          if (canCancel) ...[
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spaceMd,
              ),
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppStrings.appointmentDeleted)),
                  );
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.cancel_outlined, color: AppColors.danger),
                label: Text(
                  '${AppStrings.cancel} ${AppStrings.appointment}',
                  style: AppTextStyles.bodyMedium(context).copyWith(
                    color: AppColors.danger,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.danger),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppConstants.radiusButton),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  /// البحث عن الموعد من MockData وتحويله إلى AppointmentItem
  AppointmentItem? _findAppointment(String appointmentId) {
    final raw = MockData.appointments
        .where((a) => a['id'] == appointmentId)
        .toList();
    if (raw.isEmpty) return null;

    final data = raw.first;
    final patient = data['patients'] as Map<String, dynamic>? ?? {};
    final type = data['appointment_types'] as Map<String, dynamic>? ?? {};
    final doctorId = data['doctor_id'] as String;
    final doctor = MockData.users.firstWhere(
      (u) => u['id'] == doctorId,
      orElse: () => {'name': AppStrings.doctorRoleLabel},
    );

    final prescription = MockData.prescriptions
        .where((p) => p['appointment_id'] == appointmentId)
        .toList();
    final invoice = MockData.invoices
        .where((i) => i['appointment_id'] == appointmentId)
        .toList();

    final timeRaw = data['time'] as String;
    final parts = timeRaw.split(':');
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = parts.length > 1 ? parts[1] : '00';
    final period = hour >= 12 ? (AppStrings.isArabic ? 'م' : 'PM') : (AppStrings.isArabic ? 'ص' : 'AM');
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

    return AppointmentItem(
      id: appointmentId,
      patientId: data['patient_id'] as String,
      patientName: patient['name'] as String? ?? AppStrings.patient,
      patientPhone: patient['phone'] as String? ?? '',
      doctorId: doctorId,
      doctorName: doctor['name'] as String,
      typeId: data['appointment_type_id'] as String,
      typeName: type['name'] as String? ?? AppStrings.normalCheckup,
      date: data['date'] as String,
      displayTime: '$displayHour:$minute $period',
      status: data['status'] as String,
      price: (data['price'] as num).toDouble(),
      isUrgent: data['is_urgent'] as bool? ?? false,
      notes: data['notes'] as String?,
      arrivedAt: data['arrived_at'] != null
          ? DateTime.parse(data['arrived_at'] as String)
          : null,
      calledAt: data['called_at'] != null
          ? DateTime.parse(data['called_at'] as String)
          : null,
      hasPrescription: prescription.isNotEmpty,
      hasInvoice: invoice.isNotEmpty,
      prescriptionDiagnosis: prescription.isNotEmpty
          ? prescription.first['diagnosis'] as String?
          : null,
      invoiceAmount: invoice.isNotEmpty ? '${invoice.first['amount']}' : null,
      invoiceStatus: invoice.isNotEmpty ? invoice.first['status'] as String? : null,
      invoiceNumber: invoice.isNotEmpty
          ? '#INV-${appointmentId.substring(appointmentId.length > 4 ? appointmentId.length - 4 : 0)}'
          : null,
    );
  }
}

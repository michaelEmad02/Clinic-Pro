// ────────────────────────────────────────────────────────
// InvoicesRemoteDataSource — مصدر البيانات البعيد للفواتير بـ Supabase
// (يقع بداخل data_sources المعتمد للمشروع)
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/constants/supabase_constants.dart';
import 'package:clinic_pro/core/services/i_cloud_service.dart';
import 'package:clinic_pro/features/invoices/data/models/invoice_model.dart';
import 'package:clinic_pro/features/invoices/domain/entities/unpaid_appointment_entity.dart';
import 'package:injectable/injectable.dart';

abstract class IInvoicesRemoteDataSource {
  Future<List<InvoiceModel>> getInvoices(String clinicId);
  Future<void> createInvoice(InvoiceModel invoice);
  Future<void> updateInvoice(InvoiceModel invoice);
  Future<void> deleteInvoice(String id);
  Future<List<UnpaidAppointmentEntity>> getPatientUnpaidAppointments(
      String patientId);
}

@LazySingleton(as: IInvoicesRemoteDataSource)
class InvoicesRemoteDataSourceImpl implements IInvoicesRemoteDataSource {
  final ICloudService _cloudService;

  InvoicesRemoteDataSourceImpl(this._cloudService);

  @override
  Future<List<InvoiceModel>> getInvoices(String clinicId) async {
    final queryEq = clinicId.isNotEmpty ? {'clinic_id': clinicId} : null;
    final invoices = await _cloudService.select(
      table: SupabaseTables.invoices,
      eq: queryEq,
    );

    if (invoices.isEmpty) return [];

    // 1. تجميع الـ IDs المميزة للمرضى والمواعيد
    final patientIds = invoices
        .map((inv) => inv['patient_id'] as String?)
        .whereType<String>()
        .toSet();

    final appointmentIds = invoices
        .map((inv) => inv['source_id'] as String?)
        .whereType<String>()
        .toSet();

    // 2. جلب جميع المرضى المعنيين في استعلام واحد أو تجميعي
    final Map<String, String> patientNamesMap = {};
    if (patientIds.isNotEmpty) {
      final allPatients = await _cloudService.select(table: SupabaseTables.patients);
      for (final p in allPatients) {
        final id = p['id'] as String?;
        final name = p['name'] as String?;
        if (id != null && name != null) {
          patientNamesMap[id] = name;
        }
      }
    }

    // 3. جلب جميع المواعيد وأنواعها دفعة واحدة
    final Map<String, String> appointmentTypesMap = {};
    if (appointmentIds.isNotEmpty) {
      final allAppointments = await _cloudService.select(table: SupabaseTables.appointments);
      final allDoctorTypes = await _cloudService.select(table: SupabaseTables.doctorAppointmentTypes);
      final allApptTypes = await _cloudService.select(table: SupabaseTables.appointmentTypes);

      final Map<String, String> docTypeToApptTypeId = {};
      for (final dt in allDoctorTypes) {
        final dtId = dt['id'] as String?;
        final apptTypeId = dt['appointment_type_id'] as String?;
        if (dtId != null && apptTypeId != null) {
          docTypeToApptTypeId[dtId] = apptTypeId;
        }
      }

      final Map<String, String> apptTypeIdToName = {};
      for (final at in allApptTypes) {
        final atId = at['id'] as String?;
        final name = at['name'] as String?;
        if (atId != null && name != null) {
          apptTypeIdToName[atId] = name;
        }
      }

      for (final appt in allAppointments) {
        final apptId = appt['id'] as String?;
        final typeId = appt['type_id'] as String?;
        if (apptId != null && typeId != null) {
          final targetApptTypeId = docTypeToApptTypeId[typeId];
          if (targetApptTypeId != null && apptTypeIdToName.containsKey(targetApptTypeId)) {
            appointmentTypesMap[apptId] = apptTypeIdToName[targetApptTypeId]!;
          }
        }
      }
    }

    // 4. دمج البيانات المجلوبة بـ O(N) بخصائص حاسوبية فورية
    final List<InvoiceModel> result = [];
    for (final inv in invoices) {
      final patientId = inv['patient_id'] as String?;
      final appointmentId = inv['source_id'] as String?;

      final mutableInv = Map<String, dynamic>.from(inv);
      if (patientId != null && patientNamesMap.containsKey(patientId)) {
        mutableInv['patient_name'] = patientNamesMap[patientId];
      }
      if (appointmentId != null && appointmentTypesMap.containsKey(appointmentId)) {
        mutableInv['appointment_type'] = appointmentTypesMap[appointmentId];
      }

      result.add(InvoiceModel.fromJson(mutableInv));
    }

    result.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return result;
  }

  @override
  Future<void> createInvoice(InvoiceModel invoice) async {
    final data = invoice.toJson();
    data.remove('id');
    data.remove('created_at');
    data.remove('patient_name');
    data.remove('appointment_type');

    await _cloudService.insert(
      table: SupabaseTables.invoices,
      data: data,
    );
  }

  @override
  Future<void> updateInvoice(InvoiceModel invoice) async {
    final data = invoice.toJson();
    data.remove('created_at');
    data.remove('patient_name');
    data.remove('appointment_type');

    await _cloudService.update(
      table: SupabaseTables.invoices,
      data: data,
      matchColumn: 'id',
      matchValue: invoice.id,
    );
  }

  @override
  Future<void> deleteInvoice(String id) async {
    await _cloudService.delete(
      table: SupabaseTables.invoices,
      matchColumn: 'id',
      matchValue: id,
    );
  }

  @override
  Future<List<UnpaidAppointmentEntity>> getPatientUnpaidAppointments(
      String patientId) async {
    final appointments = await _cloudService.select(
      table: SupabaseTables.appointments,
      eq: {'patient_id': patientId},
    );

    final List<UnpaidAppointmentEntity> result = [];

    for (final appt in appointments) {
      final apptId = appt['id'] as String;

      // حساب المبالغ المدفوعة مسبقاً لهذا الموعد من جدول الفواتير
      final existingInvoices = await _cloudService.select(
        table: SupabaseTables.invoices,
        eq: {'source_id': apptId},
      );

      double paidSoFar = 0.0;
      for (final inv in existingInvoices) {
        paidSoFar += (inv['paid_amount'] as num?)?.toDouble() ?? 0.0;
      }

      final expectedPrice = (appt['price'] as num?)?.toDouble() ?? 0.0;

      // تشمل المواعيد التي لم تُسدد بالكامل بعد
      if (existingInvoices.isEmpty || paidSoFar < expectedPrice) {
        var typeName = '';
        final typeId = appt['type_id'];
          if (typeId != null) {
            final doctorAppointmentTypes = await _cloudService.select(
              table: SupabaseTables.doctorAppointmentTypes,
              eq: {'id': typeId},
            );
            final appointmentTypes = await _cloudService.select(
              table: SupabaseTables.appointmentTypes,
              eq: {'id': doctorAppointmentTypes.first['appointment_type_id']},
            );
            if (doctorAppointmentTypes.isNotEmpty) {
              typeName = appointmentTypes.first['name']?? '';
            }
          }
          
        

        result.add(UnpaidAppointmentEntity(
          id: apptId,
          patientId: patientId,
          clinicId: appt['clinic_id'] as String? ?? '',
          appointmentTypeName: typeName,
          expectedPrice: expectedPrice,
          paidSoFar: paidSoFar,
          date: appt['date'] as String? ?? '',
          time: appt['time'] as String? ?? '',
        ));
      }
    }

    result.sort((a, b) => b.date.compareTo(a.date));

    return result;
  }
}

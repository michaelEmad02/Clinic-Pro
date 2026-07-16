import '../../../../core/strings/app_strings.dart';
import '../../../../core/services/i_cloud_service.dart';
import 'prescription_state.dart';

class PrescriptionLoadResult {
  final Map<String, dynamic> appointmentRaw;
  final Map<String, dynamic> patientRaw;
  final Map<String, dynamic> doctor;
  final String typeName;
  final List<SelectedDrugModel> selectedDrugs;
  final List<String> selectedDiagnosis;
  final String finalDiagnosis;
  final String notes;

  const PrescriptionLoadResult({
    required this.appointmentRaw,
    required this.patientRaw,
    required this.doctor,
    required this.typeName,
    required this.selectedDrugs,
    required this.selectedDiagnosis,
    required this.finalDiagnosis,
    required this.notes,
  });
}

class PrescriptionRepository {
  final ICloudService _cloud;

  PrescriptionRepository(this._cloud);

  Future<PrescriptionLoadResult> loadData(String appointmentId) async {
    final appointments = await _cloud.select(
      table: 'appointments',
      eq: {'id': appointmentId},
    );

    final apptRaw = appointments.isNotEmpty
        ? appointments.first
        : (await _cloud.select(table: 'appointments')).first;
    final patientId = apptRaw['patient_id'];

    final patients = await _cloud.select(
      table: 'patients',
      eq: {'id': patientId},
    );
    final patientRaw = patients.isNotEmpty
        ? patients.first
        : (await _cloud.select(table: 'patients')).first;

    final doctorId = apptRaw['doctor_id'] as String? ?? 'u-doc-1';
    final users = await _cloud.select(
      table: 'users',
      eq: {'id': doctorId},
    );
    final doctor = users.isNotEmpty ? users.first : {'name': AppStrings.generalPractitioner};

    final typeMap = apptRaw['appointment_types'] as Map<String, dynamic>? ?? {};
    final typeName = typeMap['name'] as String? ?? AppStrings.normalCheckup;

    List<String> selectedDiag = [];
    List<SelectedDrugModel> selectedDrugs = [];
    String prescNotes = '';
    String finalDiag = apptRaw['notes'] as String? ?? '';

    final prescriptions = await _cloud.select(
      table: 'prescriptions',
      eq: {'patient_id': patientId},
    );

    if (prescriptions.isNotEmpty) {
      final prescription = prescriptions.first;
      prescNotes = prescription['notes'] as String? ?? '';
      finalDiag = prescription['diagnosis'] as String? ?? '';

      if (finalDiag.isNotEmpty) {
        selectedDiag = finalDiag.split(' ، ');
      }

      final items = await _cloud.select(
        table: 'prescription_items',
        eq: {'prescription_id': prescription['id']},
      );

      for (final item in items) {
        final drugId = item['drug_id'] as String;
        final drugs = await _cloud.select(table: 'drugs', eq: {'id': drugId});
        final drugRaw = drugs.isNotEmpty
            ? drugs.first
            : {'trade_name': AppStrings.unknownDrug, 'generic_name': '', 'category': ''};

        selectedDrugs.add(SelectedDrugModel(
          id: drugId,
          tradeName: drugRaw['trade_name'] as String? ?? '',
          genericName: drugRaw['generic_name'] as String? ?? '',
          category: drugRaw['category'] as String? ?? '',
          doseFrequency: item['frequency'] as int?,
          doseDuration: item['duration'] as int?,
          doseTiming: item['timing'] as String?,
          isPrn: item['is_prn'] as bool? ?? false,
        ));
      }
    }

    return PrescriptionLoadResult(
      appointmentRaw: apptRaw,
      patientRaw: patientRaw,
      doctor: doctor,
      typeName: typeName,
      selectedDrugs: selectedDrugs,
      selectedDiagnosis: selectedDiag,
      finalDiagnosis: finalDiag,
      notes: prescNotes,
    );
  }

  Future<String?> save(PrescriptionState state) async {
    final appt = await _cloud.select(
      table: 'appointments',
      eq: {'id': state.appointmentId},
    );
    final actualPatientId = appt.isNotEmpty ? appt.first['patient_id'] : null;

    final newPresc = await _cloud.insert(
      table: 'prescriptions',
      data: {
        'clinic_id': state.clinicId,
        'doctor_id': 'u-doc-1',
        'patient_id': actualPatientId,
        'diagnosis': state.selectedDiagnosis.join(' ، ') +
            (state.finalDiagnosis.isNotEmpty ? ' - ${state.finalDiagnosis}' : ''),
        'notes': state.notes,
        'created_at': DateTime.now().toIso8601String(),
      },
    );

    for (final drug in state.selectedDrugs) {
      await _cloud.insert(
        table: 'prescription_items',
        data: {
          'prescription_id': newPresc['id'],
          'drug_id': drug.id,
          'frequency': drug.doseFrequency,
          'duration': drug.doseDuration,
          'timing': drug.doseTiming,
          'is_prn': drug.isPrn,
        },
      );
    }

    for (final diag in state.selectedDiagnosis) {
      final matchingTemplates = await _cloud.select(
        table: 'prescription_templates',
        eq: {'name': diag},
      );
      if (matchingTemplates.isNotEmpty) {
        final t = matchingTemplates.first;
        final currentCount = t['user_count'] as int? ?? 0;
        await _cloud.update(
          table: 'prescription_templates',
          data: {'user_count': currentCount + 1},
          matchColumn: 'id',
          matchValue: t['id'],
        );
      }
    }

    await _cloud.update(
      table: 'appointments',
      data: {'status': 'done'},
      matchColumn: 'id',
      matchValue: state.appointmentId,
    );

    return null;
  }

  Future<(List<SelectedDrugModel>, List<String>)> copyPrevious() async {
    final prescriptions = await _cloud.select(
      table: 'prescriptions',
      order: 'created_at',
      ascending: false,
    );

    if (prescriptions.isEmpty) {
      return (<SelectedDrugModel>[], <String>[]);
    }

    final lastPresc = prescriptions.first;
    final items = await _cloud.select(
      table: 'prescription_items',
      eq: {'prescription_id': lastPresc['id']},
    );

    final List<SelectedDrugModel> copiedDrugs = [];
    for (final item in items) {
      final drugId = item['drug_id'] as String;
      final drugs = await _cloud.select(table: 'drugs', eq: {'id': drugId});
      final drugRaw = drugs.isNotEmpty
          ? drugs.first
          : {'trade_name': AppStrings.unknownDrug, 'generic_name': '', 'category': ''};

      copiedDrugs.add(SelectedDrugModel(
        id: drugId,
        tradeName: drugRaw['trade_name'] as String? ?? '',
        genericName: drugRaw['generic_name'] as String? ?? '',
        category: drugRaw['category'] as String? ?? '',
        doseFrequency: item['frequency'] as int?,
        doseDuration: item['duration'] as int?,
        doseTiming: item['timing'] as String?,
        isPrn: item['is_prn'] as bool? ?? false,
      ));
    }

    final rawDiag = lastPresc['diagnosis'] as String? ?? '';
    final diags = rawDiag.isNotEmpty ? rawDiag.split(' ، ') : <String>[];

    return (copiedDrugs, diags);
  }

  Future<(List<SelectedDrugModel>, String)> getTemplateData(
    String templateId,
  ) async {
    final templateItems = await _cloud.select(
      table: 'prescription_template_items',
      eq: {'template_id': templateId},
    );

    final templates = await _cloud.select(
      table: 'prescription_templates',
      eq: {'id': templateId},
    );
    final template = templates.isNotEmpty ? templates.first : {'name': ''};
    final templateName = template['name'] as String? ?? '';

    final List<SelectedDrugModel> result = [];
    for (final item in templateItems) {
      final drugId = item['drug_id'] as String;
      final drugs = await _cloud.select(table: 'drugs', eq: {'id': drugId});
      final drugRaw = drugs.isNotEmpty
          ? drugs.first
          : {'trade_name': AppStrings.unknownDrug, 'generic_name': '', 'category': ''};

      result.add(SelectedDrugModel(
        id: drugId,
        tradeName: drugRaw['trade_name'] as String? ?? '',
        genericName: drugRaw['generic_name'] as String? ?? '',
        category: drugRaw['category'] as String? ?? '',
        doseFrequency: item['frequency'] as int?,
        doseDuration: item['duration'] as int?,
        doseTiming: item['timing'] as String?,
        isPrn: item['is_prn'] as bool? ?? false,
      ));
    }

    return (result, templateName);
  }
}

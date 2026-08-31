// ────────────────────────────────────────────────────────
import 'dart:convert';
import '../../domain/entities/prescription_entity.dart';
import 'drug_model.dart';

class PrescriptionItemModel extends PrescriptionItemEntity {
  const PrescriptionItemModel({
    required super.id,
    required super.prescriptionId,
    super.drugId,
    super.frequency,
    super.duration,
    super.timing,
    super.isPrn = false,
    super.drug,
  });

  factory PrescriptionItemModel.fromJson(Map<String, dynamic> json) {
    int? parseNum(dynamic val) {
      if (val is int) return val;
      if (val is String) return int.tryParse(val);
      return null;
    }

    final rawDrug = json['drug'] ?? json['drugs'];

    return PrescriptionItemModel(
      id: json['id'] as String? ?? '',
      prescriptionId: json['prescription_id'] as String? ?? '',
      drugId: json['drug_id'] as String?,
      frequency: parseNum(json['frequency']),
      duration: parseNum(json['duration']),
      timing: json['timing'] as String?,
      isPrn: json['is_prn'] as bool? ?? false,
      drug: rawDrug is Map<String, dynamic>
          ? DrugModel.fromJson(rawDrug)
          : (rawDrug is Map
              ? DrugModel.fromJson((rawDrug).cast<String, dynamic>())
              : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'prescription_id': prescriptionId,
      'drug_id': drugId,
      'frequency': frequency,
      'duration': duration,
      'timing': timing,
      'is_prn': isPrn,
    };
  }
}

class PrescriptionModel extends PrescriptionEntity {
  const PrescriptionModel({
    required super.id,
    required super.createdAt,
    super.clinicId,
    super.doctorId,
    super.patientId,
    super.appointmentId,
    super.patientName,
    super.patientPhone,
    super.diagnosis,
    super.diagnoses = const [],
    super.notes,
    super.nextVisitDays,
    super.items = const [],
  });

  factory PrescriptionModel.fromJson(Map<String, dynamic> json) {
    int? parseDays(dynamic val) {
      if (val == null) return null;
      if (val is int) return val;
      return int.tryParse(val.toString());
    }

    List<String> parseDiagnoses(dynamic raw) {
      if (raw == null) return [];
      if (raw is List) {
        return raw
            .map((e) => e.toString().trim())
            .where((e) => e.isNotEmpty && e != '[]' && e != 'null')
            .toList();
      }
      if (raw is String) {
        if (raw.contains(' ، ')) {
          return raw
              .split(' ، ')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty && e != '[]' && e != 'null')
              .toList();
        } else if (raw.contains(', ')) {
          return raw
              .split(', ')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty && e != '[]' && e != 'null')
              .toList();
        } else if (raw.contains(',')) {
          return raw
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty && e != '[]' && e != 'null')
              .toList();
        } else if (raw.trim().isNotEmpty && raw != '[]' && raw != 'null') {
          return [raw.trim()];
        }
      }
      return [];
    }

    // ─── استخراج كائن notes سواء كان Map أو JSON String ───
    Map<String, dynamic>? notesMap;
    if (json['notes'] is Map) {
      notesMap = (json['notes'] as Map).cast<String, dynamic>();
    } else if (json['notes'] is String) {
      final str = (json['notes'] as String).trim();
      if (str.startsWith('{') && str.endsWith('}')) {
        try {
          final decoded = jsonDecode(str);
          if (decoded is Map) {
            notesMap = decoded.cast<String, dynamic>();
          }
        } catch (_) {}
      }
    }

    // ─── قراءة أسماء القوالب المختارة من notes['diagnoses'] ───
    final parsedDiagnoses = parseDiagnoses(notesMap?['diagnoses']);

    // ─── قراءة نص التشخيص الحر من عمود diagnosis ───
    final String? rawDiagnosis = json['diagnosis']?.toString();
    final String? diagnosisText =
        (rawDiagnosis != null && rawDiagnosis.trim().isNotEmpty)
            ? rawDiagnosis.trim()
            : (parsedDiagnoses.isNotEmpty
                ? parsedDiagnoses.join(' ، ')
                : null);

    // ─── قراءة اسم وهاتف المريض إن وُجدا في الـ payload ───
    final rawPatient = json['patients'] ?? json['patient'];
    final String? patientName = rawPatient is Map
        ? (rawPatient['name']?.toString())
        : (json['patient_name']?.toString());
    final String? patientPhone = rawPatient is Map
        ? (rawPatient['phone']?.toString())
        : (json['patient_phone']?.toString());

    return PrescriptionModel(
      id: json['id'] as String,
      createdAt: json['created_at'] != null
          ? json['created_at'].toString()
          : DateTime.now().toIso8601String(),
      clinicId: json['clinic_id'] as String?,
      doctorId: json['doctor_id'] as String?,
      patientId: json['patient_id'] as String?,
      appointmentId: json['appointment_id'] as String?,
      patientName: patientName,
      patientPhone: patientPhone,
      diagnosis: diagnosisText,
      diagnoses: parsedDiagnoses,
      notes: notesMap != null
          ? notesMap['general_notes']?.toString()
          : (json['notes'] is String ? json['notes'] as String : null),
      nextVisitDays: parseDays(
        json['next_visit_days'] ?? notesMap?['next_visit_days'],
      ),
      items: json['prescription_items'] != null
          ? (json['prescription_items'] as List)
              .map((i) =>
                  PrescriptionItemModel.fromJson(i as Map<String, dynamic>))
              .toList()
          : const [],
    );
  }

  Map<String, dynamic> toJson() {

    return {
      'created_at': createdAt,
      'clinic_id': clinicId,
      'doctor_id': doctorId,
      'patient_id': patientId,
      'appointment_id': appointmentId,
      'next_visit_days': nextVisitDays,
      'diagnosis' : diagnosis,
      'notes': {
        'diagnoses': diagnoses,
        'general_notes': notes,
        if (nextVisitDays != null) 'next_visit_days': nextVisitDays,
      },
    };
  }
}

// ────────────────────────────────────────────────────────
// نموذج قاعدة الانتظار (QueueRuleModel)
// يرث من QueueRuleEntity ويضيف إمكانية التحويل من وإلى JSON
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/constants/supabase_constants.dart';

import '../../domain/entities/queue_rule_entity.dart';

class QueueRuleModel extends QueueRuleEntity {
  const QueueRuleModel({
    required super.id,
    required super.doctorId,
    required super.clinicId,
    required super.queueSystem,
    required super.slots,
    required super.cycleLength,
    super.avgVisitMinutes,
  });

  factory QueueRuleModel.fromJson(Map<String, dynamic> json) {
    return QueueRuleModel(
      id: json['id'] as String? ?? '',
      doctorId: json['doctor_id'] as String? ?? '',
      clinicId: json['clinic_id'] as String? ?? '',
      queueSystem: json['queue_system'] as String? ?? DoctorQueueSystem.arrival,
      slots: List<String>.from(json['slots'] as List? ?? const []),
      cycleLength: json['cycle_length'] as int? ?? 0,
      avgVisitMinutes: json['avg_visit_minutes'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'doctor_id': doctorId,
      'clinic_id': clinicId,
      'queue_system': queueSystem,
      'slots': slots,
      'cycle_length': cycleLength,
      'avg_visit_minutes': avgVisitMinutes,
    };
  }
}

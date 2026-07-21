// ────────────────────────────────────────────────────────
// كيان قاعدة انتظار الطبيب (QueueRuleEntity)
// يمثل النمط المخصص لترتيب قائمة الانتظار للعيادة
// ────────────────────────────────────────────────────────

import 'package:equatable/equatable.dart';

class QueueRuleEntity extends Equatable {
  final String id;
  final String doctorId;
  final String clinicId;
  final String queueSystem; // 'arrival', 'booking', 'pattern', 'scheduled'
  final List<String> slots; // مثل: ['normal', 'normal', 'urgent', 'revisit']
  final int cycleLength;
  final int? avgVisitMinutes;

  const QueueRuleEntity({
    required this.id,
    required this.doctorId,
    required this.clinicId,
    required this.queueSystem,
    required this.slots,
    required this.cycleLength,
    this.avgVisitMinutes,
  });

  @override
  List<Object?> get props => [
        id,
        doctorId,
        clinicId,
        queueSystem,
        slots,
        cycleLength,
        avgVisitMinutes,
      ];
}

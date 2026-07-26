// ────────────────────────────────────────────────────────
// حالة استخدام ترتيب طابور الانتظار (SortQueueUseCase)
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/features/settings/domain/entities/queue_rule_entity.dart';
import 'package:injectable/injectable.dart';
import '../../entities/appointment_entity.dart';
import '../../../../../core/utils/queue_sorter.dart';

@injectable
class SortQueueUseCase {
  SortQueueUseCase();

  List<AppointmentEntity> call({
    required List<AppointmentEntity> appointments,
    QueueRuleEntity? rule,
  }) {
    return QueueSorter.sort(
      appointments: appointments,
      rule: rule,
    );
  }
}

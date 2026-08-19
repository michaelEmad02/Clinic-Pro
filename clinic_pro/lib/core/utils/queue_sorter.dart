// ────────────────────────────────────────────────────────
// هذا الملف يحتوي على منطق ترتيب قائمة الانتظار (Queue Sorter)
// يتم الترتيب برمجياً في التطبيق (Client-side) دون تخزينه في قاعدة البيانات
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/constants/supabase_constants.dart';
import 'package:clinic_pro/features/appointments/domain/entities/appointment_entity.dart';
import 'package:clinic_pro/features/settings/domain/entities/queue_rule_entity.dart';

class QueueSorter {
  /// ترتيب المواعيد بناءً على القواعد التالية:
  /// 1. المواعيد التي بدأت أو انتهت (in_progress، done) تبقى ثابتة في البداية بترتيب استدعائها (calledAt).
  /// 2. الحالات الطارئة (isUrgent = true) تأتي أولاً في الانتظار دائماً في جميع الأنظمة.
  /// 3. بقية الحالات العادية يتم ترتيبها بناءً على النظام المحدد للطبيب (QueueRuleEntity).
  /// 4. في حال عدم وجود قواعد، يتم الترتيب الافتراضي حسب وقت الوصول (arrivedAt) تصاعدياً.
  static List<AppointmentEntity> sort({
    required List<AppointmentEntity> appointments,
    QueueRuleEntity? rule,
  }) {
    // 1. تصفية المواعيد التي وصلت ولم تُلغَ (يجب أن يكون arrivedAt غير فارغ ليدخل الطابور)
    final activeAppointments = appointments.where((appt) {
      return appt.arrivedAt != null && appt.status != 'cancelled';
    }).toList();

    // 2. تقسيم المواعيد إلى ثابتة (قيد الكشف حالياً أو المكتملة لليوم) ومنتظرة
    final fixedAppointments = activeAppointments.where((appt) {
      return appt.status == AppointmentStatus.inProgress ||
          appt.status == AppointmentStatus.done;
    }).toList();

    // ترتيب الثابتة بناءً على وقت الاستدعاء (calledAt)
    fixedAppointments.sort((a, b) {
      final aCalled = a.calledAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bCalled = b.calledAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return aCalled.compareTo(bCalled);
    });

    final waitingAppointments = activeAppointments.where((appt) {
      return appt.status == AppointmentStatus.confirmed;
    }).toList();

    // 3. فصل الحالات الطارئة المنتظرة (العاجلة تأتي أولاً قبل الحالات العادية)
    final urgentWaiting = waitingAppointments.where((appt) => appt.isUrgent).toList();
    urgentWaiting.sort((a, b) {
      final aArrived = a.arrivedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bArrived = b.arrivedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return aArrived.compareTo(bArrived);
    });

    // الحالات المنتظرة العادية
    final normalWaiting = waitingAppointments.where((appt) => !appt.isUrgent).toList();

    // 4. ترتيب الحالات العادية بناءً على نوع النظام
    List<AppointmentEntity> sortedNormal = [];

    if (rule != null) {
      switch (rule.queueSystem) {
        case DoctorQueueSystem.arrival:
          sortedNormal = _sortByArrival(normalWaiting);
          break;
        case DoctorQueueSystem.booking:
          sortedNormal = _sortByBooking(normalWaiting);
          break;
        case DoctorQueueSystem.pattern:
          if (rule.slots.isNotEmpty) {
            sortedNormal = _sortByPattern(
              normalWaiting,
              rule.slots,
              fixedAppointments.length + urgentWaiting.length,
            );
          } else {
            sortedNormal = _sortByArrival(normalWaiting);
          }
          break;
        case DoctorQueueSystem.scheduled:
          if (rule.avgVisitMinutes != null) {
            sortedNormal = _sortByScheduled(normalWaiting, rule.avgVisitMinutes!);
          } else {
            sortedNormal = _sortByArrival(normalWaiting);
          }
          break;
        default:
          sortedNormal = _sortByArrival(normalWaiting);
      }
    } else {
      sortedNormal = _sortByArrival(normalWaiting);
    }

    return [...fixedAppointments, ...urgentWaiting, ...sortedNormal];
  }

  // ① ترتيب الحضور (arrivedAt تصاعدياً)
  static List<AppointmentEntity> _sortByArrival(List<AppointmentEntity> entries) {
    return List.from(entries)
      ..sort((a, b) {
        final aArrived = a.arrivedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bArrived = b.arrivedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return aArrived.compareTo(bArrived);
      });
  }

  // ② ترتيب الحجز (date + time تصاعدياً)
  static List<AppointmentEntity> _sortByBooking(List<AppointmentEntity> entries) {
    return List.from(entries)
      ..sort((a, b) {
        final aDate = a.date;
        final bDate = b.date;
        if (aDate != bDate) {
          return aDate.compareTo(bDate);
        }
        final aTime = a.time ?? '00:00:00';
        final bTime = b.time ?? '00:00:00';
        return aTime.compareTo(bTime);
      });
  }

  // ③ نمط مخصص (تطابق مباشر عبر appt.typeId مع slots)
  static List<AppointmentEntity> _sortByPattern(
    List<AppointmentEntity> entries,
    List<dynamic> slots,
    int startIndex,
  ) {
    if (slots.isEmpty) return entries;
    final remaining = List<AppointmentEntity>.from(entries);
    final result = <AppointmentEntity>[];
    final cycleLength = slots.length;
    int slotOffset = 0;

    while (remaining.isNotEmpty) {
      final currentSlotIndex = (startIndex + result.length + slotOffset) % cycleLength;
      final rawSlot = slots[currentSlotIndex];
      final expectedType = rawSlot is Map
          ? (rawSlot['id']?.toString() ?? rawSlot['type_id']?.toString() ?? rawSlot.toString())
          : rawSlot.toString();

      final matchIndex = remaining.indexWhere((appt) {
        return appt.typeId == expectedType ||
            (appt.typeName != null && appt.typeName == expectedType);
      });

      if (matchIndex != -1) {
        result.add(remaining.removeAt(matchIndex));
        slotOffset = 0; // تفريغ الـ offset عند نجاح التنسيق لضمان استمرار النمط
      } else {
        slotOffset++;
        // إذا نفدت المحاولات في الدورة الكاملة لتجنب الجمود، نضيف المتبقي بالترتيب الافتراضي
        if (slotOffset >= cycleLength) {
          result.addAll(remaining);
          break;
        }
      }
    }
    return result;
  }

  // ④ مواعيد بوقت محدد (تحديث أوقات الاستدعاء المتوقعة)
  static List<AppointmentEntity> _sortByScheduled(
    List<AppointmentEntity> entries,
    int avgMinutes,
  ) {
    final sorted = _sortByBooking(entries);
    if (sorted.isEmpty) return sorted;

    DateTime currentExpected = DateTime.now();
    final result = <AppointmentEntity>[];

    for (final appt in sorted) {
      result.add(appt.copyWith(
        expectedCallTime: currentExpected,
      ));
      currentExpected = currentExpected.add(Duration(minutes: avgMinutes));
    }
    return result;
  }
}

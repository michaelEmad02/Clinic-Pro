# business_logic.md — Appointments & Queue Feature

---

## Appointment Types — Two-Table Design

```
appointment_types (lookup — developer-managed):
  id, name, notes
  → global catalog: كشف عادي, مستعجل, إعادة كشف, استشارة...
  → read-only from the app

doctor_appointment_types (doctor-specific pricing):
  id, appointment_type_id, doctor_id, clinic_id (nullable), price
  → doctor links to catalog type and sets their own price
  → clinic_id = null → fallback price for any clinic
```

### Pricing Fallback Resolution

```dart
Future<DoctorAppointmentType?> resolveType({
  required String appointmentTypeId,
  required String doctorId,
  required String clinicId,
}) async {
  // 1. exact match: this doctor + this clinic
  final exact = await getType(
    appointmentTypeId: appointmentTypeId,
    doctorId: doctorId,
    clinicId: clinicId,
  );
  if (exact != null) return exact;

  // 2. fallback: doctor entry with clinic_id IS NULL
  return await getType(
    appointmentTypeId: appointmentTypeId,
    doctorId: doctorId,
    clinicId: null,
  );
}
```

---

## Queue Systems — 4 Options

The doctor chooses ONE system per clinic via Settings.
Stored in `doctor_queue_rules.queue_system`.

### ① arrival — ترتيب الحضور (default)
```
Sort by: arrived_at ASC
Use case: most general clinics
is_urgent always overrides
```

### ② booking — ترتيب الحجز
```
Sort by: appointment.time ASC
Use case: clinics with strict appointment schedules
is_urgent always overrides
```

### ③ pattern — نمط مخصص
```
Doctor defines a repeating cycle: ['normal','normal','normal','urgent']
Applied to waiting patients starting from after fixed (done/in_progress) entries
is_urgent always overrides pattern
Requires: slots (jsonb) + cycle_length
```

### ④ scheduled — مواعيد بوقت محدد
```
Sort by: appointment.time ASC
Each patient gets an expected call time:
  expectedCallTime[0] = appointment[0].time
  expectedCallTime[n] = expectedCallTime[n-1] + avg_visit_minutes
Shown in queue UI as "الوقت المتوقع: 10:30 ص"
Updates dynamically as doctor progresses
is_urgent always overrides
Requires: avg_visit_minutes
```

---

## QueueSorter Algorithm

```dart
// core/utils/queue_sorter.dart

class QueueSorter {
  static List<AppointmentEntity> sort({
    required List<AppointmentEntity> appointments,
    required DoctorQueueRuleEntity rule,
  }) {
    // الطوارئ دايماً أول — في كل الأنظمة
    final fixed   = appointments.where((a) =>
        a.status == 'done' || a.status == 'in_progress').toList();
    final waiting = appointments.where((a) =>
        a.status == 'confirmed').toList();
    final urgent  = waiting.where((a) => a.isUrgent).toList();
    final normal  = waiting.where((a) => !a.isUrgent).toList();

    final sorted = switch (rule.queueSystem) {
      'arrival'   => _sortByArrival(normal),
      'booking'   => _sortByBooking(normal),
      'pattern'   => _sortByPattern(normal, rule.slots!, fixed.length),
      'scheduled' => _sortByScheduled(normal, rule.avgVisitMinutes),
      _           => _sortByArrival(normal),
    };

    return [...fixed, ...urgent, ...sorted];
  }

  // ① ترتيب الحضور
  static List<AppointmentEntity> _sortByArrival(
      List<AppointmentEntity> entries) =>
    entries..sort((a, b) => a.arrivedAt!.compareTo(b.arrivedAt!));

  // ② ترتيب الحجز
  static List<AppointmentEntity> _sortByBooking(
      List<AppointmentEntity> entries) =>
    entries..sort((a, b) => a.time!.compareTo(b.time!));

  // ③ نمط مخصص
  static List<AppointmentEntity> _sortByPattern(
    List<AppointmentEntity> entries,
    List<String> pattern,
    int startIndex,
  ) {
    if (pattern.isEmpty) return entries;
    final result = <AppointmentEntity>[];
    int n = 0, pos = startIndex;

    while (n < entries.length) {
      // كل أنواع الزيارات غير المستعجلة تعامَل كـ 'normal'
      // إلا لو الدكتور أضاف slots خاصة لـ consult/revisit
      result.add(entries[n++]);
      pos++;
    }
    return result;
  }

  // ④ مواعيد بوقت محدد
  static List<AppointmentEntity> _sortByScheduled(
    List<AppointmentEntity> entries,
    int? avgMinutes,
  ) {
    entries.sort((a, b) => a.time!.compareTo(b.time!));

    if (avgMinutes != null && entries.isNotEmpty) {
      var expectedTime = entries.first.time!;
      for (final entry in entries) {
        entry.expectedCallTime = expectedTime;
        expectedTime = expectedTime.replacing(
          hour:   expectedTime.hour + ((expectedTime.minute + avgMinutes) ~/ 60),
          minute: (expectedTime.minute + avgMinutes) % 60,
        );
      }
    }
    return entries;
  }
}
```

---

## Queue Slot Types vs Appointment Types

```
QueueSlotType (used in pattern system only):
  'normal' | 'urgent' | 'consult' | 'revisit'

Default mapping:
  is_urgent = true         → always treated as 'urgent' in ALL systems
  any other visit type     → treated as 'normal' unless doctor added
                             specific 'consult' or 'revisit' slots in pattern

Most doctors only need: ['normal','normal','normal','urgent']
All non-urgent types (consultation, revisit, etc.) fill 'normal' slots equally.
```

---

## Status Transitions

```
scheduled   → confirmed   (secretary confirms arrival — sets arrived_at)
confirmed   → in_progress (doctor calls patient — sets called_at)
in_progress → done        (doctor saves prescription)
any         → cancelled   (owner or secretary — except 'done')
```

---

## Business Rules

```
- appointment.price    = expected_fee from resolved doctor_appointment_types.price
- arrived_at           = set explicitly on arrival confirmation
- called_at            = set explicitly when doctor calls patient
- is_urgent            = secretary or doctor can toggle anytime
- created_by           = MUST be set to auth.uid() — never rely on DB default
- Queue = appointments WHERE arrived_at IS NOT NULL AND date = today
- Sorting computed in Flutter (QueueSorter) — never stored back to DB
- is_urgent overrides queue order in ALL 4 systems
```

---

## Validations

```
patient_id:        required
doctor_id:         required
type_id:           required (FK → doctor_appointment_types.id)
                   must resolve via fallback logic — error if not found
date:              required
time:              optional in DB, required in UI

queue_system = 'pattern':
  slots:           required, non-empty array of QueueSlotType values
  cycle_length:    required, must equal slots.length

queue_system = 'scheduled':
  avg_visit_minutes: required, > 0
```

---

## Realtime

```dart
supabase
  .channel('appointments:$clinicId')
  .onPostgresChanges(
    event: PostgresChangeEvent.all,
    schema: 'public',
    table: 'appointments',
    filter: PostgresChangeFilter(
      type: PostgresChangeFilterType.eq,
      column: 'clinic_id',
      value: clinicId,
    ),
    callback: (_) => refreshAndResort(), // re-fetch → QueueSorter.sort()
  )
  .subscribe();
```

# business_logic.md — Appointments & Queue Feature

---

## Appointment Types — Two-Table Design

```
appointment_types (lookup — developer-managed):
  id, name, notes
  → global catalog of type names (كشف عادي, مستعجل, إعادة كشف, استشارة...)
  → read-only from the app — never created/edited by clinic users

doctor_appointment_types (doctor-specific pricing):
  id, appointment_type_id, doctor_id, clinic_id (nullable), price
  → doctor links to a type from the catalog and sets their own price
  → clinic_id can be null to represent a "default" price for any clinic
```

---

## Appointment Type Pricing — Fallback Logic

When booking an appointment, the system resolves the price as follows:

```dart
Future<DoctorAppointmentType?> resolveType({
  required String appointmentTypeId,
  required String doctorId,
  required String clinicId,
}) async {
  // 1. Try: exact match for this doctor + this clinic
  final exact = await getType(
    appointmentTypeId: appointmentTypeId,
    doctorId: doctorId,
    clinicId: clinicId,
  );
  if (exact != null) return exact;

  // 2. Fallback: doctor entry with no specific clinic (clinic_id IS NULL)
  final fallback = await getType(
    appointmentTypeId: appointmentTypeId,
    doctorId: doctorId,
    clinicId: null,
  );
  return fallback; // null if doctor hasn't configured this type at all
}
```

**Example:**
```
Doctor Ahmed works in Clinic A and Clinic B.
He configured:
  كشف عادي   → Clinic A: 150 EGP | clinic_id = null (fallback): 100 EGP
  مستعجل     → clinic_id = null: 200 EGP  (no clinic-specific entry)

Result:
  Clinic A → كشف عادي: 150 EGP (exact match)
  Clinic B → كشف عادي: 100 EGP (fallback — no Clinic B entry)
  Clinic A → مستعجل: 200 EGP (fallback — no clinic-specific entry)
  Clinic B → مستعجل: 200 EGP (fallback)
```

---

## Queue Slot Types vs Appointment Types — Important Distinction

```
QueueSlotType (doctor_queue_rules.slots):
  'normal' | 'urgent' | 'consult' | 'revisit'
  → used ONLY for queue ordering logic
  → does NOT map 1:1 to appointment_types

The relationship:
  - 'urgent' slot → maps to the "مستعجل" appointment type
  - 'normal' slot → maps to ANY non-urgent type by default
    (كشف عادي, استشارة, إعادة كشف all treated as 'normal' in the queue)
  - 'consult' / 'revisit' slots → optional, if doctor wants finer
    queue distinction between these types

Default behavior if type is not explicitly mapped in queue rules:
  → treated as 'normal' slot (ordered by arrived_at within the slot)

This means a doctor who only distinguishes urgent vs non-urgent
simply uses pattern ['normal','normal','normal','urgent'] and all
non-urgent visit types (consultation, revisit, etc.) are treated equally.
```

---

## Status Transitions

```
scheduled   → confirmed   (secretary confirms patient arrived — sets arrived_at)
confirmed   → in_progress (doctor calls patient — sets called_at)
in_progress → done        (doctor saves prescription/examination)
any         → cancelled   (owner or secretary — except 'done')
```

---

## Business Rules

```
- appointment.price = expected_fee (copied from resolved doctor_appointment_types.price)
- arrived_at = set when secretary confirms arrival (enters queue)
- called_at  = set when doctor calls patient (in_progress)
- is_urgent  = secretary or doctor can toggle at any time
- created_by MUST be explicitly set to auth.uid() on insert
- Doctor can only confirm examination for their own appointments
- Secretary can book for any doctor in the clinic
- Cancellation allowed at any status except 'done'
- Deletion allowed: removes the appointment and any associated invoices from the database completely
- No separate queue table — queue is derived from appointments
```

---

## Waiting Queue Logic

```
Queue = appointments WHERE:
  date = today
  AND arrived_at IS NOT NULL
  AND status != 'cancelled'
  AND doctor_id = current doctor

Sorting (computed in Flutter — QueueSorter.sort()):
  ① Fixed:   status IN ('done','in_progress') → stay in place
  ② Urgent:  is_urgent = true → always first among waiting
  ③ Waiting: apply doctor_queue_rules pattern starting from fixed.length

Non-urgent types (consult, revisit, normal) all fall into 'normal' slots
unless the doctor has explicitly added 'consult'/'revisit' slots to their pattern.
```

### Pattern Application

```
pattern = ['normal','normal','normal','urgent']
position = (startIndex + waitingIndex) % cycle_length

Any appointment type that is NOT 'urgent' (is_urgent=false) occupies
a 'normal' slot regardless of its actual appointment_type name.
```

### Example

```
Pattern: [normal, normal, normal, urgent]
Appointments waiting (all arrived): كشف عادي, استشارة, إعادة كشف, مستعجل

أحمد  ✅ done             → fixed at 1
سارة  🔵 in_progress      → fixed at 2
─── startIndex = 2 ───
خالد  كشف عادي  ⏳        → slot 3 = normal ✅
رنا   استشارة   ⏳         → slot 4 = urgent → but rena is NOT urgent
                             → takes slot 4 as normal (no urgent patient available)
مريض  مستعجل 🚨 ⏳ is_urgent=true → jumps ahead via urgent priority

Display result:
1. أحمد   ✅
2. سارة   🔵
3. 🚨 مستعجل
4. خالد (كشف عادي)
5. رنا   (استشارة — treated as normal)
```

---

## QueueSorter Algorithm

```dart
// core/utils/queue_sorter.dart

class QueueSorter {
  static List<AppointmentEntity> sort({
    required List<AppointmentEntity> appointments,
    required List<String> pattern,  // from doctor_queue_rules.slots
  }) {
    final fixed = appointments
        .where((a) => a.status == 'done' || a.status == 'in_progress')
        .toList();

    final waiting = appointments
        .where((a) => a.status == 'confirmed')
        .toList();

    final urgent = waiting.where((a) => a.isUrgent).toList();
    final normal = waiting.where((a) => !a.isUrgent).toList();

    final startIndex = fixed.length;
    final sorted = _applyPattern(normal, urgent, pattern, startIndex);

    return [...fixed, ...sorted];
  }

  static List<AppointmentEntity> _applyPattern(
    List<AppointmentEntity> normalEntries,
    List<AppointmentEntity> urgentEntries,
    List<String> pattern,
    int startIndex,
  ) {
    if (pattern.isEmpty) return [...urgentEntries, ...normalEntries];

    final result = <AppointmentEntity>[];
    int n = 0, u = 0, pos = startIndex;

    while (n < normalEntries.length || u < urgentEntries.length) {
      final slotType = pattern[pos % pattern.length];
      if (slotType == 'urgent' && u < urgentEntries.length) {
        result.add(urgentEntries[u++]);
      } else if (n < normalEntries.length) {
        result.add(normalEntries[n++]);
      } else if (u < urgentEntries.length) {
        result.add(urgentEntries[u++]);
      }
      pos++;
    }
    return result;
  }
}
```

---

## Doctor Queue Rules Configuration

```
One rule per (doctor_id, clinic_id) pair.
slots: jsonb array using QueueSlotType values.
cycle_length must equal slots.length.
If no active rule: default sort by arrived_at ASC.
```

---

## Validations

```
patient_id:        required
doctor_id:         required
type_id:           required (FK → doctor_appointment_types.id)
date:              required
time:              optional in DB, required in UI
appointment_type resolution: must find at least a fallback entry — show
  "نوع الزيارة غير متاح لهذا الطبيب" if no entry found in either
  clinic-specific or fallback (null clinic_id) rows
```

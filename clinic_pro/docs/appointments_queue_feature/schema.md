# schema.md — Appointments & Queue Feature

---

## Tables

### `appointment_types` — Lookup Table (developer-managed)

Global catalog of visit type names — managed by developers, not by clinic users.
Similar pattern to `expense_categories`.

| Column | Type | Nullable | Default | Notes |
|--------|------|----------|---------|-------|
| `id` | uuid | NO | `gen_random_uuid()` | |
| `name` | text | NO | — | e.g. "كشف عادي", "مستعجل", "إعادة كشف" |
| `notes` | text | YES | — | optional description |

> This table is **read-only from the app** — populated and managed by developers.
> Clinic users never create or modify rows here.
> Acts as a shared catalog that `doctor_appointment_types` references.

---

### `doctor_appointment_types` — Doctor-Specific Pricing

Links a doctor to visit types with their own pricing, per clinic.
A doctor can have different prices per clinic, or reuse the same across clinics.

| Column | Type | Nullable | Default | Notes |
|--------|------|----------|---------|-------|
| `id` | uuid | NO | `gen_random_uuid()` | |
| `appointment_type_id` | uuid | NO | — | FK → appointment_types.id |
| `price` | real (float4) | YES | — | doctor's price for this type |
| `doctor_id` | uuid | NO | — | FK → users.id |
| `clinic_id` | uuid | YES | — | nullable — see fallback logic below |

> **`clinic_id` is nullable by design** — this enables the fallback pricing logic:
> If a doctor has no entry for a specific clinic, the system falls back to
> the doctor's entry where `clinic_id IS NULL` (or the entry for their first clinic).
> See `business_logic.md` for the full fallback resolution.

---

### `appointments`

| Column | Type | Nullable | Default | Notes |
|--------|------|----------|---------|-------|
| `id` | uuid | NO | `gen_random_uuid()` | |
| `clinic_id` | uuid | NO | — | |
| `doctor_id` | uuid | NO | — | |
| `patient_id` | uuid | NO | — | |
| `type_id` | uuid | NO | — | FK → doctor_appointment_types.id |
| `date` | date | NO | — | |
| `time` | time | YES | — | |
| `status` | appointment_status (enum) | NO | — | |
| `price` | real (float4) | NO | — | expected_fee — copied at booking time |
| `notes` | text | YES | — | |
| `created_by` | uuid | NO | `gen_random_uuid()` ⚠️ | always set explicitly to `auth.uid()` |
| `created_at` | timestamp (no tz) | NO | `now() AT TIME ZONE 'utc'` | ⚠️ naive UTC — see note |
| `is_urgent` | bool | YES | `false` | |
| `arrived_at` | timestamptz | YES | — | set on secretary confirms arrival |
| `called_at` | timestamptz | YES | — | set when doctor calls patient |

> ⚠️ `created_by` has a random-UUID default — must always be set to `auth.uid()` explicitly.
> ⚠️ Mixed timestamps: `created_at` has no timezone; `arrived_at`/`called_at` do.
> Convert `created_at` to UTC-aware DateTime before comparing with the other two.

---

### `doctor_queue_rules`

| Column | Type | Nullable | Default | Notes |
|--------|------|----------|---------|-------|
| `id` | uuid | NO | `gen_random_uuid()` | |
| `doctor_id` | uuid | NO | — | |
| `clinic_id` | uuid | NO | — | |
| `slots` | jsonb | YES | — | e.g. `["normal","normal","normal","urgent"]` |
| `cycle_length` | smallint | NO | — | must equal `slots.length` |
| `is_active` | bool | NO | — | no default — set explicitly |

---

## Enums

### `appointment_status`
```sql
'scheduled', 'confirmed', 'in_progress', 'done', 'cancelled'
```

### `QueueSlotType`
```sql
'normal', 'urgent', 'consult', 'revisit'
```

---

## Constants

```dart
class SupabaseTables {
  static const appointmentTypes        = 'appointment_types';         // lookup — read-only
  static const doctorAppointmentTypes  = 'doctor_appointment_types';  // doctor pricing
  static const appointments            = 'appointments';
  static const doctorQueueRules        = 'doctor_queue_rules';
}

class AppointmentStatus {
  static const scheduled  = 'scheduled';
  static const confirmed  = 'confirmed';
  static const inProgress = 'in_progress';
  static const done       = 'done';
  static const cancelled  = 'cancelled';
}

class QueueSlotType {
  static const normal  = 'normal';
  static const urgent  = 'urgent';
  static const consult = 'consult';
  static const revisit = 'revisit';
}
```

---

## Queue System

```
Queue = appointments WHERE arrived_at IS NOT NULL AND date = today
Sorting computed in Flutter (QueueSorter) — never stored back to DB.
```

See `business_logic.md` for full algorithm.

---

## Outstanding Schema Issues

```
1. appointments.created_by   → random-UUID default (should be NOT NULL, no default)
2. appointments.created_at   → no timezone (inconsistent with arrived_at/called_at)
3. invitations table         → does not exist yet in DB (see schema_audit.md)
```

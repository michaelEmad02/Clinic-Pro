# schema.md — Appointments & Queue Feature

> ✅ Verified against live Supabase project `sybsvobonipnmvymauvc` on 2025

---

## Tables

### `appointment_types` — Lookup Table (developer-managed)

Global catalog of visit type names — managed by developers only.
Similar pattern to `expense_categories`. Read-only from the app.

| Column | Type | Nullable | Default |
|--------|------|----------|---------|
| `id` | uuid | NO | `gen_random_uuid()` |
| `name` | text | NO | — |
| `notes` | text | YES | — |

---

### `doctor_appointment_types` — Doctor-Specific Pricing

| Column | Type | Nullable | Default | Notes |
|--------|------|----------|---------|-------|
| `id` | uuid | NO | `gen_random_uuid()` | |
| `appointment_type_id` | uuid | NO | — | FK → appointment_types.id |
| `price` | real | YES | — | |
| `doctor_id` | uuid | NO | — | FK → users.id |
| `clinic_id` | uuid | YES | — | nullable = fallback price for any clinic |

> **`clinic_id` nullable by design** — enables fallback pricing logic.
> See `business_logic.md` for resolution algorithm.

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
| `status` | appointment_status | NO | — | |
| `price` | real | NO | — | expected_fee — copied at booking |
| `notes` | text | YES | — | |
| `is_urgent` | bool | YES | `false` | overrides queue pattern |
| `arrived_at` | timestamptz | YES | — | set on arrival confirmation |
| `called_at` | timestamptz | YES | — | set when doctor calls patient |
| `created_by` | uuid | NO | `gen_random_uuid()` ⚠️ | always set to `auth.uid()` explicitly |
| `created_at` | timestamp | NO | `now() AT TIME ZONE 'utc'` | ⚠️ no timezone |

> ⚠️ `created_by` has random-UUID default — must always be set explicitly.
> ⚠️ Mixed timestamps: `created_at` has no timezone; `arrived_at`/`called_at` do.

---

### `doctor_queue_rules` ✅ (updated)

| Column | Type | Nullable | Default | Notes |
|--------|------|----------|---------|-------|
| `id` | uuid | NO | `gen_random_uuid()` | |
| `doctor_id` | uuid | NO | — | |
| `clinic_id` | uuid | NO | — | |
| `queue_system` | text | NO | `'arrival'` | CHECK IN ('arrival','booking','pattern','scheduled') |
| `slots` | jsonb | YES | — | used only when queue_system = 'pattern' |
| `cycle_length` | smallint | NO | — | used only when queue_system = 'pattern' |
| `avg_visit_minutes` | smallint | YES | — | used only when queue_system = 'scheduled' |
| `is_active` | bool | NO | — | set explicitly |

> **Column usage per queue_system:**
>
> | queue_system | slots | cycle_length | avg_visit_minutes |
> |-------------|-------|--------------|-------------------|
> | `arrival` | ignored | ignored | ignored |
> | `booking` | ignored | ignored | ignored |
> | `pattern` | ✅ required | ✅ required | ignored |
> | `scheduled` | ignored | ignored | ✅ required |

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
  static const appointmentTypes       = 'appointment_types';
  static const doctorAppointmentTypes = 'doctor_appointment_types';
  static const appointments           = 'appointments';
  static const doctorQueueRules       = 'doctor_queue_rules';
}

class AppointmentStatus {
  static const scheduled  = 'scheduled';
  static const confirmed  = 'confirmed';
  static const inProgress = 'in_progress';
  static const done       = 'done';
  static const cancelled  = 'cancelled';
}

class QueueSystem {
  static const arrival   = 'arrival';    // ترتيب الحضور
  static const booking   = 'booking';    // ترتيب الحجز
  static const pattern   = 'pattern';    // نمط مخصص
  static const scheduled = 'scheduled';  // مواعيد بوقت محدد
}

class QueueSlotType {
  static const normal  = 'normal';
  static const urgent  = 'urgent';
  static const consult = 'consult';
  static const revisit = 'revisit';
}
```

---

## Outstanding Schema Issues

```
1. appointments.created_by  → random-UUID default — always set explicitly
2. appointments.created_at  → no timezone — inconsistent with arrived_at/called_at
```

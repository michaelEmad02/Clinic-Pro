# schema.md — Patients Feature

---

## Table

### `patients`

| Column | Type | Nullable | Default | Notes |
|--------|------|----------|---------|-------|
| `id` | uuid | NO | `gen_random_uuid()` | |
| `owner_id` | uuid | NO | — | FK → Owners.id — shared across owner's clinics |
| `name` | text | NO | — | |
| `phone` | text | YES | — | |
| `address` | text | YES | — | |
| `date_of_birth` | date | YES | — | |
| `allergies` | text | YES | — | free text |
| `chronic_conditions` | text | YES | — | free text |
| `gender` | gender (enum) | **NO** ⚠️ | — | required |
| `blood_type` | blood_type (enum) | YES | — | optional |

> ⚠️ `gender` is **required** — not optional as previously documented.
> Patient form must enforce gender selection.

---

## Enums

### `gender`
```sql
'male', 'female'
```

### `blood_type`
```sql
'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'
```

---

## Constants

```dart
class SupabaseTables {
  static const patients = 'patients';
}

class Gender {
  static const male   = 'male';
  static const female = 'female';
}

class BloodType {
  static const aPos  = 'A+';
  static const aNeg  = 'A-';
  static const bPos  = 'B+';
  static const bNeg  = 'B-';
  static const abPos = 'AB+';
  static const abNeg = 'AB-';
  static const oPos  = 'O+';
  static const oNeg  = 'O-';
}
```

---

## Related Files
- `business_logic.md` — patient scoping, validations
- `ui.md` — Patients, Patient Details screens

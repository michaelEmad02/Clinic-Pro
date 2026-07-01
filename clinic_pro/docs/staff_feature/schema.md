# schema.md — Clinics & Staff Feature

---

## Tables

### `clinics`

| Column | Type | Nullable | Default | Notes |
|--------|------|----------|---------|-------|
| `id` | uuid | NO | `gen_random_uuid()` | |
| `created_at` | timestamptz | NO | `now()` | |
| `owner_id` | uuid | NO | — | FK → Owners.id |
| `name` | text | NO | — | |
| `address` | text | YES | — | |
| `phone1` | text | YES | — | |
| `phone2` | text | YES | — | |
| `logo_url` | text | YES | — | |
| `is_active` | bool | NO | `true` | |

Comment: *"يحتوي علي بيانات العيادات"*

---

### `clinic_staff`

| Column | Type | Nullable | Default | Notes |
|--------|------|----------|---------|-------|
| `id` | uuid | NO | `gen_random_uuid()` | |
| `clinic_id` | uuid | YES ⚠️ | `gen_random_uuid()` ⚠️ | FK → clinics.id |
| `user_id` | uuid | NO | — | FK → users.id |
| `role` | staff_role (enum) | NO | — | see enum below |
| `is_active` | bool | NO | `true` | |
| `joined_at` | timestamptz | NO | `now()` | |

> ⚠️ **`clinic_id` is nullable with a random UUID default** — this looks like a schema bug.
> A row with `clinic_id` defaulting to a *new random UUID* (not linked to any real clinic) would create orphaned data.
> **Action needed:** This should likely be `NOT NULL` with no default, forcing explicit assignment.
> Flag this to the backend owner before relying on `clinic_id` uniqueness.

Comment: *"يحتوي علي موظفين كل عياده"*

---

### `staff_role` (enum)

```sql
'doctor', 'secretary'
```

> ⚠️ **Only 2 values currently** — `nurse` and `accountant` are NOT in the database enum,
> even though the `users` table comment mentions them. These roles are confirmed
> **not yet available** — see `upcoming_features.md` → "Additional Staff Roles".
>
> Do NOT build UI that allows selecting nurse/accountant until the enum is updated.

---

### `invitations`

> ⚠️ **This table was NOT found in the live Supabase project.**
> It exists only in the planning docs — not yet created in the database.
> Must be created before implementing the invitation flow (Phase 10).

**Planned schema (not yet in DB):**

```sql
CREATE TABLE invitations (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  clinic_id   uuid REFERENCES clinics(id),
  owner_id    uuid REFERENCES "Owners"(id),
  email       text NOT NULL,
  name        text,
  role        staff_role NOT NULL,
  token       text UNIQUE NOT NULL,
  status      text DEFAULT 'pending' CHECK (status IN ('pending','accepted','expired')),
  expires_at  timestamptz DEFAULT now() + interval '7 days',
  created_at  timestamptz DEFAULT now()
);
```

---

## Constants

```dart
class SupabaseTables {
  static const clinics      = 'clinics';
  static const clinicStaff  = 'clinic_staff';
  static const invitations  = 'invitations';  // not yet created in DB
}

class StaffRole {
  static const doctor    = 'doctor';
  static const secretary = 'secretary';
  // nurse, accountant — NOT YET AVAILABLE (see upcoming_features.md)
}
```

---

## Related Files
- `business_logic.md` — invitation flow, role permissions
- `ui.md` — Clinics, Clinic Details, Staff screens

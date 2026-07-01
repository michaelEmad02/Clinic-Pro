# business_logic.md — Auth Feature

---

## Registration Rules

- Only **Owners** self-register (Google / Apple / Magic Link)
- **Staff** never self-register — only via invitation (see `clinics_staff/business_logic.md`)
- `Owners` table requires `name`, `phone`, `country`, `address` — all NOT NULL.
  Registration form must collect all 4 before creating the record.

---

## Session Detection Flow

```
auth.uid() exists?
  ├── found in "Owners" table → UserType.owner  → Owner Dashboard
  ├── found in "users" table  → check is_active
  │     ├── true  → check clinic_staff → get role → Staff Dashboard
  │     └── false → "Account suspended" screen
  └── not found → logout + Login screen
```

> ⚠️ Table name is `"Owners"` (capital O) — case-sensitive in Postgres when quoted.
> Supabase client query must match exactly: `.from('Owners')`

---

## Multi-Clinic Staff

```
user found in clinic_staff with multiple active clinic rows:
  → show Clinic Picker Bottom Sheet
  → user selects active clinic
  → session stores: currentClinicId + currentRole
```

---

## Owner-as-Doctor

```
If Owners.id == auth.uid() AND same id exists in clinic_staff with role='doctor':
  → user has BOTH owner permissions AND doctor permissions
  → UI shows owner-level Settings + doctor-level Prescription/Queue features
```

---

## Validations

```
name:     required, min 2 chars
phone:    required, valid format
country:  required
address:  required
```

# schema.md — Auth Feature

---

## Tables

### `Owners` ⚠️ (capital O — not `owners`)

| Column | Type | Nullable | Default | Notes |
|--------|------|----------|---------|-------|
| `id` | uuid | NO | `gen_random_uuid()` | = `auth.uid()` |
| `name` | text | **NO** | — | required |
| `phone` | text | **NO** | — | required |
| `country` | text | **NO** | — | required |
| `address` | text | **NO** | — | required |
| `created_at` | timestamptz | NO | `now()` | |

> ⚠️ All fields are **NOT NULL** — must be collected during registration, not optional.

---

### `users` (Staff)

| Column | Type | Nullable | Default | Notes |
|--------|------|----------|---------|-------|
| `id` | uuid | NO | `gen_random_uuid()` | = `auth.uid()` |
| `owner_id` | uuid | NO | — | FK → Owners.id |
| `name` | text | NO | — | |
| `address` | text | YES | — | |
| `phone` | text | YES | — | |
| `specialty` | text | YES | — | doctors only |
| `image_url` | text | YES | — | Supabase Storage URL |
| `is_active` | bool | NO | `true` | |
| `created_at` | timestamptz | NO | `now()` | |

> No `email` column — auth identity comes entirely from Supabase Auth (`auth.users`).
> No password field — Google/Apple/Magic Link only.

---

## Table Comments (from Supabase)

```
Owners:       "يحتوي علي بيانات مالك العياده او لو اكثر من عياده (مستثمر - طبيب - مجمع طبي..)"
users:        "contains users like (Doctor , secretary , nurse, accountant)"
              ⚠️ Comment mentions nurse/accountant but staff_role enum currently
              only supports doctor/secretary — see clinics_staff/schema.md
```

---

## Constants

```dart
// core/constants/supabase_constants.dart (auth section)

class SupabaseTables {
  static const owners = 'Owners';   // ⚠️ Capital O — exact match required
  static const users  = 'users';
}
```

---

## Related Files
- `business_logic.md` — login flow, session detection
- `ui.md` — Splash, Login, Create Account, Accept Invitation screens

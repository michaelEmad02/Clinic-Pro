# schema.md — Financial Feature (Invoices & Expenses)

## Tables

### `invoices`

| Column | Type | Nullable | Default | Notes |
|--------|------|----------|---------|-------|
| `id` | uuid | NO | `gen_random_uuid()` | |
| `clinic_id` | uuid | YES | `gen_random_uuid()` ⚠️ | pass explicitly |
| `patient_id` | uuid | YES | `gen_random_uuid()` ⚠️ | pass explicitly |
| `source_id` | uuid | NO | `gen_random_uuid()` ⚠️ | pass explicitly — references appointments.id |
| `source_type` | invoices_source_type (enum) ✅ | NO | `gen_random_uuid()`?? | see note below |
| `total_amount` | real (float4) | NO | — | |
| `paid_amount` | real (float4) | NO | — | |
| `created_by` | uuid | YES | `gen_random_uuid()` ⚠️ | pass explicitly |
| `created_at` | timestamptz | NO | `now()` | |
| `payment_method` | text | YES | — | optional |

> ✅ `source_type` was migrated from `uuid` to a proper enum `invoices_source_type`
> on 2025 per your request. Current enum has 1 value: `'appointment'`.
> Extensible for future source types.
>
> ⚠️ Note: `source_type`'s default still shows as a UUID-generating function in
> some metadata views due to the migration — verify the actual default resolves
> to `'appointment'::invoices_source_type` (confirmed correct after migration,
> but double-check column default after any future schema change).

---

### `expense_categories` (only for developers)

| Column | Type | Nullable | Default | Notes |
|--------|------|----------|---------|-------|
| `id` | uuid | NO | `gen_random_uuid()` | |
| `name` | text | NO | — | |

**Seeded data (13 rows) — confirmed final list:**

```
أخري                    (other)
إيجار                   (rent)
اجهزة طبية              (medical equipment)
انترنت                  (internet)
تسويق و اعلانات         (marketing & ads)
خدمات (نظافه..)         (services — cleaning etc.)
رواتب                   (salaries)
صيانه                   (maintenance)
ضرائب و رسوم            (taxes & fees)
طاقه اخري (غاز)         (other energy — gas)
كهرباء                  (electricity)
مستلزمات                (supplies)
مياه                    (water)
```

> ⚠️ This replaces the previously documented 6-category enum
> (`rent, electricity, supplies, salaries, maintenance, other`).
> The real implementation uses a **lookup table with 13 Arabic-named categories**,
> not a hardcoded enum. Always fetch categories from this table — never hardcode
> the list client-side.

---

### `expenses`

| Column | Type | Nullable | Default | Notes |
|--------|------|----------|---------|-------|
| `id` | uuid | NO | `gen_random_uuid()` | |
| `clinic_id` | uuid | YES | — | pass explicitly |
| `category_id` | uuid | YES | — | FK → expense_categories.id, pass explicitly |
| `amount` | real (float4) | NO | `0` | |
| `notes` | text | YES | — | |
| `created_by` | uuid | YES | — | pass explicitly |
| `created_at` | timestamptz | NO | `now()` | |

---

## Enums

### `invoices_source_type` ✅ (new — created 2025)
```sql
'appointment'
```

---

## Constants

```dart
class SupabaseTables {
  static const invoices           = 'invoices';
  static const expenses           = 'expenses';
  static const expenseCategories  = 'expense_categories';
}

class InvoiceSourceType {
  static const appointment = 'appointment';
}
```

> No `ExpenseCategory` static class — categories must be fetched dynamically
> from `expense_categories` table, not hardcoded as constants.

---

## Schema Issues to Flag

```
1. invoices.clinic_id, patient_id, source_id, created_by
   → all have placeholder random-UUID defaults. MUST be set explicitly
     on every insert. Never rely on DB defaults for these columns.
2. invoices has no status column — status is always derived client-side:
   paid_amount = 0              → معلق   (pending)
   0 < paid_amount < total      → جزئي   (partial)
   paid_amount >= total_amount  → مدفوع  (paid)
```

---

## Related Files
- `business_logic.md` — invoice creation flow, status derivation
- `ui.md` — Invoices, Expenses, Reports screens

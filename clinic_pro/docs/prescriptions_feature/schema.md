# schema.md — Prescriptions Feature

## Tables

### `drugs`

| Column | Type | Nullable | Default | Notes |
|--------|------|----------|---------|-------|
| `id` | uuid | NO | `gen_random_uuid()` | |
| `trade_name` | text | YES | — | e.g. "Augmentin" |
| `generic_name` | text | YES | — | e.g. "Amoxicillin" |
| `category` | text | YES | — | |

Comment: *"بيانات الادوية"*
Shared globally — no `clinic_id` or `owner_id`.

---

### `prescription_templates`

| Column | Type | Nullable | Default | Notes |
|--------|------|----------|---------|-------|
| `id` | uuid | NO | `gen_random_uuid()` | |
| `doctor_id` | uuid | NO | — | personal to doctor |
| `name` | text | NO | — | |
| `user_count` ⚠️ | bigint | NO | `0` | ⚠️ named `user_count`, not `use_count` |

> ⚠️ Column is named **`user_count`** in the actual DB, not `use_count` as previously documented.
> Use the exact name in all queries and models.

Comment: *"يحتوي علي قوالب وصفات طبية (يعتبر زي التشخصيات)"*

---

### `prescription_template_items`

| Column | Type | Nullable | Default | Notes |
|--------|------|----------|---------|-------|
| `id` | uuid | NO | `gen_random_uuid()` | |
| `template_id` | uuid | NO | `gen_random_uuid()` ⚠️ | should be explicit, not relying on default |
| `drug_id` | uuid | NO | `gen_random_uuid()` ⚠️ | same — pass explicitly |
| `frequency` | smallint (int2) | YES | — | |
| `duration` | integer (int4) | YES | — | days |
| `is_prn` | bool | YES | `false` | |
| `timing` | drug_timing (enum) | YES | — | see enum below |

Comment: *"يحتوي علي الادوية التي توجد في كل قالب من قوالب الوصفات الطبية"*

---

### `prescriptions`

| Column | Type | Nullable | Default | Notes |
|--------|------|----------|---------|-------|
| `id` | uuid | NO | `gen_random_uuid()` | |
| `created_at` | timestamptz | NO | `now()` | |
| `clinic_id` | uuid | YES | — | |
| `appointment_id` | uuid | YES | — |
| `doctor_id` | uuid | YES | — | |
| `patient_id` | uuid | YES | `gen_random_uuid()` ⚠️ | should always be set explicitly |
| `diagnosis` | **text** ⚠️ | YES | — | **free text, NOT a FK** |
| `notes` | text | YES | — | |

> ⚠️ **`diagnosis` is plain text**, not a foreign key to `prescription_templates`.
> Confirmed business rule: when a doctor selects a template, the **template's
> name/title is copied as text into this field**. The doctor can also type a
> custom diagnosis freely. There is no DB-level link preserved after creation —
> analytics on "most common diagnosis" must group by the text string itself.
>


Comment: *"الروشات"*

---

### `prescription_items`

| Column | Type | Nullable | Default | Notes |
|--------|------|----------|---------|-------|
| `id` | uuid | NO | `gen_random_uuid()` | |
| `prescription_id` | uuid | NO | `gen_random_uuid()` ⚠️ | pass explicitly |
| `drug_id` | uuid | YES | `gen_random_uuid()` ⚠️ | pass explicitly |
| `frequency` | smallint | YES | — | |
| `duration` | integer | YES | — | |
| `timing` | drug_timing (enum) | YES | — | |
| `is_prn` | bool | YES | `false` | |

Comment: *"يحتوي علي الادوية التي بالروشته"*

---

### `prescription_docs`

| Column | Type | Nullable | Default | Notes |
|--------|------|----------|---------|-------|
| `id` | uuid | NO | `gen_random_uuid()` | |
| `prescription_id` | uuid | YES | `gen_random_uuid()` ⚠️ | pass explicitly |
| `docUrl` ⚠️ | text | YES | — | ⚠️ **camelCase**, not `doc_url` |

> ⚠️ Column is `docUrl` (camelCase) — inconsistent with the rest of the schema's
> snake_case convention. Must be quoted exactly in raw SQL: `"docUrl"`.
> Supabase client (`.select('docUrl')`) handles this fine without quoting issues.
>
> ⚠️ **Not yet used in code.** The `prescription_docs` table exists in the DB and
> in `SupabaseTables` constants, but no feature code reads or writes to it yet.

Comment: *"يحتوي علي مستدات تخص المريض مثل اشعه او تحاليل"*

---

## Enums

### `drug_timing` ⚠️
```sql
'after_meal', 'before_meal', 'throught_meal'
```

> ⚠️ **Typo in enum value**: `throught_meal` should be `through_meal` or `with_meal`.
> This is the literal value in the database — must be used exactly as-is in code
> until a migration fixes it. Do not "correct" it client-side without a DB migration.

### Client-side `DrugTiming` enum (in `prescription_enums.dart`)

> ⚠️ The Dart enum has **4 values** while the DB enum has only **3**.
> The extra value `any_time` was added client-side and **may not exist in the DB enum**.
> Inserts with `timing = 'any_time'` will fail if the DB enum doesn't include it.
> Verify with DB admin before using this value in production inserts.

```dart
enum DrugTiming {
  beforeMeal('before_meal'),
  afterMeal('after_meal'),
  throughMeal('throught_meal'),  // ⚠️ DB typo preserved
  anyTime('any_time'),           // ⚠️ may not exist in DB enum — verify
}
```

---

## Constants

### `SupabaseTables` (in `supabase_constants.dart`)
```dart
class SupabaseTables {
  static const drugs                     = 'drugs';
  static const prescriptionTemplates     = 'prescription_templates';
  static const prescriptionTemplateItems = 'prescription_template_items';
  static const prescriptions             = 'prescriptions';
  static const prescriptionItems         = 'prescription_items';
  static const prescriptionDocs          = 'prescription_docs';
}
```

### `DrugFrequency` (in `prescription_enums.dart`)
```dart
enum DrugFrequency {
  once(1),
  twice(2),
  thrice(3),
  four(4),
  onDemand(0);   // ⚠️ "عند اللزوم" — NOT stored in DB (PRN uses is_prn flag instead)
}
```

> ⚠️ `onDemand(0)` is a UI-only value. The actual PRN behavior is controlled by
> the `is_prn` boolean flag on `prescription_items`, NOT by setting frequency to 0.
> When `is_prn = true`, frequency and duration are set to `null`, not to 0.

### `DrugDuration` (in `prescription_enums.dart`)
```dart
enum DrugDuration {
  threeDays(3),
  sevenDays(7),
  tenDays(10),
  fourteenDays(14),
  thirtyDays(30),
  continuing(0);  // ⚠️ "مستمر" — 0 means indefinite treatment
}
```

### `DrugTiming` (in `prescription_enums.dart`)
```dart
enum DrugTiming {
  beforeMeal('before_meal'),
  afterMeal('after_meal'),
  throughMeal('throught_meal'),  // ⚠️ DB typo
  anyTime('any_time'),           // ⚠️ verify DB enum has this value
}
```

---

## Related Files
- `business_logic.md` — diagnosis-from-template logic, template usage tracking
- `prescription_enums.dart` — Dart enums for frequency, duration, timing
- `supabase_constants.dart` — table name constants

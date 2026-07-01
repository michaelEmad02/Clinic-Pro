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
> ⚠️ No `appointment_id` column exists on prescriptions — previously planned but
> not implemented in the live schema. Confirm if this link is needed before Phase 7.

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

---

## Constants

```dart
class SupabaseTables {
  static const drugs                     = 'drugs';
  static const prescriptionTemplates     = 'prescription_templates';
  static const prescriptionTemplateItems = 'prescription_template_items';
  static const prescriptions             = 'prescriptions';
  static const prescriptionItems         = 'prescription_items';
  static const prescriptionDocs          = 'prescription_docs';
}

class DrugTiming {
  static const afterMeal  = 'after_meal';
  static const beforeMeal = 'before_meal';
  static const throughMeal = 'throught_meal'; // ⚠️ exact DB spelling — typo preserved intentionally
}

class PrescriptionFrequency {
  static const once   = 1;
  static const twice  = 2;
  static const thrice = 3;
  static const four   = 4;
}
```

---

## Related Files
- `business_logic.md` — diagnosis-from-template logic, template usage tracking
- `ui.md` — Prescription, Templates, Drugs screens

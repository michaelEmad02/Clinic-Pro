# schema.md — Subscriptions & Plans Feature

## Tables

### `plans` (only for developers)

| Column | Type | Nullable | Default | Notes |
|--------|------|----------|---------|-------|
| `id` | uuid | NO | `gen_random_uuid()` | |
| `name` | text | NO | — | 'basic' \| 'pro' \| 'enterprise' (no DB enum — plain text) |
| `monthly_price` | real | NO | `0` | |
| `yearly_price` | real | NO | `0` | |
| `lifetime_price` | real | NO | `0` | |
| `description` | text | YES | — | |
| `created_at` | timestamptz | NO | `now()` | |
| `monthly_discount` | real | NO | `0` | |
| `yearly_discount` | real | NO | `0` | |
| `lifetime_discount` | real | NO | `0` | |
| `currency` | text | NO | `'USD $'` ⚠️ | default includes the $ symbol, not just code |

> ⚠️ `currency` default is the literal string `'USD $'` — not an ISO code like `'USD'`.
> If you need ISO codes for any payment integration, this will need parsing
> or a schema change. Confirm before building Stripe/Paymob integration.

**Live data (confirmed 3 plans):**

| name | monthly | yearly | lifetime | monthly_disc | yearly_disc | lifetime_disc |
|------|---------|--------|----------|--------------|--------------|----------------|
| basic | $7 | $70 | $155 | — | 20% | 50% |
| pro | $11 | $110 | $250 | — | 30% | 30% |
| enterprise | $17 | $170 | $350 | — | 30% | 40% |

---

### `plans_features` ⚠️ (table name is `plans_features`, not `plan_features`)

| Column | Type | Nullable | Default | Notes |
|--------|------|----------|---------|-------|
| `id` | uuid | NO | `gen_random_uuid()` | |
| `plan_id` | uuid | NO | — | FK → plans.id |
| `max_clinics` | smallint (int2) | NO | — | |
| `max_staff` | smallint (int2) | NO | — | |
| `max_patients` | integer (int4) | NO | — | |
| `features` ⚠️ | jsonb | YES | — | column is `features`, not `feature` |    


//Example of features jsonb:
 {
  "print_reports": 
    {
      "arb_title": "طباعه و استخراج التقارير",
      "eng_title" : "Print and Export Reports",
      "value": false
    }
  ,
  "clinics_reports": {
     "arb_title": "تقارير العيادات",
      "eng_title" : "Clinics Reports",
      "value": false
  },
    "appointments_reports": {
      "arb_title": "تقارير المواعيد",
      "eng_title" : "Appointments Reports",
      "value": false
  },
    "doctors_performance_reports": {
      "arb_title": "تقارير اداء الاطباء",
      "eng_title" : "Doctors Performance Reports",
      "value": false
  },
      "prescriptions_reports": {
      "arb_title": "تقارير الروشتات و الادوية",
      "eng_title" : "Prescription Reports",
      "value": false
  }
}
> ⚠️ Table is `plans_features` (plural "plans") and column is `features` (plural).
> Previous docs used `plan_features` / singular `feature` — both wrong.

---

### `subscriptions`

| Column | Type | Nullable | Default | Notes |
|--------|------|----------|---------|-------|
| `id` | uuid | NO | `gen_random_uuid()` | |
| `owner_id` | uuid | YES | — | pass explicitly |
| `plan_id` | uuid | YES | — | pass explicitly |
| `subscription_type` | subscription_types (enum) | NO | — | see enum below |
| `status` | subscription_status (enum) | NO | — | see enum below |
| `started_at` ⚠️ | timestamptz | YES | `now()` | ⚠️ named `started_at`, not `start_at` |
| `end_at` | timestamptz | YES | — | |
| `created_by` | uuid | YES | — | pass explicitly |
| `created_at` | timestamptz | NO | `now()` | |

> ⚠️ Column is **`started_at`** (with "ed"), not `start_at` as previously documented.

---

## Enums

### `subscription_types` ⚠️
```sql
'trail', 'monthly', 'yearly', 'lifetime'
```

> ⚠️ **Typo in enum value**: `'trail'` should be `'trial'`. This is the literal
> value in the database — must be used exactly as-is (`'trail'`) in all queries
> and Dart constants until a migration corrects it. Also note `'lifetime'` is
> a 4th option not previously documented (only trial/monthly/yearly were planned).

### `subscription_status`
```sql
'pending', 'active', 'expired', 'cancelled'
```

---

## Constants

```dart
class SupabaseTables {
  static const plans          = 'plans';
  static const plansFeatures  = 'plans_features';  // ⚠️ plural "plans"
  static const subscriptions  = 'subscriptions';
}

class SubscriptionType {
  static const trial    = 'trail';    // ⚠️ exact DB spelling — typo preserved
  static const monthly  = 'monthly';
  static const yearly   = 'yearly';
  static const lifetime = 'lifetime'; // not previously documented
}

class SubscriptionStatus {
  static const pending   = 'pending';
  static const active    = 'active';
  static const expired   = 'expired';
  static const cancelled = 'cancelled';
}

class PlanName {
  static const basic      = 'basic';
  static const pro        = 'pro';
  static const enterprise = 'enterprise';
}
```

---

## Related Files
- `business_logic.md` — plan limit enforcement, trial expiry
- `ui.md` — Subscription screen

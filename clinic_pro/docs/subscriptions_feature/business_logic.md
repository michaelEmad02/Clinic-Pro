# business_logic.md — Subscriptions & Plans Feature

---

## Plan Limits Enforcement

```dart
// Check before adding doctor/secretary
final features = await getPlanFeatures(subscription.planId);
final currentStaff = await countStaff(clinicId);
if (currentStaff >= features.maxStaff) {
  return Left(PlanLimitFailure('staff'));
}

// Check before adding clinic
final currentClinics = await countClinics(ownerId);
if (currentClinics >= features.maxClinics) {
  return Left(PlanLimitFailure('clinics'));
}

// Check before adding patient
final currentPatients = await countPatients(ownerId);
if (currentPatients >= features.maxPatients) {
  return Left(PlanLimitFailure('patients'));
}
```

> Note: max_clinics/max_staff/max_patients have NO "-1 = unlimited" convention
> confirmed in the live schema (smallint/integer, no special sentinel documented).
> Confirm with backend whether unlimited plans use a very large number or a
> separate boolean flag before implementing enforcement logic.

---

## Subscription Status Flow

```
pending → active   (after payment confirmed)
active  → expired  (end_at < today)
active  → cancelled (owner cancels)
expired → active   (owner renews)
```

---

## Subscription Type — Including Lifetime

```
4 types now confirmed: trial (DB: 'trail'), monthly, yearly, lifetime

Lifetime subscriptions:
  - one-time payment (lifetime_price)
  - end_at should likely be null or far future date — confirm convention
    with backend before implementing renewal/expiry checks
```

---

## Trial Expiry

```
status = 'pending' or DB enum 'trail' AND end_at < today:
  → Dashboard shows "Trial expired" banner
  → Block add/edit actions (read-only mode)
  → Show upgrade CTA prominently
```

> ⚠️ When checking trial status in code, the enum value to compare against
> is the literal string `'trail'` (typo), not `'trial'`.

---

## Pricing Display

```dart
// Discounted price calculation
final displayPrice = monthlyPrice * (1 - monthlyDiscount / 100);

// Currency display
// plans.currency default is 'USD $' (full string with symbol)
// Display as-is, do not assume ISO code parsing without confirming format
```

---

## Plan Comparison (live data — confirmed)

| | Basic | Pro | Enterprise |
|--|-------|-----|------------|
| Monthly | $7 | $11 | $17 |
| Yearly | $70 (20% off) | $110 (30% off) | $170 (30% off) |
| Lifetime | $155 (50% off) | $250 (30% off) | $350 (40% off) |

> Source of truth: query `plans` + `plans_features` tables directly —
> do not hardcode these values in the app, fetch dynamically.

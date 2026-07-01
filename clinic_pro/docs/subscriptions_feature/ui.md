# ui.md — Subscriptions & Plans Feature

---

## Screens

| Screen | Route | Roles |
|--------|-------|-----------|
| Plan Selection (onboarding) | `/onboarding/plan` | Owner |
| Subscription | `/settings/subscription` | Owner |

---

## Plan Selection Screen (Onboarding)

```
3 plan cards fetched from `plans` + `plans_features` tables:
  Basic:      $7/mo  — fetch max_clinics/max_staff/max_patients dynamically
  Pro:        $11/mo — marked "الأكثر طلباً"
  Enterprise: $17/mo

Toggle: شهري | سنوي | مدى الحياة
  → switches displayed price using monthly_price/yearly_price/lifetime_price
  → shows discount badge using monthly_discount/yearly_discount/lifetime_discount

CTA: "ابدأ التجربة المجانية"
  → creates subscription with subscription_type = 'trail' (DB literal spelling)
```

---

## Subscription Screen (Settings)

```
Current plan card — fetched live from subscriptions + plans join
Countdown to end_at (if trial or active with expiry)
Usage progress bars: clinics / staff / patients (current vs max from plans_features)
Upgrade CTA button
Billing history (future — not in current scope)
```

---

## Design Tokens
See `architecture.md` → Design System section.

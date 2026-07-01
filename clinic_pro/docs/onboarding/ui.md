# ui.md — Onboarding (Composite Screen)

> This is a **composite feature** — it has no dedicated DB tables.
> It orchestrates data from multiple features in sequence.
> No `schema.md` or `business_logic.md` exists here — refer to the source
> features listed below for all data rules.

---

## Source Features Used

| Step | Data From | Tables Touched |
|------|-----------|-----------------|
| Account creation | `auth/` | `Owners` |
| Plan selection | `subscriptions/` | `plans`, `plans_features`, `subscriptions` |
| Clinic creation | `clinics_staff/` | `clinics`, `users`, `clinic_staff` |
| Staff invitation | `clinics_staff/` | `invitations` ⚠️ table not yet in DB |

---

## Screens

| Screen | Route | Roles |
|--------|-------|-----------|
| Plan Selection | `/onboarding/plan` | Owner |
| Create Clinic | `/onboarding/clinic` | Owner |
| Invite Staff | `/onboarding/invite` | Owner |

> Detailed UI specs for these 3 screens are documented in
> `subscriptions/ui.md` (Plan Selection) and `clinics_staff/ui.md`
> (Create Clinic, Invite Staff) — duplicated here only as a sequence map.

---

## Flow Sequence

```
① Create Account (auth/ui.md)
        ↓
② Plan Selection (subscriptions/ui.md)
   → creates subscription record, subscription_type = 'trail' (DB enum spelling)
        ↓
③ Create Clinic (clinics_staff/ui.md)
   → creates clinic record
   → embedded "هل أنت طبيب؟" toggle
     → if yes: creates users + clinic_staff row (role: doctor)
        ↓
④ Invite Staff (clinics_staff/ui.md) — optional, skippable
   → creates invitation records
   ⚠️ requires `invitations` table to exist first — see schema_audit.md
        ↓
⑤ Redirect to Owner Dashboard (composite/dashboard/ui.md)
```

---

## State Management Note

```
A single OnboardingCubit/Bloc orchestrates all 3 steps as one flow,
but each step's data submission calls UseCases from the SOURCE feature
(e.g. CreateClinicUseCase lives in clinics_staff/domain, not in an
"onboarding" domain layer — there is no onboarding feature folder under
lib/features/, only a presentation-level flow).
```

```
lib/features/onboarding/
├── presentation/
│   ├── manager/
│   │   ├── onboarding_cubit.dart   ← orchestrates step navigation only
│   │   └── onboarding_state.dart
│   └── ui/
│       ├── plan_screen.dart
│       ├── create_clinic_screen.dart
│       └── invite_staff_screen.dart
│
# No data/ or domain/ folders — onboarding has no own entities/repositories.
# It calls UseCases from: subscriptions/domain, clinics_staff/domain
```

---

## Design Tokens
See `architecture.md` → Design System section.

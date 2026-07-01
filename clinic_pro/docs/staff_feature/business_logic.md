# business_logic.md — Clinics & Staff Feature

---

## Permission Matrix (current — doctor/secretary only)

| Action | Owner | Doctor | Secretary |
|--------|-------|--------|-----------|
| Manage clinics | ✅ | ❌ | ❌ |
| Invite staff | ✅ | ❌ | ❌ |
| View staff list | ✅ | ❌ | ❌ |
| Manage queue rules | ✅ (if doctor) | ✅ | ❌ |
| Manage appointment types | ✅ | ✅ (own) | ❌ |

> Nurse/Accountant rows removed — not in current `staff_role` enum.
> See `upcoming_features.md` for planned permissions once added.

---

## Invitation Flow

```
1. Owner fills: email + name + role (doctor | secretary only)
2. System creates invitation record (status: pending, expires in 7 days)
3. Supabase Auth sends invitation email with token link
4. Staff clicks link → Accept Invitation screen
5. Staff registers via Google / Apple
6. System:
   a. Creates record in `users` (id = auth.uid())
   b. Creates record in `clinic_staff` (user_id, clinic_id, role)
      ⚠️ MUST explicitly set clinic_id — do not rely on column default
   c. Updates invitation status → 'accepted'
7. Staff enters role-specific dashboard
```

### Edge Cases
```
Token expired (> 7 days) → "Invitation expired" screen
Token already accepted   → "Already registered" → redirect to login
Same email invited twice to same clinic → blocked at owner UI level
```

---

## Multi-Clinic Staff

```
Same user_id can appear in multiple clinic_staff rows (different clinic_id).
Role can differ per clinic (e.g. doctor in Clinic A, secretary in Clinic B).
```

---

## Appointment Types — Doctor-Specific Pricing

```
appointment_types.doctor_id is REQUIRED (NOT NULL)
appointment_types.clinic_id is OPTIONAL (nullable)

This means: a doctor's visit type pricing is fundamentally tied to the doctor,
not strictly to a clinic. Verify this is intentional before building the
"Add Visit Type" flow — currently a doctor could theoretically have a visit
type with no clinic_id set.

Recommendation: Always pass clinic_id explicitly when creating appointment_types
even though the DB allows null, to avoid orphaned types.
```

---

## Validations

```
clinic name:     required
invitation role:  must be 'doctor' or 'secretary' (enum constraint)
```

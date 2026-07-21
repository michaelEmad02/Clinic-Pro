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

---

## Secretary — Doctor Assignment

### Relationship Rules
```
- One secretary can serve multiple doctors (across clinics or different days)
- One doctor can have multiple secretaries
- A secretary serves only ONE doctor at a time (never concurrent)
- The link is stored in doctor_secretary_schedule (fixed pairing)
- Time-based resolution uses doctor_schedules at runtime
```

### Auto-Selection Logic (on app launch)

```dart
// 1. Get current clinic (from SharedPreferences/Hive cache)
final currentClinicId = await cache.getCurrentClinicId()
  ?? staffClinics.first.id;

// 2. Find active doctor for current time
final today = DateTime.now().weekday % 7; // 0=Sun...6=Sat
final now   = TimeOfDay.now();

final schedule = await supabase
  .from('doctor_secretary_schedule')
  .select('doctor_id, users!doctor_id(name), doctor_schedules!inner(*)')
  .eq('secretary_id', currentUserId)
  .eq('clinic_id', currentClinicId)
  .eq('is_active', true)
  .eq('doctor_schedules.day_of_week', today)
  .lte('doctor_schedules.start_time', now.format(context))
  .gte('doctor_schedules.end_time', now.format(context))
  .eq('doctor_schedules.is_active', true)
  .maybeSingle();

// 3. Fallback: first assigned doctor (no time filter)
if (schedule == null) {
  final fallback = await supabase
    .from('doctor_secretary_schedule')
    .select('doctor_id, users!doctor_id(name)')
    .eq('secretary_id', currentUserId)
    .eq('clinic_id', currentClinicId)
    .eq('is_active', true)
    .limit(1)
    .maybeSingle();
  currentDoctorId = fallback?['doctor_id'];
}

// 4. Cache the result locally
await cache.setCurrentDoctorId(currentDoctorId);
await cache.setCurrentClinicId(currentClinicId);
```

### When Secretary Changes Clinic (from Settings)

```
① Secretary selects new clinic from Clinic Picker
② System re-runs auto-selection logic for the new clinic
③ Loads list of assigned doctors for new clinic
   from doctor_secretary_schedule WHERE clinic_id = newClinic
④ Auto-selects doctor based on current time + doctor_schedules
⑤ Caches: currentClinicId + currentDoctorId
⑥ Reloads Dashboard with new context
```

### When Secretary Manually Changes Doctor (from Settings)

```
① Secretary selects doctor from dropdown
   (list = doctor_secretary_schedule WHERE clinic_id = currentClinic)
② Updates cache: currentDoctorId = selected
③ Reloads Dashboard
④ Does NOT update DB — manual override is local only (SharedPreferences/Hive)
```

### Cache Strategy

```
Phase 1 (current): SharedPreferences
  → currentClinicId (String)
  → currentDoctorId (String?)

Phase 2 (future): Hive
  → same keys, typed boxes
  → add last_sync_at for cache invalidation

Cache is cleared on:
  → logout
  → clinic deletion
  → secretary removed from doctor_secretary_schedule
```

### Impact on Secretary Dashboard

```
Secretary Dashboard queries are filtered by:
  appointments WHERE clinic_id = currentClinicId
                AND doctor_id  = currentDoctorId  ← NEW filter

If currentDoctorId is null (no assignment found):
  → show ALL appointments for the clinic (no doctor filter)
  → show info banner: "لم يتم تحديد طبيب — عرض كل المواعيد"
```


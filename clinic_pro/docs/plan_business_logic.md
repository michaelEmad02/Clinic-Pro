# 🧠 plan_business_logic.md — Business Logic Plan

---

## 1. Authentication & Session

### Rules
- Only **Owners** can self-register (Google / Apple / Magic Link)
- **Staff** can ONLY join via invitation email — no self-registration
- After login, the app checks `auth.uid()` against `owners` table first, then `users` table
- If found in neither → show error "Account not found"

### Session Flow
```
auth.uid() exists?
  ├── found in owners → UserType.owner  → Owner Dashboard
  ├── found in users  → check is_active
  │     ├── true  → check clinic_staff → get role → Staff Dashboard
  │     └── false → show "Account suspended" screen
  └── not found → logout + show Login
```

### Multi-clinic Staff
```
user found in clinic_staff with multiple clinics:
  → show Clinic Picker Bottom Sheet
  → user selects active clinic
  → session stores: currentClinicId + currentRole
```

---

## 2. Roles & Permissions

### Permission Matrix

| Action | Owner | Doctor | Secretary | 
|--------|-------|--------|-----------|
| Manage clinics | ✅ | ❌ | ❌ |
| Invite staff | ✅ | ❌ | ❌ |
| Manage subscription | ✅ | ❌ | ❌ |
| View reports | ✅ | partial | ❌ |
| Add/edit patients | ✅ | ✅ | ✅ |
| View appointments | ✅ | ✅ | ✅ |  
| Add appointments | ✅ | ✅ | ✅ |   
| Confirm examination | ✅ | ✅ | ❌ |  
| Write prescriptions | ✅ | ✅ | ❌ | 
| View prescriptions | ✅ | ✅ | ✅ |  
| Create invoices | ✅ | ✅ | ✅ | 
| View invoices | ✅ | ✅ | ✅ |  
| Add expenses | ✅ | ✅ | ✅ |  
| Manage drugs/templates | ✅ | ✅ | ✅ |  

### Owner as Doctor
```
If owner is also a doctor in the clinic:
  - Appears in clinic_staff with role = 'doctor'
  - Has BOTH owner permissions + doctor permissions
  - Determined by: owners.id == auth.uid()
```

---

## 3. Invitation System

### Flow
```
1. Owner fills: email + name + role
2. System creates invitation record (status: 'pending', expires in 7 days)
3. Supabase Auth sends invitation email with unique token link
4. Staff clicks link → Accept Invitation screen
5. Staff registers via Google / Apple
6. System:
   a. Creates record in users table (id = auth.uid())
   b. Creates record in clinic_staff (user_id, clinic_id, role)
   c. Updates invitation status → 'accepted'
7. Staff enters their role-specific dashboard
```

### Edge Cases
```
Token expired (> 7 days):
  → Show "Invitation expired" screen
  → Suggest contacting the clinic owner

Token already accepted:
  → Show "Already registered" → redirect to login

Same email invited twice to same clinic:
  → Block at owner level: "This email is already invited"
```

---

## 4. Appointments


### Status Transitions
```
scheduled   → confirmed   (secretary confirms patient arrived — sets arrived_at)
confirmed   → in_progress (doctor calls patient — sets called_at)
in_progress → done        (doctor saves prescription/examination)
any         → cancelled   (owner or secretary — except 'done')
```

### Business Rules
```
- appointment.price    = expected_fee (copied from appointment_type at booking)
- arrived_at           = set when secretary confirms arrival (enters queue)
- called_at            = set when doctor calls patient (in_progress)
- is_urgent            = secretary or doctor can toggle at any time
- Doctor can only confirm examination for their own appointments
- Secretary can book for any doctor in the clinic
- Cancellation allowed at any status except 'done'
- Cancelled appointments remain visible in history
- No separate queue table — queue is derived from appointments
```

### Waiting Queue Logic
```
Queue = appointments WHERE:
  date = today
  AND arrived_at IS NOT NULL
  AND status != 'cancelled'
  AND doctor_id = current doctor

Sorting (computed in Flutter — QueueSorter.sort()):
  ① Fixed:   status IN ('done','in_progress') → stay in place
  ② Urgent:  is_urgent = true → always first among waiting
  ③ Waiting: apply doctor_queue_rules pattern starting from fixed.length

Pattern application:
  - pattern = ['normal','normal','normal','urgent']
  - position = (startIndex + waitingIndex) % cycle_length
  - If a patient arrives late and breaks the pattern:
    → already done/in_progress patients stay fixed
    → remaining waiting patients re-apply pattern from that point
    → no DB update — recomputed every time queue is displayed

Realtime:
  - Supabase Realtime on appointments table
  - Any change (arrived_at, called_at, is_urgent, status) triggers re-sort
  - Re-sort is instant in Flutter — no extra DB call needed
```

### Doctor Queue Rules
```
Stored in: doctor_queue_rules table
  - One rule per doctor per clinic
  - slots: jsonb array e.g. ["normal","normal","normal","urgent"]
  - cycle_length: length of slots array

The doctor configures this once in Settings.
If no rule exists → default sort by arrived_at ASC.
```

---

## 5. Prescription (Examination)

### Access Rule
```
Prescription screen opens ONLY when:
  appointment.status = 'confirmed' OR 'in_progress'
  AND current user = appointment.doctor_id OR is owner
```

### Workflow
```
1. Doctor opens Prescription screen (from "Confirm Examination")
2. appointment.status → 'in_progress'
3. Doctor selects diagnosis template(s) [multi-select]
   → selected template drugs auto-added to prescription items
4. Doctor adjusts each drug: frequency + duration + timing + is_prn
5. Doctor adds extra drugs manually via search
6. Doctor adds notes
7. Doctor saves:
   a. Creates prescription record
   b. Creates prescription_items records
   c. Creates prescription_docs if files attached
   d. appointment.status → 'done'
   e. prescription_templates.use_count++ for each selected template
8. Options: Print PDF or Share via WhatsApp
```

### PRN Rule (is_prn = true)
```
- frequency chips disabled and hidden
- duration chips disabled and hidden
- timing chips remain active
- Label shown: "عند اللزوم (PRN)"
```

### Multi-Template Selection
```
Templates selected: [Template A, Template B]
Result: drugs from A + drugs from B all added
Duplicate drugs: keep both (doctor decides which to remove)
```

---

## 6. Invoice System

### Creation Flow
```
Secretary creates invoice manually:
  1. Select patient (autocomplete search)
  2. Select appointment (filtered to selected patient, status: done)
     → appointment.price auto-fills as hint only (label: "السعر المتوقع")
  3. Enter actual total_amount
  4. Enter paid_amount (can be partial)
  5. Select payment_method (optional)
  6. Save

Also accessible via:
  Appointments screen → (···) → "تسجيل فاتورة"
  → pre-fills patient + appointment automatically
```

### Invoice Status (derived — not stored in DB)
```dart
String get status {
  if (paidAmount <= 0)              return 'pending';   // معلق
  if (paidAmount < totalAmount)     return 'partial';   // جزئي
  return 'paid';                                        // مدفوع
}
```

### Business Rules
```
- One appointment can have multiple invoice records (partial payments)
- invoice.source_type = 'appointment' (extensible for future)
- Secretary and Owner can create/edit invoices
- Doctor can VIEW invoices only
- Invoices cannot be deleted — only marked via paid_amount
```

---

## 7. Expenses

### Rules
```
- Expenses are per clinic (clinic_id)
- Owner and Secretary (accountant role) can add/edit/delete
- Doctors cannot access expenses
- Category is from `expense_categories` table (seeded at DB init)
- `category_id` FK → expense_categories.id
- No soft-delete — expenses are hard-deleted
```

---

## 8. Patient Data

### Scoping Rule
```
patients.owner_id → shared across all clinics of same owner

Example:
  Owner has Clinic A and Clinic B
  Patient registered in Clinic A
  → Patient is visible in Clinic B
  → Patient's visit history is filtered per clinic
```

### Visit History
```
Patient Details → Visits tab:
  Shows all appointments across all owner's clinics
  Each visit shows: date + clinic name + doctor + diagnosis

Patient Details → Prescriptions tab:
  Shows all prescriptions across all owner's clinics
```

---

## 9. Drug Templates

### Scoping Rule
```
prescription_templates.doctor_id → personal to each doctor
  - Doctor A cannot see Doctor B's templates
  - Owner (if also doctor) has their own templates
  - Templates travel with the doctor across clinics
```

### use_count Increment
```
On prescription save:
  For each selected template:
    UPDATE prescription_templates SET use_count = use_count + 1
    WHERE id = [template_id]
```

---

## 10. Reports

### Available Reports (Owner only)
```
1. Revenue Summary:
   SUM(invoices.paid_amount) grouped by day/week/month
   filtered by clinic_id and date range

2. Expenses Summary:
   SUM(expenses.amount) grouped by category
   filtered by clinic_id and date range

3. Net Profit:
   Revenue - Expenses for selected period

4. Patient Count:
   COUNT(appointments) WHERE status = 'done'
   grouped by doctor

5. Doctor Performance:
   Per doctor: appointment count + revenue generated

6. Most Requested Visit Types:
   COUNT(appointments) grouped by type_id
```

---

## 11. Realtime Behavior

### Subscribed channels per session
```dart
// Appointments channel — all staff in active clinic
supabase
  .channel('appointments:$clinicId')
  .onPostgresChanges(
    event: PostgresChangeEvent.all,
    table: 'appointments',
    filter: PostgresChangeFilter(
      type: PostgresChangeFilterType.eq,
      column: 'clinic_id',
      value: clinicId,
    ),
    callback: (_) => refreshAppointments(),
  )
  .subscribe();
```

### On Realtime Event
```
Receive event → do NOT use payload data directly
→ re-fetch fresh data from Supabase (or mock)
→ update state via Cubit/Bloc emit
```

---

## 12. Subscription & Plan Limits

### Plan Enforcement
```
Starter:    max 1 doctor  | max 500 patients | max 1 clinic
Growth:     max 5 doctors | unlimited patients | max 3 clinics
Enterprise: unlimited
```

### Enforcement Points
```
Adding a new doctor via invitation:
  → Check current doctor count in clinic_staff
  → If at limit → show upgrade prompt

Adding a new clinic:
  → Check current clinic count for owner
  → If at limit → show upgrade prompt

Adding patient:
  → Check patient count for owner
  → If at limit → show upgrade prompt
```

### Trial Expiry
```
status = 'trial' AND trial_ends < now():
  → Show "Trial expired" banner on dashboard
  → Block access to core features
  → Show upgrade CTA
```

---

## 13. Validations

### Patient Form
```
name:               required, min 2 chars
phone:              optional, valid format if provided
date_of_birth:      optional, must be in the past
gender:             optional, enum check
blood_type:         optional, enum check
```

### Appointment Form
```
patient_id:   required
doctor_id:    required
type_id:      required
date:         required, cannot be in the past (warn, not block for edit)
time:         required
```

### Prescription
```
diagnosis:    required (at least 1 template selected)
drugs:        at least 1 drug must be added
  per drug:
    frequency: required (unless is_prn = true)
    duration:  required (unless is_prn = true)
    timing:    required
```

### Invoice
```
patient_id:    required
source_id:     required (appointment)
total_amount:  required, > 0
paid_amount:   required, >= 0, <= total_amount
```

### Expense
```
category:  required
amount:    required, > 0
```

---

## 14. Edge Cases

```
Doctor tries to open Prescription for another doctor's appointment
→ Show "Access denied" snackbar

Invitation token expired
→ Show clear message + "Contact your clinic admin"

Staff tries to access a screen outside their role
→ GoRouter redirect blocks navigation
→ Show "No permission" screen

Realtime disconnects
→ Show "Live updates paused" subtle banner
→ Auto-reconnect on network restore

Offline mode
→ Show "No internet connection" banner
→ Disable all actions that require network
→ Read-only from last cached data (if implemented)

Owner deletes a clinic
→ All staff in that clinic → is_active = false
→ Their login redirects to "Clinic unavailable" screen

Owner suspends a staff member (is_active = false)
→ Next login attempt shows "Account suspended" screen
→ Active sessions: kicked out via Supabase Auth revoke
```

---

## 11. Plans & Subscriptions

### Plan Structure
```
plans table:
  - name: 'basic' | 'pro' | 'enterprise'
  - monthly_price / yearly_price / lifetime_price
  - monthly_discount / yearly_discount / lifetime_discount
  - currency: 'USD' (default)

plan_features table (per plan):
  - max_clinics:  -1 = unlimited
  - max_staff:    -1 = unlimited
  - max_patients: -1 = unlimited
  - feature: jsonb  { realtime, reports, pdf_export, multi_branch, ... }
```

### Subscription Types
```
trial    → free period, limited features
monthly  → billed every month
yearly   → billed annually (discount applied)
```

### Subscription Status Flow
```
pending → active (after payment confirmed)
active  → expired (end_at < today)
active  → cancelled (owner cancels)
expired → active (owner renews)
```

### Plan Limits Enforcement
```dart
// Check before adding doctor
final features = await getPlanFeatures(subscription.planId);
final currentDoctors = await countDoctors(clinicId);
if (features.maxStaff != -1 && currentDoctors >= features.maxStaff) {
  return Left(PlanLimitFailure('staff'));
}

// Check before adding clinic
final currentClinics = await countClinics(ownerId);
if (features.maxClinics != -1 && currentClinics >= features.maxClinics) {
  return Left(PlanLimitFailure('clinics'));
}

// Check before adding patient
final currentPatients = await countPatients(ownerId);
if (features.maxPatients != -1 && currentPatients >= features.maxPatients) {
  return Left(PlanLimitFailure('patients'));
}
```

### Trial Expiry
```
subscription.status = 'trial' AND end_at < today:
  → Show "Trial expired" banner on dashboard
  → Block add/edit actions
  → Allow read-only access
  → Show upgrade CTA prominently
```

### Pricing Display
```dart
// Show discounted price
final displayPrice = monthlyPrice * (1 - monthlyDiscount / 100);

// Yearly savings
final yearlySavings = (monthlyPrice * 12) - yearlyPrice;
```

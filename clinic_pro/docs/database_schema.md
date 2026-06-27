# 🗄️ database_schema.md — Supabase Database Schema

---

## Overview

- **Database:** PostgreSQL via Supabase
- **Multi-tenancy:** `clinic_id` (staff/clinic data) | `owner_id` (patient data)
- **Security:** Row Level Security (RLS) on all tables
- **Total Tables:** 18

---

## Tables Reference

---

### 👤 `owners`

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | uuid | PK, references auth.users(id) | = auth.uid() |
| `name` | text | NOT NULL | |
| `phone` | text | | |
| `country` | text | | |
| `address` | text | | |
| `created_at` | timestamptz | DEFAULT now() | |

---

### 👥 `users` _(Clinic Staff)_

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | uuid | PK, references auth.users(id) | = auth.uid() |
| `owner_id` | uuid | FK → owners.id NOT NULL | The owner who invited them |
| `name` | text | NOT NULL | |
| `address` | text | | |
| `phone` | text | | |
| `specialty` | text | | For doctors only |
| `image_url` | text | | Supabase Storage URL |
| `is_active` | bool | DEFAULT true | |
| `created_at` | timestamptz | DEFAULT now() | |

---

### 🏥 `clinics`

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | uuid | PK | |
| `owner_id` | uuid | FK → owners.id NOT NULL | |
| `name` | text | NOT NULL | |
| `address` | text | | |
| `phone1` | text | | Primary phone |
| `phone2` | text | | Secondary phone |
| `logo_url` | text | | Supabase Storage URL |
| `is_active` | bool | DEFAULT true | |

---

### 🔗 `clinic_staff`

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | uuid | PK | |
| `clinic_id` | uuid | FK → clinics.id NOT NULL | |
| `user_id` | uuid | FK → users.id NOT NULL | |
| `role` | text | CHECK IN ('doctor','secretary','nurse','accountant') | staff_role enum |
| `is_active` | bool | DEFAULT true | |
| `joined_at` | timestamptz | DEFAULT now() | |

> **Unique constraint:** `(clinic_id, user_id)`

---

### 📨 `invitations`

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | uuid | PK | |
| `clinic_id` | uuid | FK → clinics.id | |
| `owner_id` | uuid | FK → owners.id | |
| `email` | text | NOT NULL | |
| `name` | text | | |
| `role` | text | NOT NULL | |
| `token` | text | UNIQUE | Auto-generated |
| `status` | text | CHECK IN ('pending','accepted','expired') DEFAULT 'pending' | |
| `expires_at` | timestamptz | DEFAULT now() + interval '7 days' | |
| `created_at` | timestamptz | DEFAULT now() | |

---

### 🧑‍⚕️ `patients`
Linked to `owner_id` — shared across all clinics of same owner.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | uuid | PK | |
| `owner_id` | uuid | FK → owners.id NOT NULL | Shared across owner's clinics |
| `name` | text | NOT NULL | |
| `phone` | text | | |
| `address` | text | | |
| `date_of_birth` | date | | |
| `gender` | text | CHECK IN ('male','female') | |
| `blood_type` | text | CHECK IN ('A+','A-','B+','B-','AB+','AB-','O+','O-') | |
| `allergies` | text | | Free text |
| `chronic_conditions` | text | | Free text |

---

### 💊 `drugs`
Shared globally — no `clinic_id` or `owner_id`.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | uuid | PK | |
| `trade_name` | text | NOT NULL | e.g. "Augmentin" |
| `generic_name` | text | NOT NULL | e.g. "Amoxicillin" |
| `category` | text | | e.g. "antibiotic" |

---

### 📋 `prescription_templates`
Personal to each doctor — no `clinic_id`.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | uuid | PK | |
| `doctor_id` | uuid | FK → users.id NOT NULL | Personal to this doctor |
| `name` | text | NOT NULL | e.g. "Sore Throat - Simple" |
| `use_count` | int | DEFAULT 0 | |

---

### 💊 `prescription_template_items`

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | uuid | PK | |
| `template_id` | uuid | FK → prescription_templates.id ON DELETE CASCADE | |
| `drug_id` | uuid | FK → drugs.id | |
| `frequency` | int | | 1=once / 2=twice / 3=three times |
| `duration` | int | | Days |
| `is_prn` | bool | DEFAULT false | PRN = "as needed" — overrides frequency/duration |
| `timing` | text | | "after_meal" / "before_meal" / "with_meal" |

---

### 🗓️ `appointment_types`
Per doctor within a clinic — pricing varies per doctor.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | uuid | PK | |
| `clinic_id` | uuid | FK → clinics.id | |
| `doctor_id` | uuid | FK → users.id | Price is per doctor |
| `name` | text | NOT NULL | "Regular Visit" / "Urgent" |
| `price` | decimal | NOT NULL | Expected fee |

---

### 🔀 `doctor_queue_rules`
Defines the repeating pattern the doctor uses for ordering the waiting queue.
One rule per doctor per clinic.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | uuid | PK | |
| `doctor_id` | uuid | FK → users.id NOT NULL | |
| `clinic_id` | uuid | FK → clinics.id NOT NULL | |
| `slots` | jsonb | NOT NULL | Pattern array e.g. `["normal","normal","normal","urgent"]` |
| `cycle_length` | int | NOT NULL | Length of pattern (= slots array length) |
| `is_active` | bool | DEFAULT true | |

> **Unique constraint:** `(doctor_id, clinic_id)` — one rule per doctor per clinic.
>
> **`slots` jsonb example:**
> ```json
> ["normal", "normal", "normal", "urgent"]
> ```
> Values map to `appointment_types.name` categories.
>
> **How it works:**
> - Queue is built from `appointments` WHERE `arrived_at IS NOT NULL` AND `date = today`
> - Already `done` / `in_progress` entries stay fixed in place
> - Remaining `waiting` entries are sorted by applying the pattern starting from `done.length` index
> - `is_urgent = true` entries always go first, before the pattern
> - Pattern position = `(startIndex + waitingIndex) % cycle_length`
> - Sorting is computed in Flutter — NOT stored back to DB

---

### 📅 `appointments`

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | uuid | PK | |
| `clinic_id` | uuid | FK → clinics.id | |
| `patient_id` | uuid | FK → patients.id | |
| `doctor_id` | uuid | FK → users.id | |
| `type_id` | uuid | FK → appointment_types.id | |
| `date` | date | NOT NULL | |
| `time` | time | NOT NULL | |
| `status` | text | CHECK IN ('scheduled','confirmed','in_progress','done','cancelled') | |
| `price` | decimal | | **expected_fee** — copied from appointment_type at booking |
| `notes` | text | | |
| `is_urgent` | bool | DEFAULT false | Urgent case — overrides queue pattern priority |
| `arrived_at` | timestamptz | | Set when secretary confirms patient arrival |
| `called_at` | timestamptz | | Set when doctor calls the patient |
| `created_by` | uuid | FK → users.id | |
| `created_at` | timestamptz | DEFAULT now() | |

> `appointments.price` = `expected_fee` only. Actual payment tracked in `invoices`.
> Queue is derived from `appointments` — no separate queue table.
> Only appointments with `arrived_at IS NOT NULL` appear in the waiting queue.

---

### 📝 `prescriptions`

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | uuid | PK | |
| `clinic_id` | uuid | FK → clinics.id | |
| `doctor_id` | uuid | FK → users.id | |
| `patient_id` | uuid | FK → patients.id | |
| `appointment_id` | uuid | FK → appointments.id | |
| `diagnosis` | uuid | FK → prescription_templates.id | Selected template |
| `notes` | text | | Doctor's notes |
| `created_at` | timestamptz | DEFAULT now() | |

---

### 💉 `prescription_items`

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | uuid | PK | |
| `prescription_id` | uuid | FK → prescriptions.id ON DELETE CASCADE | |
| `drug_id` | uuid | FK → drugs.id | |
| `frequency` | int | | Doctor's selection |
| `duration` | int | | Days |
| `is_prn` | bool | DEFAULT false | |
| `timing` | text | | Doctor's selection |

---

### 📄 `prescription_docs` _(optional)_

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | uuid | PK | |
| `prescription_id` | uuid | FK → prescriptions.id ON DELETE CASCADE | |
| `doc_url` | text | NOT NULL | Supabase Storage URL |

---

### 🧾 `invoices`
Created **manually** by secretary. Not auto-generated.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | uuid | PK | |
| `clinic_id` | uuid | FK → clinics.id | |
| `patient_id` | uuid | FK → patients.id | |
| `source_id` | uuid | FK → appointments.id | |
| `source_type` | text | DEFAULT 'appointment' | Extensible for future |
| `total_amount` | decimal | NOT NULL | Actual charged amount |
| `paid_amount` | decimal | DEFAULT 0 | |
| `payment_method` | text | | Optional |
| `created_at` | timestamptz | DEFAULT now() | |
| `created_by` | uuid | FK → users.id | |

> **Invoice status** (computed in app — NOT stored):
> `paid_amount = 0` → pending | `0 < paid < total` → partial | `paid >= total` → paid

---

### 💸 `expenses`

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | uuid | PK | |
| `clinic_id` | uuid | FK → clinics.id | |
| `category_id` | uuid | FK → expense_categories.id | |
| `amount` | decimal | NOT NULL | |
| `notes` | text | | |
| `created_at` | timestamptz | DEFAULT now() | |
| `created_by` | uuid | FK → users.id | |

---

### 🏷️ `expense_categories`

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | uuid | PK | |
| `name` | text | CHECK IN ('rent','electricity','supplies','salaries','maintenance','other') | |

---

### 📦 `plans`

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | uuid | PK | |
| `name` | text | CHECK IN ('basic','pro','enterprise') | |
| `monthly_price` | decimal | | |
| `yearly_price` | decimal | | |
| `lifetime_price` | decimal | | |
| `monthly_discount` | decimal | | Discount percentage |
| `yearly_discount` | decimal | | |
| `lifetime_discount` | decimal | | |
| `currency` | text | DEFAULT 'USD' | |
| `description` | text | | |
| `created_at` | timestamptz | DEFAULT now() | |

---

### ⭐ `plan_features`

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | uuid | PK | |
| `plan_id` | uuid | FK → plans.id | |
| `max_clinics` | int | | -1 = unlimited |
| `max_staff` | int | | -1 = unlimited |
| `max_patients` | int | | -1 = unlimited |
| `feature` | jsonb | | Additional feature flags |

> **`feature` jsonb example:**
> ```json
> {
>   "realtime": true,
>   "reports": true,
>   "whatsapp_integration": false,
>   "pdf_export": true,
>   "multi_branch": true
> }
> ```

---

### 💳 `subscriptions`

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | uuid | PK | |
| `owner_id` | uuid | FK → owners.id | Per owner, not per clinic |
| `plan_id` | uuid | FK → plans.id | |
| `subscription_type` | text | CHECK IN ('trial','monthly','yearly') | |
| `status` | text | CHECK IN ('pending','active','expired','cancelled') | |
| `start_at` | date | | |
| `end_at` | date | | |
| `created_at` | timestamptz | DEFAULT now() | |
| `created_by` | uuid | FK → owners.id | |

---

## RLS Policies

### Clinic-scoped tables
```sql
-- Staff: own clinic only
CREATE POLICY "clinic_staff_access" ON [table] FOR ALL
USING (clinic_id IN (
  SELECT clinic_id FROM clinic_staff
  WHERE user_id = auth.uid() AND is_active = true
));

-- Owner: all their clinics
CREATE POLICY "owner_clinic_access" ON [table] FOR ALL
USING (clinic_id IN (
  SELECT id FROM clinics WHERE owner_id = auth.uid()
));
```

### Owner-scoped (patients)
```sql
CREATE POLICY "patients_access" ON patients FOR ALL
USING (
  owner_id = auth.uid()
  OR owner_id IN (SELECT owner_id FROM users WHERE id = auth.uid())
);
```

### Personal (prescription_templates)
```sql
CREATE POLICY "templates_personal" ON prescription_templates FOR ALL
USING (doctor_id = auth.uid());
```

### Global (drugs, plans, plan_features)
```sql
CREATE POLICY "drugs_read_all" ON drugs FOR SELECT
USING (auth.role() = 'authenticated');

CREATE POLICY "plans_read_all" ON plans FOR SELECT
USING (auth.role() = 'authenticated');

CREATE POLICY "plan_features_read_all" ON plan_features FOR SELECT
USING (auth.role() = 'authenticated');
```

---

## Supabase Constants

```dart
// core/constants/supabase_constants.dart

class SupabaseTables {
  static const owners                    = 'owners';
  static const users                     = 'users';
  static const clinics                   = 'clinics';
  static const clinicStaff              = 'clinic_staff';
  static const invitations               = 'invitations';
  static const patients                  = 'patients';
  static const drugs                     = 'drugs';
  static const prescriptionTemplates     = 'prescription_templates';
  static const prescriptionTemplateItems = 'prescription_template_items';
  static const appointmentTypes          = 'appointment_types';
  static const appointments              = 'appointments';
  static const doctorQueueRules          = 'doctor_queue_rules';
  static const prescriptions             = 'prescriptions';
  static const prescriptionItems         = 'prescription_items';
  static const prescriptionDocs          = 'prescription_docs';
  static const invoices                  = 'invoices';
  static const expenses                  = 'expenses';
  static const expenseCategories         = 'expense_categories';
  static const plans                     = 'plans';
  static const planFeatures              = 'plan_features';
  static const subscriptions             = 'subscriptions';
}

class AppointmentStatus {
  static const scheduled  = 'scheduled';   // حجز مجدول
  static const confirmed  = 'confirmed';   // تأكيد الحضور (arrived_at set)
  static const inProgress = 'in_progress'; // داخل عند الدكتور (called_at set)
  static const done       = 'done';        // انتهى الكشف
  static const cancelled  = 'cancelled';   // ملغي
}

class QueueSlotType {
  static const normal  = 'normal';   // عادي
  static const urgent  = 'urgent';   // مستعجل
  static const revisit = 'revisit';  // إعادة كشف
  static const consult = 'consult';  // استشارة
}

class StaffRole {
  static const doctor     = 'doctor';
  static const secretary  = 'secretary';
}

class SubscriptionType {
  static const trial    = 'trial';
  static const monthly  = 'monthly';
  static const yearly   = 'yearly';
  static const lifetime = 'lifetime';
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

## Realtime-Enabled Tables

| Table | Events | Why |
|-------|--------|-----|
| `appointments` | ALL | Live calendar + queue sync (arrived_at, called_at, status changes) |
| `patients` | INSERT | New patient appears instantly |
| `prescriptions` | INSERT | Secretary notified after doctor saves |

```sql
ALTER TABLE appointments  REPLICA IDENTITY FULL;
ALTER TABLE patients      REPLICA IDENTITY FULL;
ALTER TABLE prescriptions REPLICA IDENTITY FULL;
```

> **Queue is Realtime via `appointments`** — no separate channel needed.
> Any change to `arrived_at`, `called_at`, `is_urgent`, or `status` triggers a queue refresh.
